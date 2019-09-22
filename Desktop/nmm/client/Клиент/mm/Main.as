package mm
{

	import com.smartfoxserver.v2.SmartFox;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.*;
	import com.smartfoxserver.v2.entities.data.*;
	import com.smartfoxserver.v2.entities.variables.*;
	import com.smartfoxserver.v2.requests.*;
	import com.smartfoxserver.v2.util.ClientDisconnectionReason;
	import com.smartfoxserver.v2.core.SFSBuddyEvent;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import mm.Auth;
	import mm.utils.Mask;
	import flash.ui.Mouse;
	import com.smartfoxserver.v2.util.ConfigData;
	import flash.net.URLRequest;
	
	import com.adobe.crypto.MD5;
	import mm.rooms.*;
	import mm.screens.*
	import mm.CalendarDay.*;
	import mm.CalendarDay.Elements.*;
	
	import flash.system.SecurityDomain;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    import flash.system.Security;
	
	//temp
	import com.greensock.*;
	import com.greensock.easing.*;
	import lib.stuffForMM.*;

	public class Main extends MovieClip
	{
		// Режим отладки
		public static var debugMode = true;
		//
		
		
		public static var main:Main;

		public static var sfs:SmartFox = null;
		public static var isBuddyListInited:Boolean;

		private var adminMessage:String;
		
		public static var roomScreen;
		public static var gameScreen:GameScreen;
		
		//temp
		public static var Presents;
		public static var Calendars;
		public var SFS;
		
		// TODO нахуй
		public static var dzAllow:Boolean = false;

		public function Main()
		{
			init();
			main = this;
		}

		public function init():void
		{
			var ls1:LoadingScreen = new LoadingScreen();
			ls1.name = "ls1";
			var ls2:LoadingScreen = new LoadingScreen();
			ls2.name = "ls2";
			var ls3:LoadingScreen = new LoadingScreen();
			ls3.name = "ls3";
			addChild(ls1);
			addChild(ls2);
			addChild(ls3);
			
			preloader();

			sfs = new SmartFox();
			
			var config:ConfigData = new ConfigData();
			
			config.useBlueBox = false;
			if(debugMode)
			{
				//config.debug = true;
				config.host = "127.0.0.1";
				//config.host = "185.104.249.50";
			}
			else
			{
				config.host = "185.104.249.50";
				//config.httpPort = 80;
				//config.useBlueBox = false;
				//config.blueBoxPollingRate = 50;
			}
			config.zone = "mirkomir";
			
			sfs.connectWithConfig(config);

			sfs.addEventListener(SFSEvent.CONNECTION, Auth.sfsConnection);
			sfs.addEventListener(SFSEvent.CONNECTION_LOST, sfsConnectionLost);
			sfs.addEventListener(SFSEvent.LOGIN_ERROR, Auth.sfsLoginError);
			sfs.addEventListener(SFSEvent.LOGIN, Auth.sfsLogin);
			sfs.addEventListener(SFSEvent.ADMIN_MESSAGE, sfsAdminMessage);
			sfs.addEventListener(SFSEvent.MODERATOR_MESSAGE, sfsAdminMessage);
			sfs.addEventListener(SFSBuddyEvent.BUDDY_LIST_INIT, onBuddyListInit);
			sfs.addEventListener(SFSBuddyEvent.BUDDY_ERROR, onBuddyError);
			sfs.addEventListener(SFSBuddyEvent.BUDDY_ONLINE_STATE_UPDATE, onBuddyListUpdate);
			sfs.addEventListener(SFSBuddyEvent.BUDDY_VARIABLES_UPDATE, onBuddyListUpdate);
			sfs.addEventListener(SFSBuddyEvent.BUDDY_ADD, onBuddyListUpdate);
			sfs.addEventListener(SFSBuddyEvent.BUDDY_REMOVE, onBuddyListUpdate);
			sfs.addEventListener(SFSBuddyEvent.BUDDY_BLOCK, onBuddyListUpdate);
			//sfs.addEventListener(SFSBuddyEvent.BUDDY_MESSAGE, onBuddyMessage);
			//temp
			sfs.addEventListener(SFSEvent.PRIVATE_MESSAGE, OnPM);
			
			sfs.addEventListener(SFSEvent.ROOM_JOIN, sfsRoomJoin);
			//говно
			sfs.addEventListener(SFSEvent.EXTENSION_RESPONSE, CatalogScreenUtils.sfsExtensionResponse);
			
			isBuddyListInited = false;
			
			new Mask(this, 1000, 650);
			
			SFS = sfs;
			Presents = new Gifts(this);
			Calendars = new Calendar(this);
		}

		private function preloader():void
		{
			var loadingScreen:LoadingScreen = new LoadingScreen();
			loadingScreen.name = "loadingScreen";
			loadingScreen.lblTarget.text = "Загрузка игры...";
			addChild(loadingScreen);

			loaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, loadProgress);

			function loadComplete(event:Event)
			{
				loaderInfo.removeEventListener(Event.COMPLETE, loadComplete);
				loaderInfo.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
				
				loadingScreen.lblTarget.text = "Подключение к серверу...";
				loadingScreen.lblProgress.text = "";
				
				Main.main.removeChild(Main.main.getChildByName("ls1"));
				Main.main.removeChild(Main.main.getChildByName("ls2"));
				Main.main.removeChild(Main.main.getChildByName("ls3"));
			}
			function loadProgress(event:ProgressEvent):void
			{
				var percent = event.bytesLoaded / event.bytesTotal;
				
				loadingScreen.lblProgress.text = Math.floor(percent*100) + "%";
				trace("Загрузка:", Math.floor(percent*100) + "%");
			}
		}

		private function sfsConnectionLost(event:SFSEvent):void
		{
			// обнуляем всё, что само не в состоянии обнулиться
			//Main.main.removeEventListener(Event.ENTER_FRAME, Location.mainEnterFrame);
			
			trace("Connection was lost. Reason: " + event.params.reason);
			
			var reason:String = "";
			var loadingScreen;
			
			if (event.params.reason != ClientDisconnectionReason.MANUAL)
            {
                 if (event.params.reason == ClientDisconnectionReason.IDLE)
                     reason = "Вы слишком долго бездействовали";
                 else if (event.params.reason == ClientDisconnectionReason.KICK)
				 	 if(adminMessage)
					 	reason = adminMessage
					 else
                     	reason = "Вы были отключены от сервера";
                 else if (event.params.reason == ClientDisconnectionReason.BAN)
				 	 if(adminMessage)
					 	reason = adminMessage
					 else
                     reason = "Ваш аккаунт заблокирован";
                 else
				 	if(Auth.nologin)
					{
						loadingScreen = Main.main.getChildByName("loadingScreen");
						loadingScreen.icon.gotoAndStop("error");
						loadingScreen.lblTarget.text = "Ошибка подключения";
						return;
					}
            }
			else
			{
				loadingScreen = Main.main.getChildByName("loadingScreen");
				loadingScreen.icon.gotoAndStop("error");
				loadingScreen.lblTarget.text = "Ошибка подключения";
				return;
			}
			
			if(reason != "")
				reason = "Причина: " + reason;
			 
			var lostConnectionScreen:LostConnectionScreen = new LostConnectionScreen();
			
			lostConnectionScreen.txtReason.text = "Сервер разорвал соединение. " + reason;
			
			lostConnectionScreen.btn.addEventListener(MouseEvent.CLICK, lostConnectionScreenBtnClick);
			
			addChild(lostConnectionScreen);
		}
		
		private function lostConnectionScreenBtnClick(event:MouseEvent):void
		{
			// обнуляем музыку тут (это логично)
			roomScreen.destroy();
			main.removeChildren(0,main.numChildren - 1);
			init();
		}

		private function sfsAdminMessage(event:SFSEvent):void
		{
			trace("сообщение: " + event.params.message);
			adminMessage = event.params.message;
		}
		
		// друзья
		
		private function onBuddyListInit(evt:SFSBuddyEvent):void
		{
			// Populate list of buddies
			onBuddyListUpdate(evt);
			
			// Set current user details as buddy
			
			// Nick
			//ti_nick.text = sfs.buddyManager.myNickName;
			
			// States
			/*var states:Array = sfs.buddyManager.buddyStates;
			dd_states.dataProvider = states;
			var state:String = (sfs.buddyManager.myState != null ? sfs.buddyManager.myState : "");
			if (states.indexOf(state) > -1)
				dd_states.selectedIndex = states.indexOf(state);
			else
				dd_states.selectedIndex = 0;*/
			
			// Online
			//cb_online.selected = sfs.buddyManager.myOnlineState;
				
			// Buddy variables
			/*var age:BuddyVariable = sfs.buddyManager.getMyVariable(BUDDYVAR_AGE);
			ns_age.value = ((age != null && !age.isNull()) ? age.getIntValue() : 30);
			
			var mood:BuddyVariable = sfs.buddyManager.getMyVariable(BUDDYVAR_MOOD);
			ti_mood.text = ((mood != null && !mood.isNull()) ? mood.getStringValue() : "");*/
			
			isBuddyListInited = true;
			
			initGame();
		}
		
		/**
		 * Build buddies list.
		 */
		private function onBuddyListUpdate(evt:SFSBuddyEvent):void
		{
			trace("buddylistupdate");
			/*var buddies:ArrayCollection = new ArrayCollection();
			
			for each (var buddy:Buddy in sfs.buddyManager.buddyList)
			{
				buddies.addItem(buddy);
				
				// Refresh the buddy chat tab (if open) so that it matches the buddy state
				var tab:ChatTab = stn_chats.getChildByName(buddy.name) as ChatTab;
				if (tab != null)
				{
					tab.buddy = buddy;
					tab.refresh();
					
					// If a buddy was blocked, close its tab
					if (buddy.isBlocked)
						stn_chats.removeChild(tab);
				}
			}*/
			
			//ls_buddies.dataProvider = buddies;
		}
		
		/**
		 * Message received from a buddy.
		 */
		private function onBuddyMessage(evt:SFSBuddyEvent):void
		{
			/*var isItMe:Boolean = evt.params.isItMe;
			var sender:Buddy = evt.params.buddy;
			var message:String = evt.params.message;
			
			var buddy:Buddy;
			
			if (isItMe)
			{
				var buddyName:String = (evt.params.data as ISFSObject).getUtfString("recipient");
				buddy = sfs.buddyManager.getBuddyByName(buddyName);
			}
			else
				buddy = sender;
			
			if (buddy != null)
			{
				var tab:ChatTab = addChatTab(buddy, false);
				tab.displayMessage("<b>" + (isItMe ? "You" : tab.getDisplayedName()) + ":</b> " + message);
			}*/
		}
		
		private function onBuddyError(evt:SFSBuddyEvent):void
		{
			trace("The following error occurred in the buddy list system: " + evt.params.errorMessage);
		}
		
		private function sfsRoomJoin(event:SFSEvent):void
		{
			this.addChild(gameScreen);
			var room:Room = event.params.room;
			
			if(room.groupId == "default" || room.groupId == "houses")
			{
				//init
				Main.gameScreen.setLocation(room.getVariable("name_ru").getStringValue());
				
				var loadingScreen:LoadingScreen;
				
				if(Main.main.getChildByName("loadingScreen"))
					loadingScreen = Main.main.getChildByName("loadingScreen") as LoadingScreen;
				else
					loadingScreen = new LoadingScreen;
				
				loadingScreen.name = "loadingScreen";
				loadingScreen.lblProgress.text = "";
				loadingScreen.lblTarget.text = "Загрузка локации...";
				
				Main.main.addChild(loadingScreen);
				
				var request:URLRequest;
				if(room.groupId == "houses")
					request = new URLRequest('https://playxcat.ru/storage/' + room.getVariable("hash").getStringValue() + ".swf?v" + Math.random());
				else if(Main.debugMode)
					request = new URLRequest('https://playxcat.ru/storage/' + room.getVariable("hash").getStringValue() + ".swf?v" + Math.random());
				else
					request = new URLRequest('https://playxcat.ru/storage/' + room.getVariable("hash").getStringValue() + ".swf?v" + Math.random());
				
				var loader:Loader = new Loader  ;
				loader.load(request);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,loadProgress);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);
	
				function loadComplete(event:Event):void
				{
					var loader = event.target.loader;
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
					loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,loadProgress);
					
					if(room.groupId == "default")
						roomScreen = new Location(event.target.loader.content, room);
						
					if(room.groupId == "houses")
						roomScreen = new House(event.target.loader.content, room);
						
					if(Main.main.getChildByName("questscr"))
					{
						Main.main.setChildIndex(Main.main.getChildByName("questscr"), Main.main.numChildren - 1);
					}
				}
				
				function loadProgress(event:ProgressEvent):void
				{
					var percent = event.bytesLoaded / event.bytesTotal;
	
					loadingScreen.lblProgress.text = Math.floor(percent*100) + "%";
				}
				
				function loadError(event:IOErrorEvent):void
				{
					var loader:Loader = event.target.loader;
					
					var request:URLRequest;
					if(room.groupId == "houses")
						request = new URLRequest('https://playxcat.ru/storage/' + room.getVariable("hash").getStringValue() + ".swf?v" + Math.random());
					else if(Main.debugMode)
						request = new URLRequest('https://playxcat.ru/storage/' + room.getVariable("hash").getStringValue() + ".swf?v" + Math.random());
					else
						request = new URLRequest('https://playxcat.ru/storage/' + room.getVariable("hash").getStringValue() + ".swf?v" + Math.random());
					
					loader.load(request);
				}
			}
			if(room.groupId == "games")
			{
				roomScreen = new TicTacToe();
	
				var params:Object = {};
				params.sfs = Main.sfs;
				params.container = Main.main;
				
				roomScreen.initGame(params);
			}
		}
		
		private function initGame():void
		{
			gameScreen = new GameScreen();
			
			gameScreen.setBalanceRegular(Main.sfs.mySelf.getVariable("balance_regular").getIntValue().toString());
			gameScreen.setBalanceDonate(Main.sfs.mySelf.getVariable("balance_donate").getIntValue().toString());
			
			if(Main.sfs.mySelf.getVariable("bonus").getBoolValue() == true)
				BonusScreenUtils.init();
			
			// инит локи 
			//this.addChild(gameScreen); 
			var locs:Array = new Array("forest","beach","square","club_square") 
			var rnd:Number = Math.round(Math.random()*3); 

			var params:ISFSObject = new SFSObject(); 
			params.putUtfString("location", "beach"); 

			Main.sfs.send(new ExtensionRequest("joinroom", params)); 
			// 

			Main.sfs.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsExtensionResponse); 

			//Main.sfs.send(new ExtensionRequest("friendlist.incoming_requests_count"));
			
			/*var params22:ISFSObject = new SFSObject();
			params22.putInt("id", 0);
			sfs.send(new ExtensionRequest("catalog_wear.price", params22));*/
		}
		
		//temp
		private function OnPM(e:SFSEvent):void {
			if(e.params.sender != sfs.mySelf){
				TweenLite.to(gameScreen.chatPanel.counterValentine, 0.7, {ease:Expo.easeOut, alpha: 0, onComplete:function(){
					gameScreen.chatPanel.counterValentine.lblCount.text = String(int(gameScreen.chatPanel.counterValentine.lblCount.text)+1);
					gameScreen.chatPanel.counterValentine.visible = true;
					TweenLite.to(gameScreen.chatPanel.counterValentine, 0.7, {ease:Expo.easeOut, alpha: 1});
				}});
			}
		}
		
		public function Alert(msg:String):void {
			var W:Al = new Al();
			W.Shadow.alpha = 0;
			W.AlWin.alpha = 0;
			W.AlWin.y = 25;
			
			W.AlWin.ErrText.text = msg;
			W.AlWin.Close.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				TweenNano.to(W.Shadow, 0.7, {ease:Expo.easeOut, alpha: 0});
				TweenNano.to(W.AlWin, 0.7, {ease:Expo.easeOut, alpha: 0, y: -25, onComplete:function(){
				 	stage.removeChild(W);
				}});
			});
			
			stage.addChild(W);
			
			TweenNano.to(W.Shadow, 0.7, {ease:Expo.easeOut, alpha: 1});
			TweenNano.to(W.AlWin, 0.7, {ease:Expo.easeOut, alpha: 1, y: 0});
		}
		
		private function sfsExtensionResponse(evt:SFSEvent):void
		{
			var responseParams:SFSObject;
			
			trace(evt.params.cmd);
			 
			//
			
			if (evt.params.cmd == "shop.data")
			{
				responseParams = evt.params.params as SFSObject;
				
				var shopScreen:ShopScreen = new ShopScreen(this, responseParams);
			}
			
			if (evt.params.cmd == "furniture.set")
			{
				Main.main.removeChild(Main.main.getChildByName("dls"));
			}
			
			if (evt.params.cmd == "furniture.get")
			{
				trace('мебель');
				responseParams = evt.params.params as SFSObject;
				
				gameScreen.initFurniturePanel(responseParams);
			}
			
			if (evt.params.cmd == "profile_info")
			{
				responseParams = evt.params.params as SFSObject;
				
				ProfileScreenUtils.init(responseParams);
			}
			
			if (evt.params.cmd == "profile_inventory")
			{
				responseParams = evt.params.params as SFSObject;
				
				ProfileScreenUtils.saveInventoryParams = responseParams;
				ProfileScreenUtils.inventory(responseParams);
			}
			
			if (evt.params.cmd == "profile_backgrounds")
			{
				responseParams = evt.params.params as SFSObject;
				
				ProfileScreenUtils.page_backgrounds(responseParams);
			}
			
			if (evt.params.cmd == "profile_houses")
			{
				responseParams = evt.params.params as SFSObject;
				
				ProfileScreenUtils.page_houses(responseParams);
			}
			
			if (evt.params.cmd == "invisible_response")
			{
				if(Main.main.getChildByName("dls"))
				{
					Main.main.removeChild(Main.main.getChildByName("dls"));
				}
			}
			
			if (evt.params.cmd == "friendlist")
			{
				responseParams = evt.params.params as SFSObject;
				
				FriendsScreenUtils.init(responseParams);
			}
			
			if (evt.params.cmd == "rating")
			{
				responseParams = evt.params.params as SFSObject;
				
				RatingScreenUtils.init(responseParams);
			}
			
			if (evt.params.cmd == "outcoming_requests")
			{
				responseParams = evt.params.params as SFSObject;
				
				FriendsScreenUtils.outcomingRequests(responseParams);
			}
			
			if (evt.params.cmd == "incoming_requests")
			{
				responseParams = evt.params.params as SFSObject;
				
				FriendsScreenUtils.incomingRequests(responseParams);
			}
			
			if (evt.params.cmd == "incoming_requests_count")
			{
				responseParams = evt.params.params as SFSObject;
				
				var count:Number = responseParams.getInt("count");
				
				trace("count", count);
				
				if(count > 0)
				{
					gameScreen.chatPanel.btnFriendsNotification.visible = true;
					gameScreen.chatPanel.btnFriendsNotification.lblCount.text = count;
				}
				else
				{
					gameScreen.chatPanel.btnFriendsNotification.visible = false;
				}
			}
			
			trace('event', evt.params.cmd);
		}
	}

}