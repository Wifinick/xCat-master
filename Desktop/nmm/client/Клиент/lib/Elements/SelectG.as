package lib.Elements {
	import fl.transitions.easing.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	
	import com.greensock.*;
	
	import com.smartfoxserver.v2.*;
	import com.smartfoxserver.v2.entities.variables.*;
	import com.smartfoxserver.v2.entities.data.*;
	
	
	public class SelectG extends MovieClip {
		public function SelectG(P:Cr) {
			this.name = 'Selector';
			this.Shadow.alpha = 0;
			this.Win.y = 25;
			this.Win.alpha = 0;
			this.Win.G0.addEventListener(MouseEvent.CLICK, P.CloseG);
			for(var i:int = 1; i <= 6; i++){
				var G:MovieClip = this.Win.getChildByName('G' + String(i)) as MovieClip;
				G.mouseChildren = false;
				G.buttonMode = true;
				G.gotoAndStop('_up');
				G.addEventListener(MouseEvent.CLICK, P.SelectGift);
			}
		}
	}
}
