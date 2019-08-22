package mm.screens.shop {
	
	import flash.display.MovieClip;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.events.Event;
	
	public class Cover extends MovieClip {
		
		
		public function Cover(hash:String)
		{
			var dla:DataLoadingAnim = new DataLoadingAnim();
			//dla.scaleX = 0.2;
			//dla.scaleY = 0.2;
			dla.x = 500;
			dla.y = 305;
			addChild(dla);
			
			var request:URLRequest = new URLRequest('https://playxcat.ru/storage/' + hash + ".swf?" + Math.random());
			var loader:Loader = new Loader();
			loader.load(request);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
		}
		
		private function loadComplete(event:Event):void
		{
			event.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
			
			removeChild(getChildAt(0));
			
			addChild(event.target.loader.content);
		}
	}
	
}
