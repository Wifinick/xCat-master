package lib.Elements {
	import fl.transitions.easing.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	
	import com.greensock.*;
	
	import com.smartfoxserver.v2.*;
	import com.smartfoxserver.v2.core.*;
	import com.smartfoxserver.v2.requests.*;
	import com.smartfoxserver.v2.util.*;
	import com.smartfoxserver.v2.entities.variables.*;
	import com.smartfoxserver.v2.entities.data.*;
	
	import lib.stuffForMM.*;
	import lib.*;

	public class Cr extends MovieClip {
		private var LastSelected:Object;
		private var SelectedGift:int = 0;
		private var SelectedPost:int = 0;
		private var G:Gifts;
		private var Gs:Gift;
		private var M;
		public function Cr(m) {
			M = m;
			
			this.name = 'Creator';

			for(var i:int; i < 3; i++){
				var Data:ISFSObject = new SFSObject();
				Data.putInt('Type', i+1);
				Data.putInt('Read', 1);
				Data.putInt('Gift', 0);
				Data.putUtfString('From', '');
				var C:Present = new Present(Data);
				C.name = 'C' + String(i+1);
				C.x = 170 + 90*i;
				C.y = 107;
				C.width = 60;
				C.height = 65;
				C.addEventListener(MouseEvent.CLICK, SelectThis);
				this.Win.addChild(C);
			}
			
			Gs = new Gift(true);
			Gs.x = 435;
			Gs.y = 70;
			Gs.width = 95;
			Gs.height = 65;
			Gs.addEventListener(MouseEvent.CLICK, OpenSelector);
			this.Win.addChild(Gs);
			
			this.Win.Send.alpha = .5;
			this.Win.Send.mouseEnabled = false;
			this.Win.Send.addEventListener(MouseEvent.CLICK, Send);
			this.Win.Nickname.addEventListener(KeyboardEvent.KEY_UP, CheckDone);
			
			this.Shadow.alpha = 0;
			this.Win.alpha = 0;
			this.Win.y = 233;
			this.Shadow.addEventListener(MouseEvent.CLICK, Close);
		}
		private function Send(e:MouseEvent):void {
			this.Win.Preload.alpha = 0;
			this.Win.Preload.visible = true;
			TweenNano.to(this.Win.Preload, .2, {ease: Regular.easeOut, alpha: 1});
			
			var Params:ISFSObject = new SFSObject();
			Params.putInt('Design', SelectedPost);
			Params.putInt('Gift', SelectedGift);
			Params.putUtfString('To', this.Win.Nickname.text);
			M.SFS.send(new ExtensionRequest('Gifts.SendGift', Params));
			trace(SelectedPost, SelectedGift);
		}
		private function CheckDone(e:KeyboardEvent=null):void {
			if(this.Win.Nickname.text && SelectedPost){
				this.Win.Send.mouseEnabled = true;
				TweenNano.to(this.Win.Send, .2, {ease: Regular.easeOut, alpha: 1});
			}
			else{
				this.Win.Send.mouseEnabled = false;
				TweenNano.to(this.Win.Send, .2, {ease: Regular.easeOut, alpha: .5});
			}
		}
		private function OpenSelector(e:MouseEvent):void {
			var S:SelectG = new SelectG(this);
			stage.addChild(S);
			TweenNano.to(S.Shadow, 0.4, {ease: Regular.easeOut, alpha: 1});
			TweenNano.to(S.Win, 0.4, {ease: Regular.easeOut, alpha: 1, y: 0});
		}
		public function SelectGift(e:MouseEvent):void {
			SelectedGift = int(e.target.name.split('G')[1]);
			Gs.gotoAndStop(SelectedGift+1);
			var D:MovieClip = stage.getChildByName('Selector') as MovieClip;
			TweenNano.to(D.Shadow, 0.3, {ease: Regular.easeOut, alpha: 0});
			TweenNano.to(D.Win, 0.3, {ease: Regular.easeOut, alpha: 0, y: -25, onComplete:function(){
				stage.removeChild(D); 
			}});
		}
		public function CloseG(e:MouseEvent):void {
			SelectedGift = 0;
			Gs.gotoAndStop(SelectedGift);
			var D:MovieClip = stage.getChildByName('Selector') as MovieClip;
			TweenNano.to(D.Shadow, 0.3, {ease: Regular.easeOut, alpha: 0});
			TweenNano.to(D.Win, 0.3, {ease: Regular.easeOut, alpha: 0, y: -25, onComplete:function(){
				stage.removeChild(D); 
			}});
		}
		private function SelectThis(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.AUTO;
			
			if(LastSelected){
				LastSelected.gotoAndStop('_up');
				LastSelected.Selected = false;
				TweenNano.to(LastSelected, 0.3, {ease: Regular.easeOut, alpha: .7});
			}
			
			SelectedPost = int(e.target.name.split('C')[1]);
			LastSelected = e.target;
			
			LastSelected.gotoAndStop('_over');
			LastSelected.Selected = true;
			
			CheckDone();
		}
		private function Close(e:MouseEvent):void {
			TweenNano.to(this.Shadow, 0.3, {ease: Regular.easeOut, alpha: 0});
			TweenNano.to(this.Win, 0.3, {ease: Regular.easeOut, alpha: 0, y: 183, onComplete:function(){
				stage.removeChild(stage.getChildByName('Creator')); 
			}});
		}
	}
}
