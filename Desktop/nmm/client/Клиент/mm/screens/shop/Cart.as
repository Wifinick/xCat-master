package mm.screens.shop
{

	import flash.display.MovieClip;
	import flash.display.BlendMode;
	import com.smartfoxserver.v2.entities.data.ISFSArray;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import mm.screens.shop.CartItem;
	import mm.ScrollBar;
	import mm.Main;
	import mm.screens.ShopScreen;
	import flash.events.MouseEvent;
	import mm.screens.ShopScreen;
	import mm.screens.shop.Catalog;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	import com.smartfoxserver.v2.requests.ExtensionRequest;

	public class Cart extends MovieClip
	{

		public var items:ISFSArray = new SFSArray();
		private var scrollBar;
		public var shop:String;

		public function Cart()
		{
			this.blendMode = BlendMode.LAYER;
			this.visible = false;

			scrollbar.area.slider.stop();
			scrollbar.mouseEnabled = false;

			this.orderBtn.addEventListener(MouseEvent.CLICK, order);

			this.regular_price.text = "0";
			this.donate_price.text = "0";
		}

		private function order(e:MouseEvent):void
		{
			var orderBalanceRegular:int = int(this.regular_price.text);
			var orderBalanceDonate:int = int(this.donate_price.text);
			if(orderBalanceDonate == 0 && orderBalanceRegular == 0)
			  return;
			  
			if ((orderBalanceDonate != 0 && Main.sfs.mySelf.getVariable("balance_donate").getIntValue() < orderBalanceDonate) ||
			  (orderBalanceRegular != 0 && Main.sfs.mySelf.getVariable("balance_regular").getIntValue() < orderBalanceRegular))
			{

				var popup:PopupOK = new PopupOK();
				popup.screen.lblName.text = "Оформление заказа";
				popup.screen.lblMessage.text = "Недостаточно средств!";
				popup.screen.btnOK.addEventListener(MouseEvent.CLICK, btnOKClick);
				popup.name = "popupOK";
				Main.main.addChild(popup);

				function btnOKClick(event:MouseEvent):void
				{
					Main.main.removeChild(Main.main.getChildByName("popupOK"));
				}
				return;
			}

			var buyScreenMC:BuyScreen = new BuyScreen();

			buyScreenMC.name = "buyScreen";

			buyScreenMC.screen.lblName.text = "Оформление заказа";
			buyScreenMC.screen.lblMessage.text = "Сумма заказа: " + this.regular_price.text + " клубков и " + this.donate_price.text + " рыбок. Продолжить?";
			buyScreenMC.overlay.addEventListener(MouseEvent.CLICK, btnOverlayClick);
			buyScreenMC.screen.btnYes.addEventListener(MouseEvent.CLICK, btnYesClick);
			buyScreenMC.screen.btnNo.addEventListener(MouseEvent.CLICK, btnNoClick);

			function btnOverlayClick(event:MouseEvent):void
			{
				Main.main.removeChild(buyScreenMC);
			}

			function btnYesClick(event:MouseEvent):void
			{
				var items_ids:ISFSArray = new SFSArray();
				for (var i:int = 0; i < items.size(); i++)
				{
					items_ids.addInt(items.getSFSObject(i).getInt("id"));
				}

				var params:ISFSObject = new SFSObject();
				params.putSFSArray("wear", items_ids);

				Main.sfs.send(new ExtensionRequest(shop + ".order", params));

				var dataLoadingScreen:DataLoadingScreen = new DataLoadingScreen();
				dataLoadingScreen.name = "dls";
				Main.main.addChild(dataLoadingScreen);
			}

			function btnNoClick(event:MouseEvent):void
			{
				Main.main.removeChild(buyScreenMC);
			}

			Main.main.addChild(buyScreenMC);

		}

		public function addItem(item:ISFSObject):void
		{
			var check:Boolean = false;

			for (var i:int = 0; i < items.size(); i++)
			{
				if (items.getSFSObject(i).getInt("id") == item.getInt("id"))
				{
					check = true;
					break;
				}
			}

			if (! check)
			{
				items.addSFSObject(item);
				updateItems();
			}
		}

		public function removeItem(id:int):void
		{
			for (var i:int = 0; i < items.size(); i++)
			{
				if (items.getSFSObject(i).getInt("id") == id)
				{
					items.removeElementAt(i);
					updateItems();
					break;
				}
			}
		}

		public function updateItems():void
		{
			this.regular_price.text = "0";
			this.donate_price.text = "0";

			for (var i:int = field.content.numChildren - 1; i >= 0; i--)
			{
				var ci:CartItem = field.content.getChildAt(i) as CartItem;
				var check:Boolean = false;

				for (var j:int = 0; j < items.size(); j++)
				{
					if (items.getSFSObject(j).getInt("id").toString() == ci.name) // тут потом добавить чеккаунт (см в апдейтфурн)
					{
						check = true;
						break;
					}
				}

				if (! check)
				{
					ci.btnRemove.removeEventListener(MouseEvent.CLICK, ciBtnRemoveClick);

					field.content.removeChild(ci);

					if (field.content.x <= -40)
					{
						field.content.x +=  40;
					}
				}
			}

			var mod:int = 0;

			for (var i:int = 0; i < items.size(); i++)
			{
				if (items.getSFSObject(i).getInt("balance_type_id") == 1)
				{
					this.regular_price.text = (int(this.regular_price.text) + items.getSFSObject(i).getInt("price")).toString();
				}
				else
				{
					this.donate_price.text = (int(this.donate_price.text) + items.getSFSObject(i).getInt("price")).toString();

				}
				if (field.content.getChildByName(items.getSFSObject(i).getInt("id")))
				{
					var ci:CartItem = field.content.getChildByName(items.getSFSObject(i).getInt("id")) as CartItem;
					ci.y = mod * 40;
					field.content.setChildIndex(ci, 0);
				}
				else
				{
					var ci:CartItem = new CartItem(items.getSFSObject(i));
					ci.y = mod * 40;
					ci.btnRemove.addEventListener(MouseEvent.CLICK, ciBtnRemoveClick);
					ci.btnShow.addEventListener(MouseEvent.CLICK, btnViewClick);

					field.content.addChildAt(ci, 0);
				}

				mod++;
			}

			if (field.content.numChildren == 0)
			{
				lblEmpty.text = "Корзина пуста";
			}
			else
			{
				lblEmpty.text = "";

			}
			if (field.content.height > field.mask.height)
			{
				scrollbar.mouseEnabled = true;

				if (scrollBar)
				{
					scrollBar.destroy();
				}

				scrollBar = new ScrollBar(field,scrollbar,Main.main.stage,40);
			}

		}

		private function ciBtnRemoveClick(event:MouseEvent):void
		{
			removeItem(int(event.target.parent.name));
		}

		private function btnViewClick(event:MouseEvent):void
		{
			var ci:CartItem = field.content.getChildByName(event.target.parent.name) as CartItem;

			for (var j:int = 0; j < items.size(); j++)
			{
				if (items.getSFSObject(j).getInt("id").toString() == event.target.parent.name)
				{
					var shopScreen:ShopScreen = this.parent as ShopScreen;
					shopScreen.createView(items.getSFSObject(j));
					break;
				}
			}
		}

	}

}