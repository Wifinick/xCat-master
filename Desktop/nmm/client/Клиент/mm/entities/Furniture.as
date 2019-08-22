package mm.entities {
	import flash.display.MovieClip;
	
	public class Furniture extends MovieClip {

		public var _id:int;
		public var _mc:MovieClip;
		public var type:int;
		public var graphic:MovieClip;
		public var hash;
		
		public function Furniture(mc:MovieClip, id:int, scale:Number, dir:int, _type:int, _hash:String = "")
		{
			graphic = mc.graphic;
			//graphic.x = 0;
			//graphic.y = 0;
			addChild(graphic);
			
			_id = id;
			type = _type;
			hash = _hash;
			
			scale /= 100;
			this.scaleX = scale;
			this.scaleY = scale;
			
			this.mouseChildren = false;
			this.mouseEnabled = false;
			
			this.name = "frn_" + _id.toString();
			
			this.graphic.gotoAndStop(dir);
			
		}
		
		public function destroy():void
		{
			//
		}
		
		public function set dir(dir:int):void
		{
			graphic.gotoAndStop(dir);
		}
		
		public function get dir():int
		{
			return graphic.currentFrame;
		}
		
		

	}
	
}
