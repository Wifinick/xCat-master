package mm.screens {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import com.smartfoxserver.v2.entities.data.ISFSArray;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import mm.Main;
	import com.greensock.*;
	import com.greensock.easing.*;
	import mm.screens.shop.*;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	public class ShopScreen extends MovieClip {
		
		private var shop:String;
		private var catalog:ISFSArray;
		private var pageNum:int = 1;
		private var pagesCount:int;
		private var hash:String;
		public var cart:Cart;
		public var _catalog:Catalog;
		
		public function ShopScreen(container:Main, params:ISFSObject)
		{
			Main.sfs.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsExtensionResponse);
			
			cart = this.cartPanel as Cart;
			
			shop = params.getUtfString("name");
			catalog = params.getSFSArray("catalog");
			hash = params.getUtfString("hash");
			
			cart.shop = shop;
			
			pagesCount = catalog.size() / 15 + 1;
			
			//
			// navigationPanel
			//
			
			var np:MovieClip = this.navigationPanel;
			
			np.logo.gotoAndStop(shop);
			
			np.btnCover.addEventListener(MouseEvent.CLICK, btnCoverClick);
			np.btnCatalog.addEventListener(MouseEvent.CLICK, btnCatalogClick);
			np.btnExit.addEventListener(MouseEvent.CLICK, btnExitClick);
			np.btnCart.addEventListener(MouseEvent.CLICK, btnCartClick);
			np.lblRegular.text = Main.sfs.mySelf.getVariable("balance_regular").getIntValue().toString();
			np.lblDonate.text = Main.sfs.mySelf.getVariable("balance_donate").getIntValue().toString();
			
			for(var i:int = 0; i < catalog.size(); i++)
			{
				trace(catalog.getSFSObject(i).getUtfString("name"));
			}
			
			container.removeChild(container.getChildByName("dls"));
			container.addChild(this);
			
			this.alpha = 0;
			
			TweenNano.to(this, 0.2, {alpha:1});
			
			var cover:Cover = new Cover(hash);
			
			this.field.addChild(cover);
		}
		
		private function destroy():void
		{
			Main.sfs.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsExtensionResponse);
			this.parent.removeChild(this);
		}
		
		private function btnCoverClick(event:MouseEvent):void
		{
			if(this.field.numChildren > 0)
				this.field.removeChildAt(0);
			
			var cover:Cover = new Cover(hash);
			
			this.field.addChild(cover);
		}
		
		private function btnCatalogClick(event:MouseEvent):void
		{
			btnCoverClick(event);
			if(this.field.numChildren > 0)
				this.field.removeChildAt(0);
			
			var sc:Catalog = new Catalog(catalog);
			
			this.field.addChild(sc);
			
			_catalog = sc as Catalog;
		}
		
		public function createView(item:ISFSObject):void
		{
			if(this.field.numChildren > 0)
				this.field.removeChildAt(0);
			
			var view:View = new View(shop, item);
			
			this.field.addChild(view);
		}
		
		private function btnCartClick(event:MouseEvent):void
		{
			if(cart.visible)
				TweenLite.to(cart, 0.2, {y:"-20", visible:false, alpha:0});
			else
				TweenLite.fromTo(cart, 0.2, {y:37, alpha:0, visible:true}, {y:"20", alpha:1});
		}
		
		private function btnExitClick(event:MouseEvent):void
		{
			TweenNano.to(this, 0.2, {alpha:0, onComplete:destroy});
		}
		
		public function sfsExtensionResponse(evt:SFSEvent):void
		{
			var responseParams;

			if (evt.params.cmd == "shop_buy_response")
			{
				responseParams = evt.params.params as SFSObject;

				for (var i:int = 0; i < cart.items.size(); i++)
				{
					cart.items.removeElementAt(i);
					i--;
				}

				cart.updateItems();



				    Main.main.removeChild(Main.main.getChildByName("dls"));
				if (Main.main.getChildByName("buyScreen"))
					Main.main.removeChild(Main.main.getChildByName("buyScreen"));

				var popup:PopupOK = new PopupOK();
				popup.screen.lblName.text = "Оформление заказа";
				popup.screen.lblMessage.text = responseParams.getUtfString("message");
				popup.screen.btnOK.addEventListener(MouseEvent.CLICK, btnOKClick);
				popup.name = "popupOK";
				Main.main.addChild(popup);

				function btnOKClick(event:MouseEvent):void
				{
					Main.main.removeChild(Main.main.getChildByName("popupOK"));
				}
				
			    this.navigationPanel.lblRegular.text = Main.sfs.mySelf.getVariable("balance_regular").getIntValue().toString();
			    this.navigationPanel.lblDonate.text = Main.sfs.mySelf.getVariable("balance_donate").getIntValue().toString();
			}

			if (responseParams.containsKey("catalog"))
			{
				_catalog.catalog = responseParams.getSFSArray("catalog");
				_catalog._catalog = responseParams.getSFSArray("catalog");
				_catalog.search(null);
			}
		}
	}
	
}
