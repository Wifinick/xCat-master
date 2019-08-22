package mm {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.text.*;
	import flash.geom.ColorTransform;
	import com.adobe.crypto.MD5;
	import com.smartfoxserver.v2.entities.*;
	import com.smartfoxserver.v2.entities.UserPrivileges;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	import com.smartfoxserver.v2.requests.*;
	import com.smartfoxserver.v2.entities.data.ISFSArray;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	import com.hurlant.crypto.symmetric.NullPad;
	import com.smartfoxserver.v2.requests.buddylist.AddBuddyRequest;
	import com.smartfoxserver.v2.requests.buddylist.RemoveBuddyRequest;
	import com.smartfoxserver.v2.core.SFSEvent;
	
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.greensock.plugins.TweenPlugin; 
	import com.greensock.plugins.VisiblePlugin;
	
	import mm.entities.Avatar;
	
	public class ProfileScreenUtils {
		
		private static var profileScreen:ProfileScreen;
		private static var profileParams:SFSObject;
		private static var inventoryParams:SFSObject;
		public static var saveInventoryParams:SFSObject;
		private static var backgroundsParams:SFSObject;
		private static var housesParams:SFSObject;
		private static var avatar:Avatar;
		private static var wear:Object;
		private static var select_background:Object;
		private static var invent:ISFSArray;
		private static var backgrounds:ISFSArray;
		private static var houses:ISFSArray;
		private static var houseStatus;
		private static var i;
		
		public function ProfileScreenUtils() {
			super();
		}
		
		public static function init(params:SFSObject):void
		{
			trace("Профиль", params.getUtfString("name"));
			
			// удаление открытого профиля при повторном открытии
			if(profileScreen)
				if(Main.main.contains(profileScreen))
					Main.main.removeChild(profileScreen);
			
			profileScreen = new ProfileScreen();
			
			wear = new Object();
			avatar = null;
			select_background = new Object();
			
			profileParams = null;
			inventoryParams = null;
			backgroundsParams = null;
			housesParams = null;
			houseStatus = null;
			
			// включение/выключение кнопки редактора аватара
			if(params.getUtfString("name") == Main.sfs.mySelf.name)
			{
				profileScreen.screen.btnInfo.visible = true;
				profileScreen.screen.btnInventory.visible = true;
				profileScreen.screen.btnBackgrounds.visible = true;
				
				profileScreen.screen.btnInfo.addEventListener(MouseEvent.CLICK, btnInfoClick);
				profileScreen.screen.btnInventory.addEventListener(MouseEvent.CLICK, btnInventoryClick);
				profileScreen.screen.btnBackgrounds.addEventListener(MouseEvent.CLICK, btnBackgroundsClick);
				profileScreen.screen.btnHouses.addEventListener(MouseEvent.CLICK, btnHousesClick);
			}
			else
			{
				profileScreen.screen.btnInfo.visible = false;
				profileScreen.screen.btnInventory.visible = false;
				profileScreen.screen.btnBackgrounds.visible = false;
			}
			
			// остальные события
			profileScreen.overlay.addEventListener(MouseEvent.CLICK, overlayClick);
			
			info(params);
		}
		
		private static function info(params:SFSObject = null):void
		{
			trace("Профиль: информация");
			
			if(params)
			{
				profileParams = params;
			}
			
			profileScreen.screen.gotoAndStop(1);
			
			trace('friend_status', profileParams.getInt("friend_status"));
			
			
			// друзья
			var friendStatus = profileParams.getInt("friend_status");
			
			if(Main.sfs.userManager.containsUserName(profileParams.getUtfString("name")))
			{
				if(! Main.sfs.userManager.getUserByName(profileParams.getUtfString("name")).isItMe)
				{
					if(friendStatus == 2)
					{
						profileScreen.screen.btnRemoveFriend.visible = true;
						profileScreen.screen.btnRemoveFriend.addEventListener(MouseEvent.CLICK, btnRemoveFriendClick);
					}
					else if(friendStatus == 1)
					{
						profileScreen.screen.btnApproveFriend.visible = true;
						profileScreen.screen.btnApproveFriend.addEventListener(MouseEvent.CLICK, btnApproveFriendClick);
					}
					else if(Main.sfs.buddyManager.containsBuddy(params.getUtfString("name")))
					{
						profileScreen.screen.btnCancelFriend.visible = true;
						profileScreen.screen.btnCancelFriend.addEventListener(MouseEvent.CLICK, btnCancelFriendClick);
					}
					else
					{
						if(!(Main.sfs.mySelf.privilegeId < 2 && profileParams.getInt("permission") >= 2))
						{
							profileScreen.screen.btnAddFriend.addEventListener(MouseEvent.CLICK, btnAddFriendClick);
							profileScreen.screen.btnAddFriend.visible = true;
						}
					}
					
				}
			}
			else
			{
				if(friendStatus == 2)
				{
					profileScreen.screen.btnRemoveFriend.visible = true;
					profileScreen.screen.btnRemoveFriend.addEventListener(MouseEvent.CLICK, btnRemoveFriendClick);
				}
				else if(friendStatus == 1)
				{
					profileScreen.screen.btnApproveFriend.visible = true;
					profileScreen.screen.btnApproveFriend.addEventListener(MouseEvent.CLICK, btnApproveFriendClick);
				}
				else if(Main.sfs.buddyManager.containsBuddy(params.getUtfString("name")))
				{
					profileScreen.screen.btnCancelFriend.visible = true;
					profileScreen.screen.btnCancelFriend.addEventListener(MouseEvent.CLICK, btnCancelFriendClick);
				}
				else
				{
					if(!(Main.sfs.mySelf.privilegeId < 2 && profileParams.getInt("permission") >= 2))
					{
						profileScreen.screen.btnAddFriend.addEventListener(MouseEvent.CLICK, btnAddFriendClick);
						profileScreen.screen.btnAddFriend.visible = true;
					}
				}
			}
			
			//дом
			
			houseStatus = profileParams.getInt("house_status");
			
			if(profileParams.getUtfString("name") != Main.sfs.mySelf.name)
			{
				if(Main.sfs.mySelf.isModerator() || Main.sfs.mySelf.isAdmin())
				{
					profileScreen.screen.btnHouses.addEventListener(MouseEvent.CLICK, btnEnterHouseClick);
				}
				else if(houseStatus == 3 || (houseStatus == 2 && friendStatus == 2))
				{
					profileScreen.screen.btnHouses.addEventListener(MouseEvent.CLICK, btnEnterHouseClick);
				}
				else
					profileScreen.screen.btnHouses.visible = false;
			}
			
			// обновление аватара при повторном открытии
			if(avatar != null)
			{
				profileScreen.screen.mcAvatar.removeChild(avatar);
				wear = new Object();
				select_background = new Object();
			}
			
			select_background.id = profileParams.getInt("background");
			
			// загрузка фона
			if(profileParams.getInt("background") != 0)
			{
				var backgroundRequest:URLRequest = new URLRequest('https://playxcat.ru/gameres/e850f8eeae83947d989e289d94a012d4/' + MD5.hash("background_" + profileParams.getInt("background")) + ".swf?v" + Math.random());
				var backgroundLoader:Loader = new Loader();
				backgroundLoader.load(backgroundRequest);
				backgroundLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, backgroundLoadComplete);
				
				function backgroundLoadComplete(event:Event):void
				{
					event.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, backgroundLoadComplete);
					
					select_background.mc = event.target.loader.content.background;
					
					profileScreen.screen.mcAvatar.mcBackground.addChild(select_background.mc);
				}
			}
			
			// загрузка одежды
			for(i = 1; i < 6; i++)
			{
				wear[i] = new Object();
				if(profileParams.getInt("wear_" + i.toString()) != 0)
				{
					wear[i].id = profileParams.getInt("wear_" + i.toString());
					var request:URLRequest = new URLRequest('https://playxcat.ru/gameres/ff07673105bd3e6790eaec3b1d9deb88/' + MD5.hash("wear_" + profileParams.getInt("wear_" + i.toString())) + ".swf?v" + Math.random());
					var loader:Loader = new Loader();
					loader.name = i;
					loader.load(request);
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
					
					function loadComplete(event:Event):void
					{
						event.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
						
						wear[event.target.loader.name].mc = event.target.loader.content.wear;
						
						// сортировка одежды
						for(i = 5; i > 0; i--)
						{
							if(wear[i].mc != null)
							{
								var mcWear:MovieClip = wear[i].mc;
								mcWear.gotoAndStop("S");
								avatar.avatar.addChild(mcWear);
							}
						}
					}
				}
				else
				{
					wear[i].mc = null;
					wear[i].id = 0;
				}
			}
			
			// настройки аватара для профиля
			avatar = new Avatar(0, "", profileParams.getUtfString("avatar_color"));
			avatar.avatar.gotoAndStop("S");
			avatar.avatar.x = 125;
			avatar.avatar.y = 150;
			avatar.avatar.scaleX = 1.25;
			avatar.avatar.scaleY = 1.25;
			
			// цвет аватара
			/*if(profileParams.getUtfString("avatar_color") == "rainbow")
			{
				Main.main.addEventListener(Event.ENTER_FRAME, colorEnterFrame);
			}
			else
			{
				var colorTrans = new ColorTransform();
				colorTrans.color = profileParams.getUtfString("avatar_color");
				avatar.avatar.character.background.transform.colorTransform = colorTrans;
			}*/

			profileScreen.screen.mcAvatar.addChild(avatar);
			
			// отображение информации об игроке
			var txtStatus;
			var txtGroup = "";
			if(profileParams.containsKey("location"))
			{
				var locNameRus:String = Main.sfs.getRoomByName(profileParams.getUtfString("location")).getVariable("name_ru").getStringValue();
				
				txtStatus = profileParams.getUtfString("online") + "\n\nЛокация: " + locNameRus;
			}
			else
			{
				txtStatus = profileParams.getUtfString("online");
			}
			
			switch(profileParams.getUtfString("name"))
			{
				case "Wifi": txtGroup = "Администратор игры"; break;
				case "Xset": txtGroup = "Администратор игры"; break;
				case "Kurochkin": txtGroup = "Администратор игры"; break;
				case "Phoenix": txtGroup = "Администратор игры"; break;				
				case "Кcaвье": txtGroup = "Гл. модератор игры"; break;
				case "Wine": txtGroup = "Модератор игры"; break;
				case "Queelstextue": txtGroup = "Модератор игры"; break;
				case "Aimee": txtGroup = "Модератор игры"; break;
				case "Коэпио": txtGroup = "Модератор игры"; break;
				case "p1xel": txtGroup = "Модератор игры"; break;				
				case "Shadepig54": txtGroup = "Художник игры"; break;
			}
			
			var uip:String = "";
			if(Main.sfs.mySelf.isModerator() || Main.sfs.mySelf.isAdmin())
				uip = "\nIP: " + profileParams.getUtfString("ip");
			
			profileScreen.screen.lblName.text = profileParams.getUtfString("name");
			profileScreen.screen.txtInfo.text = "Статус: " + txtStatus + "\n\nРегистрация: \n" + profileParams.getUtfString("reg_date") + 
			"\n\nДень рождения: \n" + profileParams.getUtfString("birthday") + "\n\n" + txtGroup + uip;
			
			// кнопка блокировки
			if((Main.sfs.mySelf.isModerator() || Main.sfs.mySelf.isAdmin()) && profileParams.getUtfString("name") != Main.sfs.mySelf.name)
			{
				profileScreen.screen.btnReport.visible = true;
				
				profileScreen.screen.btnReport.addEventListener(MouseEvent.CLICK, btnReportClick);
			}
			
			// проверка, загружается ли страница в первый раз
			if(!Main.main.contains(profileScreen))
			{
				Main.main.removeChild(Main.main.getChildByName("dls"));
				Main.main.addChild(profileScreen);
			}
		}
		
		public static function inventory(params:SFSObject = null):void
		{
			trace("Профиль: одежда");
			
			if(params)
			{
				inventoryParams = params;
			}
			
			profileScreen.screen.gotoAndStop("info"); //сброс
			profileScreen.screen.gotoAndStop("inventory");
			
			// снятие одежды по клику
			for(i = 1; i < 6; i++)
			{
				if(wear[i].mc)
				{
					wear[i].mc.buttonMode = true;
					wear[i].mc.addEventListener(MouseEvent.CLICK, mcAvatarWearClick);
				}
			}
			
			var scr = profileScreen.screen;
			
			var cmbSort = scr.cmbSort;
			
			var cmbSortList = scr.cmbSortList.list;
			
			cmbSort.btnList.stop();
			cmbSort.btnList.mouseChildren = false;
			cmbSort.btnList.buttonMode = true;
			cmbSort.btnList.tabEnabled = false;
			cmbSortList.y = -204;
			cmbSortList.visible = false;
			cmbSort.btnList.addEventListener(MouseEvent.CLICK, cmbSortBtnListClick);
			
			if(inventoryParams.getUtfString("sort"))
			{
				cmbSort.btnList.lblName.text = inventoryParams.getUtfString("sort");
				cmbSortList.y = 34;
				cmbSortList.visible = true;
				TweenLite.to(cmbSortList, 0.2, {y:"-238", visible:false});
				trace('елда');
			}
			
			function cmbSortBtnListClick(event:MouseEvent)
			{
				if(cmbSortList.visible)
				{
					TweenLite.to(cmbSortList, 0.2, {y:"-238", visible:false});
				}
				else
				{
					TweenLite.fromTo(cmbSortList, 0.2, {visible:true}, {y:"238"});
				}
			}
			
			cmbSortList.btn1.addEventListener(MouseEvent.CLICK, cmbSortListBtn1Click);
			cmbSortList.btn2.addEventListener(MouseEvent.CLICK, cmbSortListBtn2Click);
			cmbSortList.btn3.addEventListener(MouseEvent.CLICK, cmbSortListBtn3Click);
			cmbSortList.btn4.addEventListener(MouseEvent.CLICK, cmbSortListBtn4Click);
			cmbSortList.btn5.addEventListener(MouseEvent.CLICK, cmbSortListBtn5Click);
			cmbSortList.btn6.addEventListener(MouseEvent.CLICK, cmbSortListBtn6Click);
			
			function cmbSortListBtn1Click(event:MouseEvent)
			{
				var sfsObj:SFSObject = saveInventoryParams as SFSObject;
				
				sfsObj.putUtfString("sort", "Все вещи");
				
				inventory(sfsObj);
			}
			
			function cmbSortListBtn2Click(event:MouseEvent)
			{
				var arr:SFSArray = saveInventoryParams.getSFSArray("inventory") as SFSArray;
				var newarr:SFSArray = new SFSArray();
				
				for(var i:int; i < arr.size(); i++)
					if(arr.getSFSObject(i).getInt("type") == 1)
						newarr.addSFSObject(arr.getSFSObject(i));
				
				var sfsObj:SFSObject = new SFSObject();
				sfsObj.putSFSArray("inventory", newarr);
				sfsObj.putUtfString("sort", "Аксессуары");
				
				inventory(sfsObj);
			}
			
			function cmbSortListBtn3Click(event:MouseEvent)
			{
				var arr:SFSArray = saveInventoryParams.getSFSArray("inventory") as SFSArray;
				var newarr:SFSArray = new SFSArray();
				
				for(var i:int; i < arr.size(); i++)
					if(arr.getSFSObject(i).getInt("type") == 2)
						newarr.addSFSObject(arr.getSFSObject(i));
				
				var sfsObj:SFSObject = new SFSObject();
				sfsObj.putSFSArray("inventory", newarr);
				sfsObj.putUtfString("sort", "Головные уборы");
				
				inventory(sfsObj);
			}
			
			function cmbSortListBtn4Click(event:MouseEvent)
			{
				var arr:SFSArray = saveInventoryParams.getSFSArray("inventory") as SFSArray;
				var newarr:SFSArray = new SFSArray();
				
				for(var i:int; i < arr.size(); i++)
					if(arr.getSFSObject(i).getInt("type") == 3)
						newarr.addSFSObject(arr.getSFSObject(i));
				
				var sfsObj:SFSObject = new SFSObject();
				sfsObj.putSFSArray("inventory", newarr);
				sfsObj.putUtfString("sort", "Верхняя одежда");
				
				inventory(sfsObj);
			}
			
			function cmbSortListBtn5Click(event:MouseEvent)
			{
				var arr:SFSArray = saveInventoryParams.getSFSArray("inventory") as SFSArray;
				var newarr:SFSArray = new SFSArray();
				
				for(var i:int; i < arr.size(); i++)
					if(arr.getSFSObject(i).getInt("type") == 4)
						newarr.addSFSObject(arr.getSFSObject(i));
				
				var sfsObj:SFSObject = new SFSObject();
				sfsObj.putSFSArray("inventory", newarr);
				sfsObj.putUtfString("sort", "Штаны");
				
				inventory(sfsObj);
			}
			
			function cmbSortListBtn6Click(event:MouseEvent)
			{
				var arr:SFSArray = saveInventoryParams.getSFSArray("inventory") as SFSArray;
				var newarr:SFSArray = new SFSArray();
				
				for(var i:int; i < arr.size(); i++)
					if(arr.getSFSObject(i).getInt("type") == 5)
						newarr.addSFSObject(arr.getSFSObject(i));
				
				var sfsObj:SFSObject = new SFSObject();
				sfsObj.putSFSArray("inventory", newarr);
				sfsObj.putUtfString("sort", "Очки");
				
				inventory(sfsObj);
			}
			
			
			profileScreen.screen.btnSave.addEventListener(MouseEvent.CLICK, btnSaveClick);
			profileScreen.screen.btnCancel.addEventListener(MouseEvent.CLICK, btnCancelClick);
			profileScreen.screen.btnNext.addEventListener(MouseEvent.CLICK, btnNextClick);
			profileScreen.screen.btnPrev.addEventListener(MouseEvent.CLICK, btnPrevClick);
			
			profileScreen.screen.btnNext.visible = false
			profileScreen.screen.btnPrev.visible = false;
			
			invent = inventoryParams.getSFSArray("inventory");
			
			var itemX = 0, itemY = 0;
			
			for(i = 0; i < invent.size(); i++)
			{
				var item:InventoryItem = new InventoryItem();
				item.name = "item_" + i;
				item.addEventListener(MouseEvent.MOUSE_OVER, itemMouseOver);
				item.addEventListener(MouseEvent.MOUSE_OUT, itemMouseOut);
				item.addEventListener(MouseEvent.CLICK, inventoryItemClick);
				item.buttonMode = true;
				item.stop();
				item.x = itemX;
				item.y = itemY;
				item.mouseChildren = false;
				
				// перенос кнопок на следующую строку
				if(itemX + 70 > 270)
				{
					itemX = 0;
					itemY += 70;
				}
				else
				{
					itemX += 70;
				}
				
				var request:URLRequest = new URLRequest('https://playxcat.ru/gameres/ff07673105bd3e6790eaec3b1d9deb88/' + MD5.hash("wear_" + invent.getSFSObject(i).getInt("wear_id").toString()) + ".swf?v" + Math.random());
				var loader = new Loader();
				loader.name = i;
				loader.load(request);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
				
				function loadComplete(event:Event):void
				{
					event.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
					
					if(profileScreen.screen.currentLabel == "inventory")
					{
						var inventId = event.target.loader.name;
						var wearItem:MovieClip = event.target.loader.content.item;
						
						wearItem.x = 0;
						wearItem.y = 0;
						
						// удаление иконки загрузки
						var dla:MovieClip = profileScreen.screen.inventoryList.items.getChildByName("item_" + inventId).icon.getChildByName("dla");
						profileScreen.screen.inventoryList.items.getChildByName("item_" + inventId).icon.removeChild(dla);
						
						profileScreen.screen.inventoryList.items.getChildByName("item_" + inventId).icon.addChild(wearItem);
					}
				}
				
				var itemLabel = new InventoryItemLabel;
				itemLabel.name = "itemLabel_" + i;
				itemLabel.txtLabel.text = invent.getSFSObject(i).getUtfString("name");
				itemLabel.txtLabel.autoSize = TextFieldAutoSize.LEFT;
				itemLabel.background.width = itemLabel.txtLabel.width;
				itemLabel.x = item.x + item.width / 2 - itemLabel.background.width / 2;
				itemLabel.y = item.y - 30;
				itemLabel.visible = false;
				
				// добавление иконки загрузки
				var dla:DataLoadingAnim = new DataLoadingAnim();
				dla.name = "dla";
				dla.scaleX = 0.3;
				dla.scaleY = 0.3;
				item.icon.addChild(dla);
				
				profileScreen.screen.inventoryList.items.addChild(item);
				profileScreen.screen.inventoryList.labels.addChild(itemLabel);
			}
			
			if(profileScreen.screen.inventoryList.items.height > 270)
			{
				profileScreen.screen.btnNext.visible = true;
			}
			
			var pageNum:Number = 1;
			var pageCount:Number;
			
			if(profileScreen.screen.inventoryList.items.height > 270)
				pageCount =  Math.ceil((profileScreen.screen.inventoryList.items.height + 6) / 280);
			else
				pageCount = 1;
			
			profileScreen.screen.lblPage.text = pageNum + "/" + pageCount;
			
			function btnNextClick(event:MouseEvent)
			{
				profileScreen.screen.btnPrev.visible = true;
				profileScreen.screen.inventoryList.items.y -= 280;
				profileScreen.screen.inventoryList.labels.y -= 280;
				trace(profileScreen.screen.inventoryList.items.y, profileScreen.screen.inventoryList.items.height);
				if(profileScreen.screen.inventoryList.items.y * (-1) + 280 >= profileScreen.screen.inventoryList.items.height)
				{
					profileScreen.screen.btnNext.visible = false;
				}
				
				pageNum++;
				
				profileScreen.screen.lblPage.text = pageNum + "/" + pageCount;
			}
			
			function btnPrevClick(event:MouseEvent)
			{
				profileScreen.screen.btnNext.visible = true;
				profileScreen.screen.inventoryList.items.y += 280;
				profileScreen.screen.inventoryList.labels.y += 280;
				if(profileScreen.screen.inventoryList.items.y == 0)
				{
					profileScreen.screen.btnPrev.visible = false;
				}
				
				pageNum--;
				
				profileScreen.screen.lblPage.text = pageNum + "/" + pageCount;
			}
			
			function itemMouseOver(event:MouseEvent)
			{
				profileScreen.screen.inventoryList.labels.getChildByName("itemLabel_" + event.target.name.substr(5)).visible = true;
			}
			
			function itemMouseOut(event:MouseEvent)
			{
				profileScreen.screen.inventoryList.labels.getChildByName("itemLabel_" + event.target.name.substr(5)).visible = false;
			}
			
			function inventoryItemClick(event:MouseEvent)
			{
				var inventId = event.target.name.substr(5);
				
				mcAvatarChangeWear(inventId);
			}
			
			function mcAvatarWearClick(event:MouseEvent)
			{
				for(i = 1; i < 6; i++)
				{
					if(wear[i].mc == event.currentTarget)
					{
						wear[i].mc.removeEventListener(MouseEvent.CLICK, mcAvatarWearClick);
						avatar.avatar.removeChild(wear[i].mc);
						wear[i].id = 0;
						wear[i].mc = null;
					}
				}
			}
			
			function btnSaveClick(event:MouseEvent):void
			{
				var params:ISFSObject = new SFSObject();
				
				for(i = 5; i > 0; i--)
				{
					params.putInt("wear_" + i.toString(), wear[i].id);
				}
				
				Main.sfs.send(new ExtensionRequest("uservars_set.wear", params));
				
				Main.main.removeChild(profileScreen);
			}
			
			function btnCancelClick(event:MouseEvent):void
			{
				for(var i = 1; i < 6; i++)
				{
					if(profileParams.getInt("wear_" + i.toString()) != wear[i].id)
					{
						if(wear[i].id != 0)
						{
							avatar.avatar.removeChild(wear[i].mc);
							wear[i].id = 0;
							wear[i].mc = null;
						}
						
						if(profileParams.getInt("wear_" + i.toString()) != 0)
						{
							wear[i].id = profileParams.getInt("wear_" + i.toString());
							var request:URLRequest = new URLRequest('https://playxcat.ru/gameres/ff07673105bd3e6790eaec3b1d9deb88/' + MD5.hash("wear_" + profileParams.getInt("wear_" + i.toString())) + ".swf?v" + Math.random());
							var loader:Loader = new Loader();
							loader.name = i;
							loader.load(request);
							loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
							
							function loadComplete(event:Event):void
							{
								event.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
								
								wear[event.target.loader.name].mc = event.target.loader.content.wear;
								
								for(i = 5; i > 0; i--)
								{
									if(wear[i].mc != null)
									{
										wear[i].mc.gotoAndStop("S");
										wear[i].mc.buttonMode = true;
										wear[i].mc.addEventListener(MouseEvent.CLICK, mcAvatarWearClick);
										avatar.avatar.addChild(wear[i].mc);
									}
								}
							}
						}
						else
						{
							wear[i].mc = null;
							wear[i].id = 0;
						}
					}
				}
			}
			
			function mcAvatarChangeWear(inventId:Number)
			{
				var type:Number = invent.getSFSObject(inventId).getInt("type");
				
				if(wear[type].id == invent.getSFSObject(inventId).getInt("wear_id")) // проверка, надета ли вещь того же типа
				{
					avatar.avatar.removeChild(wear[type].mc);
					wear[type].id = 0
					wear[type].mc = null;
				}
				else
				{
					if(wear[type].mc != null)
					{
						avatar.avatar.removeChild(wear[type].mc);
					}
					
					wear[type].id = invent.getSFSObject(inventId).getInt("wear_id");
					
					var request:URLRequest = new URLRequest('https://playxcat.ru/gameres/ff07673105bd3e6790eaec3b1d9deb88/' + MD5.hash("wear_" + wear[type].id) + ".swf?v" + Math.random());
					var loader:Loader = new Loader();
					loader.name = type.toString();
					loader.load(request);
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
					
					function loadComplete(event:Event):void
					{
						event.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
						
						wear[event.target.loader.name].mc = event.target.loader.content.wear;
						
						for(i = 5; i > 0; i--)
						{
							if(wear[i].mc != null)
							{
								wear[i].mc.gotoAndStop("S");
								wear[i].mc.buttonMode = true;
								wear[i].mc.addEventListener(MouseEvent.CLICK, mcAvatarWearClick);
								avatar.avatar.addChild(wear[i].mc);
							}
						}
					}
				}

			}
		}
		
		public static function page_backgrounds(params:SFSObject = null):void
		{
			trace("Профиль: фоны");
			
			if(params)
			{
				backgroundsParams = params;
			}
			
			profileScreen.screen.gotoAndStop("backgrounds");
			
			profileScreen.screen.btnSave.addEventListener(MouseEvent.CLICK, btnSaveClick);
			profileScreen.screen.btnCancel.addEventListener(MouseEvent.CLICK, btnCancelClick);
			profileScreen.screen.btnNext.addEventListener(MouseEvent.CLICK, btnNextClick);
			profileScreen.screen.btnPrev.addEventListener(MouseEvent.CLICK, btnPrevClick);
			
			profileScreen.screen.btnNext.visible = false
			profileScreen.screen.btnPrev.visible = false;
			
			backgrounds = backgroundsParams.getSFSArray("backgrounds");
			
			var itemX = 0, itemY = 0;
			
			for(i = 0; i < backgrounds.size(); i++)
			{
				var item:InventoryItem = new InventoryItem();
				item.name = "item_" + i;
				item.addEventListener(MouseEvent.MOUSE_OVER, itemMouseOver);
				item.addEventListener(MouseEvent.MOUSE_OUT, itemMouseOut);
				item.addEventListener(MouseEvent.CLICK, inventoryItemClick);
				item.buttonMode = true;
				item.stop();
				item.x = itemX;
				item.y = itemY;
				item.mouseChildren = false;
				
				trace('itemh', item.height);
				
				// перенос кнопок на следующую строку
				if(itemX + 70 > 270)
				{
					itemX = 0;
					itemY += 70;
				}
				else
				{
					itemX += 70;
				}
				
				var request:URLRequest = new URLRequest('https://playxcat.ru/gameres/e850f8eeae83947d989e289d94a012d4/' + MD5.hash("background_" + backgrounds.getSFSObject(i).getInt("backgrounds_id").toString()) + ".swf?v" + Math.random());
				var loader:Loader = new Loader();
				loader.name = i;
				loader.load(request);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
				
				function loadComplete(event:Event):void
				{
					event.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
					
					if(profileScreen.screen.currentLabel == "backgrounds")
					{
						var backgroundId = event.target.loader.name;
						var backgroundItem:MovieClip = event.target.loader.content.item;
						
						backgroundItem.x = 0;
						backgroundItem.y = 0;
						
						// удаление иконки загрузки
						var dla:MovieClip = profileScreen.screen.inventoryList.items.getChildByName("item_" + backgroundId).icon.getChildByName("dla");
						profileScreen.screen.inventoryList.items.getChildByName("item_" + backgroundId).icon.removeChild(dla);
						
						profileScreen.screen.inventoryList.items.getChildByName("item_" + backgroundId).icon.addChild(backgroundItem);
					}
				}
				
				var itemLabel = new InventoryItemLabel;
				itemLabel.name = "itemLabel_" + i;
				itemLabel.txtLabel.text = backgrounds.getSFSObject(i).getUtfString("name");
				itemLabel.txtLabel.autoSize = TextFieldAutoSize.LEFT;
				itemLabel.background.width = itemLabel.txtLabel.width;
				itemLabel.x = item.x + item.width / 2 - itemLabel.background.width / 2;
				itemLabel.y = item.y - 30;
				itemLabel.visible = false;
				
				// добавление иконки загрузки
				var dla:DataLoadingAnim = new DataLoadingAnim();
				dla.name = "dla";
				dla.scaleX = 0.3;
				dla.scaleY = 0.3;
				item.icon.addChild(dla);
				
				profileScreen.screen.inventoryList.items.addChild(item);
				profileScreen.screen.inventoryList.labels.addChild(itemLabel);
			}
			
			if(profileScreen.screen.inventoryList.items.height > 275)
			{
				profileScreen.screen.btnNext.visible = true;
			}
			
			trace('хууууууууууууй', profileScreen.screen.inventoryList.items.height);
			
			var pageNum:Number = 1;
			var pageCount:Number;
			
			if(profileScreen.screen.inventoryList.items.height > 270)
				pageCount =  Math.ceil((profileScreen.screen.inventoryList.items.height + 6) / 280);
			else
				pageCount = 1;
			
			profileScreen.screen.lblPage.text = pageNum + "/" + pageCount;
			trace('хуй');
			
			function btnNextClick(event:MouseEvent)
			{
				profileScreen.screen.btnPrev.visible = true;
				profileScreen.screen.inventoryList.items.y -= 280;
				profileScreen.screen.inventoryList.labels.y -= 280;
				trace(profileScreen.screen.inventoryList.items.y, profileScreen.screen.inventoryList.items.height);
				if(profileScreen.screen.inventoryList.items.y * (-1) + 280 >= profileScreen.screen.inventoryList.items.height)
				{
					profileScreen.screen.btnNext.visible = false;
				}
				
				pageNum++;
				
				profileScreen.screen.lblPage.text = pageNum + "/" + pageCount;
			}
			
			function btnPrevClick(event:MouseEvent)
			{
				profileScreen.screen.btnNext.visible = true;
				profileScreen.screen.inventoryList.items.y += 280;
				profileScreen.screen.inventoryList.labels.y += 280;
				if(profileScreen.screen.inventoryList.items.y == 0)
				{
					profileScreen.screen.btnPrev.visible = false;
				}
				
				pageNum--;
				
				profileScreen.screen.lblPage.text = pageNum + "/" + pageCount;
			}
			
			function itemMouseOver(event:MouseEvent)
			{
				profileScreen.screen.inventoryList.labels.getChildByName("itemLabel_" + event.target.name.substr(5)).visible = true;
			}
			
			function itemMouseOut(event:MouseEvent)
			{
				profileScreen.screen.inventoryList.labels.getChildByName("itemLabel_" + event.target.name.substr(5)).visible = false;
			}
			
			function inventoryItemClick(event:MouseEvent)
			{
				var backgroundId = event.target.name.substr(5);
				
				mcBackgroundChange(backgroundId);
			}
			
			function btnSaveClick(event:MouseEvent):void
			{
				var params:ISFSObject = new SFSObject();
				
				params.putInt("background", select_background.id);
				
				Main.sfs.send(new ExtensionRequest("profile_update.background", params));
				
				Main.main.removeChild(profileScreen);
			}
			
			function btnCancelClick(event:MouseEvent):void
			{
				if(profileParams.getInt("background") != select_background.id)
				{
					if(select_background.id != 0)
					{
						profileScreen.screen.mcAvatar.mcBackground.removeChild(select_background.mc);
						select_background.id = 0
						select_background.mc = null;
					}
					
					if(profileParams.getInt("background") != 0)
					{
						select_background.id = profileParams.getInt("background");
						var request:URLRequest = new URLRequest('https://playxcat.ru/gameres/e850f8eeae83947d989e289d94a012d4/' + MD5.hash("background_" + profileParams.getInt("background")) + ".swf?v" + Math.random());
						var loader:Loader = new Loader();
						loader.load(request);
						loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
						
						function loadComplete(event:Event):void
						{
							event.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
							
							select_background.mc = event.target.loader.content.background;
							
							profileScreen.screen.mcAvatar.mcBackground.addChild(select_background.mc);
						}
					}
					else
					{
						select_background.mc = null;
						select_background.id = 0;
					}
				}
			}
			
			function mcBackgroundChange(backgroundId:Number)
			{
				
				if(select_background.id == backgrounds.getSFSObject(backgroundId).getInt("backgrounds_id")) // проверка, надета ли вещь того же типа
				{
					profileScreen.screen.mcAvatar.mcBackground.removeChild(select_background.mc);
					select_background.id = 0
					select_background.mc = null;
				}
				else
				{
					if(select_background.mc != null)
					{
						profileScreen.screen.mcAvatar.mcBackground.removeChild(select_background.mc);
					}
					
					select_background.id = backgrounds.getSFSObject(backgroundId).getInt("backgrounds_id");
					
					var request:URLRequest = new URLRequest('https://playxcat.ru/gameres/e850f8eeae83947d989e289d94a012d4/' + MD5.hash("background_" + select_background.id) + ".swf?v" + Math.random());
					var loader:Loader = new Loader();
					loader.load(request);
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
					
					function loadComplete(event:Event):void
					{
						event.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
						
						select_background.mc = event.target.loader.content.background;

						profileScreen.screen.mcAvatar.mcBackground.addChild(select_background.mc);
					}
				}

			}
		}
		
		public static function page_houses(params:SFSObject = null):void
		{
			trace("Профиль: домики");
			
			if(params)
			{
				housesParams = params;
			}
			
			if(Main.main.getChildByName("dls"))
		   	{
				Main.main.removeChild(Main.main.getChildByName("dls"));
		   	}
			
			profileScreen.screen.gotoAndStop("houses");
			
			profileScreen.screen.btnStatusMe.visible = false;
			profileScreen.screen.btnStatusFriends.visible = false;
			profileScreen.screen.btnStatusAll.visible = false;
			
			if(houseStatus == 1)
			{
				profileScreen.screen.btnStatusMe.visible = true;
				profileScreen.screen.btnStatusMe.addEventListener(MouseEvent.CLICK, btnStatusMeClick);
			}
			else if(houseStatus == 2)
			{
				profileScreen.screen.btnStatusFriends.visible = true;
				profileScreen.screen.btnStatusFriends.addEventListener(MouseEvent.CLICK, btnStatusFriendsClick);
			}
			else if(houseStatus == 3)
			{
				profileScreen.screen.btnStatusAll.visible = true;
				profileScreen.screen.btnStatusAll.addEventListener(MouseEvent.CLICK, btnStatusAllClick);
			}
			
			profileScreen.screen.btnEnterHouse.addEventListener(MouseEvent.CLICK, btnEnterHouseClick);
			
			profileScreen.screen.btnNext.addEventListener(MouseEvent.CLICK, btnNextClick);
			profileScreen.screen.btnPrev.addEventListener(MouseEvent.CLICK, btnPrevClick);
			
			profileScreen.screen.btnNext.visible = false
			profileScreen.screen.btnPrev.visible = false;
			
			houses = housesParams.getSFSArray("houses");
			
			var itemX = 0, itemY = 0;
			
			for(i = 0; i < houses.size(); i++)
			{
				var item:InventoryItem = new InventoryItem();
				item.name = "item_" + i;
				item.addEventListener(MouseEvent.MOUSE_OVER, itemMouseOver);
				item.addEventListener(MouseEvent.MOUSE_OUT, itemMouseOut);
				item.addEventListener(MouseEvent.CLICK, inventoryItemClick);
				item.buttonMode = true;
				item.stop();
				item.x = itemX;
				item.y = itemY;
				item.mouseChildren = false;
				
				/*if(houses.getSFSObject(i).getInt("active") == 1)
				{
					item.mcIsActive.visible = true;
				}*/
				
				// перенос кнопок на следующую строку
				if(itemX + 70 > 270)
				{
					itemX = 0;
					itemY += 70;
				}
				else
				{
					itemX += 70;
				}
				
				var request:URLRequest = new URLRequest('https://playxcat.ru/gameres/789406d01073ca1782d86293dcfc0764/' + MD5.hash("icon_" + houses.getSFSObject(i).getInt("houses_id").toString()) + ".swf?v" + Math.random());
				var loader:Loader = new Loader();
				loader.name = i;
				loader.load(request);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
				
				function loadComplete(event:Event):void
				{
					event.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
					
					if(profileScreen.screen.currentLabel == "houses")
					{
						var housesId = event.target.loader.name;
						var housesItem:MovieClip = event.target.loader.content.item;
						
						housesItem.x = 0;
						housesItem.y = 0;
						
						// удаление иконки загрузки
						var dla:MovieClip = profileScreen.screen.inventoryList.items.getChildByName("item_" + housesId).icon.getChildByName("dla");
						profileScreen.screen.inventoryList.items.getChildByName("item_" + housesId).icon.removeChild(dla);
						
						profileScreen.screen.inventoryList.items.getChildByName("item_" + housesId).icon.addChild(housesItem);
					}
				}
				
				var itemLabel = new InventoryItemLabel;
				itemLabel.name = "itemLabel_" + i;
				itemLabel.txtLabel.text = houses.getSFSObject(i).getUtfString("name");
				itemLabel.txtLabel.autoSize = TextFieldAutoSize.LEFT;
				itemLabel.background.width = itemLabel.txtLabel.width;
				itemLabel.x = item.x + item.width / 2 - itemLabel.background.width / 2;
				itemLabel.y = item.y - 30;
				itemLabel.visible = false;
				
				// добавление иконки загрузки
				var dla:DataLoadingAnim = new DataLoadingAnim();
				dla.name = "dla";
				dla.scaleX = 0.3;
				dla.scaleY = 0.3;
				item.icon.addChild(dla);
				
				profileScreen.screen.inventoryList.items.addChild(item);
				profileScreen.screen.inventoryList.labels.addChild(itemLabel);
			}
			
			if(profileScreen.screen.inventoryList.items.height > 270)
			{
				profileScreen.screen.btnNext.visible = true;
			}
			
			var pageNum:Number = 1;
			var pageCount:Number;
			
			if(profileScreen.screen.inventoryList.items.height > 270)
				pageCount =  Math.ceil((profileScreen.screen.inventoryList.items.height + 6) / 280);
			else
				pageCount = 1;
			
			profileScreen.screen.lblPage.text = pageNum + "/" + pageCount;
			trace('хуй');
			
			function btnNextClick(event:MouseEvent)
			{
				profileScreen.screen.btnPrev.visible = true;
				profileScreen.screen.inventoryList.items.y -= 280;
				profileScreen.screen.inventoryList.labels.y -= 280;
				trace(profileScreen.screen.inventoryList.items.y, profileScreen.screen.inventoryList.items.height);
				if(profileScreen.screen.inventoryList.items.y * (-1) + 280 >= profileScreen.screen.inventoryList.items.height)
				{
					profileScreen.screen.btnNext.visible = false;
				}
				
				pageNum++;
				
				profileScreen.screen.lblPage.text = pageNum + "/" + pageCount;
			}
			
			function btnPrevClick(event:MouseEvent)
			{
				profileScreen.screen.btnNext.visible = true;
				profileScreen.screen.inventoryList.items.y += 280;
				profileScreen.screen.inventoryList.labels.y += 280;
				if(profileScreen.screen.inventoryList.items.y == 0)
				{
					profileScreen.screen.btnPrev.visible = false;
				}
				
				pageNum--;
				
				profileScreen.screen.lblPage.text = pageNum + "/" + pageCount;
			}
			
			function itemMouseOver(event:MouseEvent)
			{
				profileScreen.screen.inventoryList.labels.getChildByName("itemLabel_" + event.target.name.substr(5)).visible = true;
			}
			
			function itemMouseOut(event:MouseEvent)
			{
				profileScreen.screen.inventoryList.labels.getChildByName("itemLabel_" + event.target.name.substr(5)).visible = false;
			}
			
			function inventoryItemClick(event:MouseEvent)
			{
				// TODO
				
				/*var housesId = event.target.name.substr(5);
				
				ActiveHouseChange(housesId);*/
			}
			
			/*function btnSaveClick(event:MouseEvent):void
			{
				var params:ISFSObject = new SFSObject();
				
				params.putInt("background", select_background.id);
				
				Main.sfs.send(new ExtensionRequest("profile_update.background", params));
				
				Main.main.removeEventListener(Event.ENTER_FRAME, colorEnterFrame);
				Main.main.removeChild(profileScreen);
			}
			
			function btnCancelClick(event:MouseEvent):void
			{
				if(profileParams.getInt("background") != select_background.id)
				{
					if(select_background.id != 0)
					{
						profileScreen.screen.mcAvatar.mcBackground.removeChild(select_background.mc);
						select_background.id = 0
						select_background.mc = null;
					}
					
					if(profileParams.getInt("background") != 0)
					{
						select_background.id = profileParams.getInt("background");
						var request:URLRequest = new URLRequest('https://playxcat.ru/gameres/e850f8eeae83947d989e289d94a012d4/' + MD5.hash("background_" + profileParams.getInt("background")) + ".swf?v" + Math.random());
						var loader:Loader = new Loader();
						loader.load(request);
						loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
						
						function loadComplete(event:Event):void
						{
							event.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
							
							select_background.mc = event.target.loader.content.background;
							
							profileScreen.screen.mcAvatar.mcBackground.addChild(select_background.mc);
						}
					}
					else
					{
						select_background.mc = null;
						select_background.id = 0;
					}
				}
			}
			
			function mcBackgroundChange(backgroundId:Number)
			{
				
				if(select_background.id == backgrounds.getSFSObject(backgroundId).getInt("backgrounds_id")) // проверка, надета ли вещь того же типа
				{
					profileScreen.screen.mcAvatar.mcBackground.removeChild(select_background.mc);
					select_background.id = 0
					select_background.mc = null;
				}
				else
				{
					if(select_background.mc != null)
					{
						profileScreen.screen.mcAvatar.mcBackground.removeChild(select_background.mc);
					}
					
					select_background.id = backgrounds.getSFSObject(backgroundId).getInt("backgrounds_id");
					
					var request:URLRequest = new URLRequest('https://playxcat.ru/gameres/e850f8eeae83947d989e289d94a012d4/' + MD5.hash("background_" + select_background.id) + ".swf?v" + Math.random());
					var loader:Loader = new Loader();
					loader.load(request);
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
					
					function loadComplete(event:Event):void
					{
						event.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
						
						select_background.mc = event.target.loader.content.background;

						profileScreen.screen.mcAvatar.mcBackground.addChild(select_background.mc);
					}
				}

			}*/
			
			function btnStatusMeClick(event:MouseEvent):void
			{
				changeHouseStatus(2);
				
				profileScreen.screen.btnStatusMe.removeEventListener(MouseEvent.CLICK, btnStatusMeClick);
				profileScreen.screen.btnStatusMe.visible = false;
				
				profileScreen.screen.btnStatusFriends.addEventListener(MouseEvent.CLICK, btnStatusFriendsClick);
				profileScreen.screen.btnStatusFriends.visible = true;
			}
			
			function btnStatusFriendsClick(event:MouseEvent):void
			{
				changeHouseStatus(3);
				
				profileScreen.screen.btnStatusFriends.removeEventListener(MouseEvent.CLICK, btnStatusFriendsClick);
				profileScreen.screen.btnStatusFriends.visible = false;
				
				profileScreen.screen.btnStatusAll.addEventListener(MouseEvent.CLICK, btnStatusAllClick);
				profileScreen.screen.btnStatusAll.visible = true;
			}
			
			function btnStatusAllClick(event:MouseEvent):void
			{
				changeHouseStatus(1);
				
				profileScreen.screen.btnStatusAll.removeEventListener(MouseEvent.CLICK, btnStatusAllClick);
				profileScreen.screen.btnStatusAll.visible = false;
				
				profileScreen.screen.btnStatusMe.addEventListener(MouseEvent.CLICK, btnStatusMeClick);
				profileScreen.screen.btnStatusMe.visible = true;
			}
			
			function changeHouseStatus(st:Number):void
			{
				var params:ISFSObject = new SFSObject();
				
				params.putInt("house_status", st);
				
				Main.sfs.send(new ExtensionRequest("profile_update.house_status", params));
			}
		}
		
		private static function btnAddFriendClick(event:MouseEvent):void
		{
			Main.sfs.send(new AddBuddyRequest(profileParams.getUtfString("name")));
			
			profileScreen.screen.btnAddFriend.removeEventListener(MouseEvent.CLICK, btnAddFriendClick);
			profileScreen.screen.btnAddFriend.visible = false;
			
			profileScreen.screen.btnCancelFriend.addEventListener(MouseEvent.CLICK, btnCancelFriendClick);
			profileScreen.screen.btnCancelFriend.visible = true;
		}
		
		private static function btnRemoveFriendClick(event:MouseEvent):void
		{
			var params:ISFSObject = new SFSObject();
			params.putUtfString("name", profileParams.getUtfString("name"));
			Main.sfs.send(new ExtensionRequest("friend_remove", params));
			
			profileScreen.screen.btnRemoveFriend.removeEventListener(MouseEvent.CLICK, btnRemoveFriendClick);
			profileScreen.screen.btnRemoveFriend.visible = false;
			
			profileScreen.screen.btnAddFriend.addEventListener(MouseEvent.CLICK, btnAddFriendClick);
			profileScreen.screen.btnAddFriend.visible = true;
			
			if(!(Main.sfs.mySelf.isModerator() || Main.sfs.mySelf.isAdmin()))
			{
				profileScreen.screen.btnHouses.visible = false;
			}
		}
		
		private static function btnApproveFriendClick(event:MouseEvent):void
		{
			Main.sfs.send(new AddBuddyRequest(profileParams.getUtfString("name")));
			
			profileScreen.screen.btnApproveFriend.removeEventListener(MouseEvent.CLICK, btnApproveFriendClick);
			profileScreen.screen.btnApproveFriend.visible = false;
			
			profileScreen.screen.btnRemoveFriend.addEventListener(MouseEvent.CLICK, btnRemoveFriendClick);
			profileScreen.screen.btnRemoveFriend.visible = true;
			
			Main.sfs.send(new ExtensionRequest("friendlist.incoming_requests_count"));
		}
		
		private static function btnCancelFriendClick(event:MouseEvent):void
		{
			Main.sfs.send(new RemoveBuddyRequest(profileParams.getUtfString("name")));
			
			profileScreen.screen.btnCancelFriend.removeEventListener(MouseEvent.CLICK, btnCancelFriendClick);
			profileScreen.screen.btnCancelFriend.visible = false;
			
			profileScreen.screen.btnAddFriend.addEventListener(MouseEvent.CLICK, btnAddFriendClick);
			profileScreen.screen.btnAddFriend.visible = true;
		}
		
		// TODO
		
		private static function btnEnterHouseClick(event:MouseEvent):void
		{
			if(Main.sfs.lastJoinedRoom.getVariable("name_ru").getStringValue() != ("Дом " + profileParams.getUtfString("name")))
			{				
				var params:ISFSObject = new SFSObject();
				params.putUtfString("location", "house_" + profileParams.getUtfString("name"));
				Main.sfs.send(new ExtensionRequest("joinroom", params));
				
				Main.main.removeChild(profileScreen);
			}
		}
		
		private static function btnHousesClick(event:MouseEvent):void
		{
			if(profileScreen.screen.currentFrameLabel != "houses")
			{
				if(housesParams)
				{
					page_houses();
				}
				else
				{
					var params:SFSObject = new SFSObject();
		
					Main.sfs.send(new ExtensionRequest("profile_houses", params));
				}
			}
		}
		
		private static function btnBackgroundsClick(event:MouseEvent):void
		{
			if(profileScreen.screen.currentFrameLabel != "backgrounds")
			{
				if(backgroundsParams)
				{
					page_backgrounds();
				}
				else
				{
					var params:SFSObject = new SFSObject();
		
					Main.sfs.send(new ExtensionRequest("profile_backgrounds", params));
				}
			}
		}
		
		private static function btnInventoryClick(event:MouseEvent):void
		{
			if(profileScreen.screen.currentFrameLabel != "inventory")
			{
				/*if(inventoryParams)
				{
					inventory();
				}
				else
				{*/
					var params:SFSObject = new SFSObject();
		
					Main.sfs.send(new ExtensionRequest("profile_inventory", params));
				//}
			}
		}
		
		private static function btnInfoClick(event:MouseEvent):void
		{
			if(profileScreen.screen.currentFrameLabel != "info")
			{
				info();
			}
		}
		
		private static function btnReportClick(event:MouseEvent):void
		{
			ModScreenUtils.init(profileParams.getUtfString("name"));
		}
		
		private static function overlayClick(event:MouseEvent):void
		{
			Main.main.removeChild(profileScreen);
		}
	}
	
}
