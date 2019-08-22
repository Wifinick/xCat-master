package lib.Elements {
	import fl.transitions.easing.*;
	
	import flash.display.*;
	import flash.events.*;
	
	import com.greensock.*;

	public class Mng extends MovieClip {
		public function Mng():void {
			this.name = 'Manager';
			
			this.Shadow.alpha = 0;
			this.Win.alpha = 0;
			this.Win.y = 72;
			
			this.Shadow.addEventListener(MouseEvent.CLICK, Close);
		}
		private function Close(e:MouseEvent):void {
			TweenNano.to(this.Shadow, 0.4, {ease: Regular.easeOut, alpha: 0});
			TweenNano.to(this.Win, 0.4, {ease: Regular.easeOut, alpha: 0, y: 22, onComplete:function(){
				stage.removeChild(stage.getChildByName('Manager')); 
			}});
		}
	}
}
