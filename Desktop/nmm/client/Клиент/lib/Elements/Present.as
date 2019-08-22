package lib.Elements {
	import fl.transitions.easing.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	
	import com.greensock.*;
	
	import com.smartfoxserver.v2.*;
	import com.smartfoxserver.v2.entities.variables.*;
	import com.smartfoxserver.v2.entities.data.*;

	public class Present extends MovieClip {
		public var Info:ISFSObject = new SFSObject();
		public var Selected:Boolean = false;
		public function Present(Data:ISFSObject):void {
			Info = Data;
			
			this.mouseChildren = false;
			this.alpha = .7;
			this.gotoAndStop('_up');
			this.G.gotoAndStop(Data.getInt('Type'));
			this.IsGift.visible = Boolean(Data.getInt('Gift'));
			this.IsNew.visible = !Data.getInt('Read');
			
			this.addEventListener(MouseEvent.MOUSE_OVER, Over);
			this.addEventListener(MouseEvent.MOUSE_OUT, Out);
		}
		private function Over(e:MouseEvent):void {
			if(!Selected){
				Mouse.cursor = MouseCursor.BUTTON;
				this.gotoAndStop('_over');
				TweenNano.to(this, 0.3, {ease: Regular.easeOut, alpha: 1});
			}
		}
		private function Out(e:MouseEvent):void {
			if(!Selected){
				Mouse.cursor = MouseCursor.AUTO;
				this.gotoAndStop('_up');
				TweenNano.to(this, 0.3, {ease: Regular.easeOut, alpha: .7});
			}
		}
	}
}
