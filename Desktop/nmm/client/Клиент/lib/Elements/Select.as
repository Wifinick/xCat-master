package lib.Elements {
	import fl.transitions.easing.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	
	import com.greensock.*;
	
	import com.smartfoxserver.v2.*;
	import com.smartfoxserver.v2.entities.variables.*;
	import com.smartfoxserver.v2.entities.data.*;
	
	
	public class Select extends MovieClip {
		public function Select() {
			this.Shadow.alpha = 0;
			this.Win.y = 25;
			this.Win.alpha = 0;
		}
	}
}
