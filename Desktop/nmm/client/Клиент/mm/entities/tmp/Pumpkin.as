package mm.entities.tmp {
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class Pumpkin extends MovieClip {

		public var _id:int;
		public var _mc:MovieClip;
		public var graphic:MovieClip;
		public var gift:MovieClip;
		
		public function Pumpkin(mc:MovieClip, scale:Number)
		{
			graphic = mc.graphic;
			addChild(graphic);
			
			scale /= 100;
			this.scaleX = scale;
			this.scaleY = scale;
			
			this.mouseChildren = false;
			this.mouseEnabled = false;
			
			this.name = "pumpkin";
		}
		
		
		public function open(_gift:Number):void
		{
			graphic.gotoAndPlay(2);
			
			gift = graphic.gift;
			gift.gotoAndStop(_gift);
		}
		
		public function destroy():void
		{
			//
		}
	}
	
}
