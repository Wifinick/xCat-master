package lib.Elements {
	import fl.transitions.easing.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	
	import com.greensock.*;
	
	import com.smartfoxserver.v2.*;
	import com.smartfoxserver.v2.entities.variables.*;
	import com.smartfoxserver.v2.entities.data.*;

	public class Gift extends MovieClip {
		public function Gift(MouseMode:Boolean=false):void {
			if(MouseMode){
				this.gotoAndStop(1);
				
				this.alpha = .7;
				
				this.addEventListener(MouseEvent.MOUSE_OVER, Over);
				this.addEventListener(MouseEvent.MOUSE_OUT, Out);
			}
		}
		private function Over(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.BUTTON;
			TweenNano.to(this, 0.3, {ease: Regular.easeOut, alpha: 1});
		}
		private function Out(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.AUTO;
			TweenNano.to(this, 0.3, {ease: Regular.easeOut, alpha: .7});
		}
	}
}
