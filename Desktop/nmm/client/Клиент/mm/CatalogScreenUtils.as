package mm {
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.*;
	import com.smartfoxserver.v2.requests.*;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.hurlant.crypto.symmetric.NullPad;
	import flash.utils.*;
	
	public class CatalogScreenUtils {
		
		private static var catalogScreen;
		
		public function CatalogScreenUtils() {
			super();
		}
		
		public static function init():void
		{
			Main.sfs.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsExtensionResponse);
			
			var request:URLRequest = new URLRequest('https://playxcat.ru/gameres/4fdeddb85f44ee6ef00c9c40c2c802fe/7e479b9703b8483ace422236f4582cad.swf?v' + Math.random());
			var loader:Loader = new Loader();
			loader.load(request);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
			
			function loadComplete(event:Event):void
			{
				event.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
				
				catalogScreen = event.target.loader.content.catalogScreen;
				
				catalogScreen.overlay.addEventListener(MouseEvent.CLICK, overlayClick);
				catalogScreen.screen.btnNext.addEventListener(MouseEvent.CLICK, btnNextClick);
				
				Main.main.addChild(catalogScreen);
				
				Main.main.removeChild(Main.main.getChildByName("dls"));
			}
		}
		
		private static function overlayClick(event:MouseEvent):void
		{
			Main.main.removeChild(catalogScreen);
		}
		
		private static function btnNextClick(event:MouseEvent):void
		{
			if(catalogScreen.screen.currentFrame == 1)
			{
				catalogScreen.screen.gotoAndStop(3);
				catalogScreen.screen.btnNext.addEventListener(MouseEvent.CLICK, btnNextClick);
				catalogScreen.screen.btnPrev.addEventListener(MouseEvent.CLICK, btnPrevClick);
			}
			else if(catalogScreen.screen.currentFrame == catalogScreen.screen.totalFrames)
			{
				catalogScreen.screen.gotoAndStop(2);
				catalogScreen.screen.btnPrev.addEventListener(MouseEvent.CLICK, btnPrevClick);
			}
			else
			{
				catalogScreen.screen.nextFrame();
			}
			
			findButtons();
		}
		
		private static function btnPrevClick(event:MouseEvent):void
		{
			if(catalogScreen.screen.currentFrame == 2)
			{
				catalogScreen.screen.gotoAndStop(catalogScreen.screen.totalFrames);
				catalogScreen.screen.btnNext.addEventListener(MouseEvent.CLICK, btnNextClick);
				catalogScreen.screen.btnPrev.addEventListener(MouseEvent.CLICK, btnPrevClick);
			}
			else if(catalogScreen.screen.currentFrame == 3)
			{
				catalogScreen.screen.gotoAndStop(1);
				catalogScreen.screen.btnNext.addEventListener(MouseEvent.CLICK, btnNextClick);
			}
			else
			{
				catalogScreen.screen.prevFrame();
			}
			
			findButtons();
		}
		
		private static function btnBuyClick(event:MouseEvent):void
		{
			var params:ISFSObject = new SFSObject();
			params.putInt("id", int(event.target.name.substr(7)));
			trace(int(event.target.name.substr(7)));

			Main.sfs.send(new ExtensionRequest("catalog_wear.price", params));
			
			var dataLoadingScreen:DataLoadingScreen = new DataLoadingScreen();
			dataLoadingScreen.name = "dls"
			Main.main.addChild(dataLoadingScreen);
		}
		
		private static function findButtons():void
		{
			for (var i:uint=0; i < catalogScreen.screen.numChildren; i++)
			{
				if (catalogScreen.screen.getChildAt(i).name.indexOf("btnBuy") >= 0)
				{
					catalogScreen.screen.getChildAt(i).addEventListener(MouseEvent.CLICK, btnBuyClick);
				}
			}
		}
		
		public static function sfsExtensionResponse(evt:SFSEvent):void
		{
			var responseParams;
			
			if (evt.params.cmd == "catalog_price_response")
			{
				responseParams = evt.params.params as SFSObject;
				
				if(responseParams.getInt("price") != null)
				{
					var buyScreenMC:BuyScreen = new BuyScreen();
					
					buyScreenMC.name = "buyScreen";
					
					if(responseParams.getInt("price") == 0)
					{
						buyScreenMC.screen.lblMessage.text = "Вы хотите получить " + responseParams.getUtfString("name") + "?";
						buyScreenMC.screen.lblName.text = "Получение подарка";
					}
					else
					{
						buyScreenMC.screen.lblMessage.text = "Вы хотите купить " + responseParams.getUtfString("name") + " за " + responseParams.getInt("price") + " клубков?";
					}
					buyScreenMC.overlay.addEventListener(MouseEvent.CLICK, btnOverlayClick);
					buyScreenMC.screen.btnYes.addEventListener(MouseEvent.CLICK, btnYesClick);
					buyScreenMC.screen.btnNo.addEventListener(MouseEvent.CLICK, btnNoClick);
					
					function btnOverlayClick(event:MouseEvent):void
					{
						Main.main.removeChild(buyScreenMC);
					}
					
					function btnYesClick(event:MouseEvent):void
					{
						var params:ISFSObject = new SFSObject();
						params.putInt("id", responseParams.getInt("id"));
			
						Main.sfs.send(new ExtensionRequest("catalog_wear.buy", params));
						
						var dataLoadingScreen:DataLoadingScreen = new DataLoadingScreen();
						dataLoadingScreen.name = "dls"
						Main.main.addChild(dataLoadingScreen);
					}
					
					function btnNoClick(event:MouseEvent):void
					{
						Main.main.removeChild(buyScreenMC);
					}
					
					Main.main.addChild(buyScreenMC);
				}
				
				Main.main.removeChild(Main.main.getChildByName("dls"));
			}
			
			if (evt.params.cmd == "catalog_buy_response")
			{
				responseParams = evt.params.params as SFSObject;
				
				Main.main.removeChild(Main.main.getChildByName("dls"));
				
				if(responseParams.getUtfString("message") == "success")
				{
					Main.main.removeChild(Main.main.getChildByName("buyScreen"));
				}
				else
				{
					var buyScreen = Main.main.getChildByName("buyScreen") as MovieClip;
					buyScreen.screen.lblResponse.text = responseParams.getUtfString("message");
				}
			}
		}
	}
	
}
