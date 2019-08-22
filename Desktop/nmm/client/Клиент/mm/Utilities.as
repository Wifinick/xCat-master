package mm
{
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.display3D.IndexBuffer3D;
	import flash.ui.GameInput;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import com.hurlant.crypto.symmetric.NullPad;
	import flash.ui.GameInput;
	import flash.ui.Keyboard;
	import flash.geom.ColorTransform;
	import flash.display.Loader;
	import flash.net.URLRequest;

	public class Utilities
	{

		/*public function Utilities() {
		// constructor code
		}*/

		/*public static function loadObject(link:String):Object
		{
			var request:URLRequest = new URLRequest("link");
			var loader:Loader = new Loader  ;
			loader.load(request);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,loadProgress);
			//loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorListener);

			var room = event.params.room;

			function loadComplete(event:Event):void
			{
				event.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
				loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,loadProgress);

				Main.main.removeChild(loadingScreen);

				MC = event.target.loader.content;

				initLocation(room);
			}

		}*/
		
		public static function stopAllClips(mc:MovieClip):void
		{
			var n:int = mc.numChildren;
			for (var i:int=0; i<n; i++)
			{
				var clip:MovieClip = mc.getChildAt(i) as MovieClip;
				if (clip)
				{
					clip.gotoAndStop(1);
				}
			}
		}

	}
}