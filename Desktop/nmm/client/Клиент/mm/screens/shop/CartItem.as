package mm.screens.shop {
	
	import flash.display.MovieClip;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.events.Event;
	import com.adobe.crypto.MD5;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	
	import com.greensock.*;
	import com.greensock.easing.*;
	
	public class CartItem extends MovieClip {
		
		
		public function CartItem(params:ISFSObject)
		{
			this.name = params.getInt("id").toString();
			
			lblName.text = params.getUtfString("name");
			lblPrice.text = params.getInt("price").toString();
			
			if(params.getInt("balance_type_id") == 1)
				mcBalance.gotoAndStop(16);
			else if(params.getInt("balance_type_id") == 2)
				mcBalance.gotoAndStop(17);
			
			var dla:DataLoadingAnim = new DataLoadingAnim();
			dla.scaleX = 0.2;
			dla.scaleY = 0.2;
			mcIcon.addChild(dla);
			
			var request:URLRequest = new URLRequest('https://playxcat.ru/gameres/ff07673105bd3e6790eaec3b1d9deb88/' + MD5.hash("wear_" + params.getInt("id")) + ".swf?v" + Math.random());
			var loader:Loader = new Loader();
			loader.load(request);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
		}
		
		private function loadComplete(event:Event):void
		{
			event.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
			
			mcIcon.removeChild(mcIcon.getChildAt(0));
			
			var icon:MovieClip = event.target.loader.content.item;
			icon.x = 0;
			icon.y = 0;
			icon.scaleX = 0.6;
			icon.scaleY = 0.6;
			
			mcIcon.addChild(icon);
			mcIcon.alpha = 0;
			TweenNano.to(mcIcon, 0.3, {alpha:1});
			
		}
	}
	
}
