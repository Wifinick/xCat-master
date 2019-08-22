package lib.stuffForMM {
	import flash.display.*;
	import flash.utils.*;
	import flash.events.*;
	import flash.text.*;
	import flash.ui.*;
	import flash.geom.*;
	
	import fl.transitions.easing.*;
	
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.smartfoxserver.v2.*;
	import com.smartfoxserver.v2.core.*;
	import com.smartfoxserver.v2.requests.*;
	import com.smartfoxserver.v2.util.*;
	import com.smartfoxserver.v2.entities.variables.*;
	import com.smartfoxserver.v2.entities.data.*;
	
	import lib.*;
	import lib.Elements.*;
	import mm.Main;
	import mm.ScrollBar;
	
	public class Gifts {
		private var M:Main;
		private var W:Cr;
		private var V:Mng;
		private var P:DataLoadingScreen;
		private var Giftes:ISFSArray;
			
		public function Gifts(m):void {
			M = m;
			M.SFS.addEventListener(SFSEvent.EXTENSION_RESPONSE, OnExt);
		}
		private function OnExt(e:SFSEvent):void {
			switch(e.params.cmd){
				case 'Gifts.GetList':
					InitList(e.params.params);
					break;
				case 'Gifts.SendGift':
					var D:MovieClip = M.stage.getChildByName('Creator') as MovieClip;
					TweenNano.to(D.Shadow, 0.3, {ease: Regular.easeOut, alpha: 0});
					TweenNano.to(D.Win, 0.3, {ease: Regular.easeOut, alpha: 0, y: 183, onComplete:function(){
						M.stage.removeChild(D); 
					}});
					if(!e.params.params.getUtfString('error')){
						var T:Array = V.Win.YouHave.text.split('Отправлено: ');
						V.Win.YouHave.text = T[0] + 'Отправлено: ' + String(int(T[1]) + 1);
					}
					break;
			}
		}
		private function InitList(D:ISFSObject):void {
			TweenNano.to(P, 0.2, {ease: Regular.easeOut, alpha: 0, onComplete:function(){
				M.stage.removeChild(P); 
			}});
			
			V = new Mng();
			
			Giftes = D.getSFSArray('Gifts');
			var Gift:ISFSObject;
			var Item:Present;
			
			var scrl = V.Win.scrollbar;
			scrl.area.slider.stop();
			scrl.visible = false;
			
			TweenNano.to(Main.gameScreen.chatPanel.counterValentine, 0.2, {ease: Regular.easeOut, alpha: 0, onComplete:function(){
				Main.gameScreen.chatPanel.counterValentine.visible = false; 
				Main.gameScreen.chatPanel.counterValentine.lblCount.text = '0';
			}});
			
			V.Win.SendPost.addEventListener(MouseEvent.CLICK, OpenPostSender);
			V.Win.YouHave.text = 'Получено: ' + Giftes.size() + '\nОтправлено: ' + D.getLong('Sent');
			V.Win.Empty.visible = !Giftes.size();
			
			for(var i:int; i < Giftes.size(); i++){
				Gift = Giftes.getElementAt(i);
				Item = new Present(Gift);
				Item.x = 30 + (95*(i-((int(i/6))*6) )); 
				Item.y = 15 + (95*int(i/6));
				Item.addEventListener(MouseEvent.CLICK, OpenGift);
				//V.Win.Cont.addChild(Item);
				V.Win.field.content.addChild(Item);
			}
			
			if(V.Win.field.content.height > V.Win.field.mask.height)
			{
				scrl.visible = true;
				var scrollBar:ScrollBar = new ScrollBar(V.Win.field, scrl, Main.main.stage, 50);
			}
			
			M.stage.addChild(V);
			TweenNano.to(V.Shadow, 0.4, {ease: Regular.easeOut, alpha: 1});
			TweenNano.to(V.Win, 0.4, {ease: Regular.easeOut, alpha: 1, y: 47});
		}
		private function OpenPostSender(e:MouseEvent):void {
			var C:Cr = new Cr(M);
			M.stage.addChild(C);
			TweenNano.to(C.Shadow, 0.4, {ease: Regular.easeOut, alpha: 1});
			TweenNano.to(C.Win, 0.4, {ease: Regular.easeOut, alpha: 1, y: 208});
		}
		private function OpenGift(e:MouseEvent):void {
			var Post:Postcard = new Postcard(e.target.Info);
			var Prev:Object = {'x': Post.Win.x, 'y': Post.Win.y, 'width': Post.Win.width, 'height': Post.Win.height};
			Post.Win.x = e.target.x+175;
			Post.Win.y = e.target.y+168;
			Post.Win.width = 75;
			Post.Win.height = 75;
			Post.Shadow.alpha = 0;
			M.stage.addChild(Post);
			TweenNano.to(Post.Shadow, 0.3, {ease: Regular.easeOut, alpha: 1});
			TweenNano.to(Post.Win, 0.3, {ease: Regular.easeOut, x: Prev.x, y: Prev.y, width: Prev.width, height: Prev.height, alpha: 1});
		}
		public function Init(e:MouseEvent):void {
			P = new DataLoadingScreen();
			P.alpha = 0;
			M.stage.addChild(P);
			TweenNano.to(P, 0.2, {ease: Regular.easeOut, alpha: 1});
			M.SFS.send(new ExtensionRequest('Gifts.GetList'));
		}
	}
}

