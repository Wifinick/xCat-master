package lib.Elements {
	import fl.transitions.easing.*;
	
	import flash.display.*;
	import flash.events.*;
	
	import com.greensock.*;
	
	import com.smartfoxserver.v2.*;
	import com.smartfoxserver.v2.entities.variables.*;
	import com.smartfoxserver.v2.entities.data.*;
	
	public class Postcard extends MovieClip {
		public function Postcard(Data:ISFSObject) {
			this.name = 'Postcard';
			this.Win.gotoAndStop(Data.getInt('Type'));
			this.Win.From.text = 'От: ' + Data.getUtfString('From');
			this.Win.Pres.visible = Data.getInt('Gift');
			this.Win.Pres.Present.gotoAndStop(Data.getInt('Gift')+1);
			this.Win.alpha = 0;
			
			this.Shadow.addEventListener(MouseEvent.CLICK, Close);
		}
		private function Close(e:MouseEvent):void {
			TweenNano.to(this.Shadow, 0.3, {ease: Regular.easeOut, alpha: 0});
			TweenNano.to(this.Win, 0.3, {ease: Regular.easeOut, alpha: 0, y: 22, onComplete:function(){
				stage.removeChild(stage.getChildByName('Postcard')); 
			}});
		}
	}
}
