package mm.interfaces {
	
	import flash.display.SimpleButton;
	import com.greensock.*;
	import com.greensock.easing.*;
	import flash.events.MouseEvent;
	
	public class Overlay extends SimpleButton {
		
		
		public function Overlay() {
			
			this.alpha = 0;
			this.addEventListener(MouseEvent.CLICK, overlayClick);
			
			TweenNano.to(this, 0.2, {alpha:1});
		}
		
		private function overlayClick(event:MouseEvent):void
		{
			this.removeEventListener(MouseEvent.CLICK, overlayClick);
			
			TweenNano.to(this, 0.2, {alpha:0});
		}
	}
	
}
