package mm.screens.shop {
	
	import flash.display.MovieClip;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.adobe.crypto.MD5;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	
	import com.greensock.*;
	import com.greensock.easing.*;
	import mm.screens.ShopScreen;
	
	public class CatalogItem extends MovieClip {
		
		private var pos_y:int;
		private var item:ISFSObject;
		
		public function CatalogItem(params:ISFSObject) 
		{
			item = params;
			
			this.blendMode = BlendMode.LAYER;
			//this.mouseChildren = false;
			this.mcIcon.mouseEnabled = false;
			this.lblName.mouseEnabled = false;
			this.lblPrice.mouseEnabled = false;
			this.mcBalance.mouseEnabled = false;
			
			lblName.text = params.getUtfString("name");
			lblPrice.text = params.getInt("price").toString();
			
			if(params.getInt("balance_type_id") == 1)
				mcBalance.gotoAndStop(16);
			else if(params.getInt("balance_type_id") == 2)
				mcBalance.gotoAndStop(17);
			
			var dla:DataLoadingAnim = new DataLoadingAnim();
			dla.scaleX = 0.6;
			dla.scaleY = 0.6;
			mcIcon.addChild(dla);
			
			var request:URLRequest = new URLRequest('https://playxcat.ru/gameres/ff07673105bd3e6790eaec3b1d9deb88/' + MD5.hash("wear_" + params.getInt("id")) + ".swf?v" + Math.random());
			var loader:Loader = new Loader();
			loader.load(request);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			
			addEventListener(MouseEvent.MOUSE_OVER, over);
			addEventListener(MouseEvent.MOUSE_OUT, out);
			
			btnView.addEventListener(MouseEvent.CLICK, btnViewClick);
			btnCart.addEventListener(MouseEvent.CLICK, btnCartClick);
		}
		
		private function btnViewClick(event:MouseEvent):void
		{
			var shopScreen:ShopScreen = this.parent.parent.parent.parent as ShopScreen;
			shopScreen.createView(item);
		}
		
		private function btnCartClick(event:MouseEvent):void
		{
			var shopScreen:ShopScreen = this.parent.parent.parent.parent as ShopScreen;
			shopScreen.cart.addItem(item);
		}
		
		private function over(event:MouseEvent):void
		{
			if(!pos_y) pos_y = this.y;
			
			TweenNano.to(this, 0.3, {y:pos_y - 3});
		}
		
		private function out(event:MouseEvent):void
		{
			TweenNano.to(this, 0.3, {y:pos_y});
		}
		
		private function loadComplete(event:Event):void
		{
			event.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
			
			mcIcon.removeChild(mcIcon.getChildAt(0));
			
			var icon:MovieClip = event.target.loader.content.item;
			icon.x = 0;
			icon.y = 0;
			icon.scaleX = 2;
			icon.scaleY = 2;
			
			mcIcon.addChild(icon);
			mcIcon.alpha = 0;
			TweenNano.to(mcIcon, 0.3, {alpha:1});
			
		}
	}
	
}
