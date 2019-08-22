package mm {
	import flash.display.*;
	import flash.utils.*;
	import flash.events.*;
	import flash.text.*;
	import flash.ui.*;
	import flash.geom.*;
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.smartfoxserver.v2.*;
	import com.smartfoxserver.v2.core.*;
	import com.smartfoxserver.v2.requests.*;
	import com.smartfoxserver.v2.util.*;
	import com.smartfoxserver.v2.entities.variables.*;
	import com.smartfoxserver.v2.entities.data.*;
	//import lib.*;
	import mm.Main;
	import mm.ScrollBar;
	
	public class Valentine {
		private var M:Main;
		private var W:Valentine_Cr;
		public var V:Valentine_Mng;
		private var P:DataLoadingScreen;
		
		private var Selected:int;
		
		private var ValData:ISFSObject;
		
		public function Valentine(m:Main):void {
			M = m;
		}
		public function Init(e:MouseEvent):void {
			TweenLite.to(Main.gameScreen.chatPanel.counterValentine, 0.7, {ease:Expo.easeOut, alpha: 0, onComplete:function(){
				Main.gameScreen.chatPanel.counterValentine.visible = false; 
				Main.gameScreen.chatPanel.counterValentine.lblCount.text = '0';
			}});
			V = new Valentine_Mng();
			V.Shadow.alpha = 0;
			V.Win.alpha = 0;
			V.Win.y = 72;
			V.Shadow.addEventListener(MouseEvent.CLICK, CloseMng);
			V.Win.SendValentine.addEventListener(MouseEvent.CLICK, OpenVSender);
			
			P = new DataLoadingScreen();
			P.alpha = 0;
			Main.main.addChild(P);
			TweenLite.to(P, 0.7, {ease:Expo.easeOut, alpha: 1});
			
			Main.sfs.send(new ExtensionRequest('getValentine'));
		}
		
		public function InitWindow(data:ISFSObject):void {
			ValData = data;
			
			TweenLite.to(P, 0.7, {ease:Expo.easeOut, alpha: 0, onComplete:function(){
				Main.main.removeChild(P); 
			}});
			
			V.Win.YouHave.text = 'Получено: ' + String(data.getSFSArray('types').size()) + '\nОтправлено: ' + String(data.getInt('sent'));
			V.Win.Empty.visible = !data.getSFSArray('types').size();
			
			var LongX:int = 30;
			var LongY:int = 15;
			
			var scrl = V.Win.scrollbar;
			scrl.area.slider.stop();
			scrl.visible = false;
			
			
			for(var i:int; i < data.getSFSArray('types').size(); i++){
				var Val:Class = getDefinitionByName('V' + data.getSFSArray('types').getElementAt(i)) as Class;
				var VInv = new Val();
				VInv.gotoAndStop('_up');
				VInv.x = LongX;
				VInv.y = LongY;
				VInv.alpha = 0.8;
				VInv.name = 'V_' + String(i);
				if(!data.getSFSArray('isRead').getElementAt(i)){
					var Q:NewValentine = new NewValentine();
					Q.x = VInv.width;
					Q.y = 0;
					Q.name = 'New';
					VInv.addChild(Q);
				}
				VInv.addEventListener(MouseEvent.MOUSE_OVER, OnVOver);
				VInv.addEventListener(MouseEvent.MOUSE_OUT, OnVOut);
				
				V.Win.field.content.addChild(VInv);
				
				LongX += 95;
				if(int((i+1)/6) != int(i/6)){
					LongY += 95;
					LongX = 30;
				}
			}
			
			if(V.Win.field.content.height > V.Win.field.mask.height)
			{
				scrl.visible = true;
				
				//if(scrollBar)
				//	scrollBar.destroy();
					
				var scrollBar:ScrollBar = new ScrollBar(V.Win.field, scrl, Main.main.stage, 50);
				
				//var scrollBar:ScrollBar = new ScrollBar(chp.field, chp.scrollbar, Main.main.stage, 25, true, heightModifer);
			}
			
			Main.main.addChild(V);
			TweenLite.to(V.Shadow, 0.7, {ease:Expo.easeOut, alpha: 1});
			TweenLite.to(V.Win, 0.7, {ease:Expo.easeOut, alpha: 1, y: 47});
		}
		public function OpenVSender(e:MouseEvent):void {
			W = new Valentine_Cr();
			W.name = 'Valentine';
			W.Shadow.alpha = 0;
			W.Window.alpha = 0;
			W.Window.y = 258;
			W.Shadow.addEventListener(MouseEvent.CLICK, Close);
			
			for(var i:int = 1; i <= 4; i++){
				var Child:MovieClip = W.Window.getChildByName('V_' + String(i)) as MovieClip;
				Child.gotoAndStop('_up');
				Child.addEventListener(MouseEvent.CLICK, SetThis);
				Child.addEventListener(MouseEvent.MOUSE_OVER, SelectThis);
				Child.addEventListener(MouseEvent.MOUSE_OUT, UnsetThis);
			}
			
			W.Window.CheckBox.gotoAndStop('_up');
			W.Window.CheckBox.Enabled = false;
			
			W.Window.CheckBox.addEventListener(MouseEvent.CLICK, SetCheckBox);
			W.Window.CheckBox.addEventListener(MouseEvent.MOUSE_OVER, SelCheckBox);
			W.Window.CheckBox.addEventListener(MouseEvent.MOUSE_OUT, UnselCheckBox);
			W.Window.Nickname.addEventListener(KeyboardEvent.KEY_UP, CheckDone);
			
			W.Window.Preload.visible = false;
			W.Window.Send.alpha = 0.5;
			W.Window.Send.mouseEnabled = false;
			W.Window.Send.addEventListener(MouseEvent.CLICK, SendValentine);
			
			Main.main.addChild(W);
			TweenLite.to(W.Shadow, 0.7, {ease:Expo.easeOut, alpha: 1});
			TweenLite.to(W.Window, 0.7, {ease:Expo.easeOut, alpha: 1, y: 233});
		}
		private function SendValentine(e:MouseEvent):void {
			var Data:ISFSObject = new SFSObject();
			Data.putInt('anonymous', (W.Window.CheckBox.Enabled ? 1 : 0));
			Data.putInt('type', Selected);
			Data.putUtfString('to', W.Window.Nickname.text);
			
			W.Window.Preload.alpha = 0;
			W.Window.Preload.visible = true;
			TweenLite.to(W.Window.Preload, 0.7, {ease:Expo.easeOut, alpha: 1});
			
			Main.sfs.send(new ExtensionRequest('sendValentine', Data));
		}
		private function CheckDone(e:KeyboardEvent=null):void {
			if(W.Window.Nickname.text && Selected){
				W.Window.Send.mouseEnabled = true;
				TweenLite.to(W.Window.Send, 0.5, {ease:Expo.easeOut, alpha: 1});
			}
			else{
				W.Window.Send.mouseEnabled = false;
				TweenLite.to(W.Window.Send, 0.5, {ease:Expo.easeOut, alpha: 0.5});
			}
		}
		private function SetCheckBox(e:MouseEvent):void {
			W.Window.CheckBox.Enabled = !W.Window.CheckBox.Enabled;
			W.Window.CheckBox.gotoAndStop((W.Window.CheckBox.Enabled ? '_down' : '_up'));
		}
		private function SetThis(e:MouseEvent):void {
			Selected = int(e.target.name.split('_')[1]);
			CheckDone();
			
			for(var i:int = 1; i <= 4; i++){
				var Child:MovieClip = W.Window.getChildByName('V_' + String(i)) as MovieClip;
				Child.gotoAndStop((e.target == Child ? '_down' : '_up'));
			}
		}
		private function CloseMng(e:MouseEvent):void {
			TweenLite.to(V.Shadow, 0.7, {ease:Expo.easeOut, alpha: 0});
			TweenLite.to(V.Win, 0.7, {ease:Expo.easeOut, alpha: 0, y: 22, onComplete:function(){
				Main.main.removeChild(V); 
				Selected = 0;
			}});
		}
		private function Close(e:MouseEvent):void {
			TweenLite.to(W.Shadow, 0.7, {ease:Expo.easeOut, alpha: 0});
			TweenLite.to(W.Window, 0.7, {ease:Expo.easeOut, alpha: 0, y: 208, onComplete:function(){
				Main.main.removeChild(W); 
				Selected = 0;
			}});
		}
		//Тут события при наведении и отводе мыши
		private function OnVOver(e:MouseEvent):void {
			var Target = (e.target.name != 'New' ? e.target : e.target.parent);
			TweenLite.to(Target, 0.2, {alpha: 1});
			var I:WhoS = new WhoS();
			I.name = 'WhoSent';
			I.From.text = 'От ' + ValData.getSFSArray('fr').getElementAt(int(Target.name.split('_')[1]));
			I.x = (Target.width/2);
			I.y = Target.height / 3 + 10;
			I.mouseEnabled = false;
			I.mouseChildren = false;
			//V.Win.field.content.addChild(I);
			Target.addChild(I);
		}
		private function OnVOut(e:MouseEvent):void {
			TweenLite.to(e.target, 0.2, {alpha: 0.8});
			e.currentTarget.removeChild(e.currentTarget.getChildByName('WhoSent'));
		}
		private function SelCheckBox(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.BUTTON;
			W.Window.CheckBox.gotoAndStop((W.Window.CheckBox.Enabled ? '_down' : '_over'));
		}
		private function UnselCheckBox(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.AUTO;
			W.Window.CheckBox.gotoAndStop((W.Window.CheckBox.Enabled ? '_down' : '_up'));
		}
		private function SelectThis(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.BUTTON;
			e.target.gotoAndStop('_down');
		}
		private function UnsetThis(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.AUTO;
			e.target.gotoAndStop((int(e.target.name.split('_')[1]) == Selected ? '_down' : '_up'));
		}
	}
}
