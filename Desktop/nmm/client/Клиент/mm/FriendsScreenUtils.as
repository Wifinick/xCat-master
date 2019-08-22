package mm {
	import com.smartfoxserver.v2.entities.Buddy;
	import flash.display.MovieClip;
	
	public class FriendsScreenUtils {
		
		import flash.events.*;
		import com.smartfoxserver.v2.SmartFox;
		import com.smartfoxserver.v2.core.SFSEvent;
		import com.smartfoxserver.v2.entities.*;
		import com.smartfoxserver.v2.entities.data.*;
		import com.smartfoxserver.v2.entities.variables.*;
		import com.smartfoxserver.v2.requests.*;
		import com.smartfoxserver.v2.requests.buddylist.*;
		
		private static var friendsScreen:FriendsScreen;
		private static var i:Number;
		private static var scrollbar:ScrollBar;
		private static var dla:MovieClip;
		private static var list:ISFSArray;

		public function FriendsScreenUtils() {
			// constructor code
		}
		
		public static function init(params:SFSObject) {
			trace('Список друзей');
			
			if(friendsScreen)
				if(Main.main.contains(friendsScreen))
					Main.main.removeChild(friendsScreen);
			
			friendsScreen = new FriendsScreen();
			
			friendsScreen.name = "fs";
			
			friendsScreen.screen.btnFriendlist.addEventListener(MouseEvent.CLICK, btnFriendlistClick);
			friendsScreen.screen.btnIncomingRequests.addEventListener(MouseEvent.CLICK, btnIncomingRequestsClick);
			friendsScreen.screen.btnOutcomingRequests.addEventListener(MouseEvent.CLICK, btnOutcomingRequestsClick);
			friendsScreen.overlay.addEventListener(MouseEvent.CLICK, overlayClick);
			friendsScreen.screen.txtSearch.addEventListener(Event.CHANGE, txtSearchInput);
			
			dla = friendsScreen.screen.dataLoadingAnim;
			
			// проверка, загружается ли страница в первый раз
			if(!Main.main.contains(friendsScreen))
			{
				if(Main.main.getChildByName("dls"))
					Main.main.removeChild(Main.main.getChildByName("dls"));
				Main.main.addChild(friendsScreen);
			}
			
			friendlist(params);
		}
		
		public static function friendlist(params:SFSObject):void
		{
			trace("Список друзей: френдлист");
			
			friendsScreen.screen.lblTitle.text = "Список друзей";
			
			list = params.getSFSArray("list");
			
			loadList(list, "friendlist");
		}
		
		public static function incomingRequests(params:SFSObject):void
		{
			trace("Список друзей: входящие заявки");
			
			friendsScreen.screen.lblTitle.text = "Входящие заявки";
			
			list = params.getSFSArray("list")
			
			loadList(list, "incoming_requests");
			
			dla.visible = false;
		}
		
		public static function outcomingRequests(params:SFSObject):void
		{
			trace("Список друзей: исходящие заявки");
			
			friendsScreen.screen.lblTitle.text = "Исходящие заявки";
			
			list = params.getSFSArray("list")
			
			loadList(list, "outcoming_requests");
			
			dla.visible = false;
		}
		
		private static function search(req:String):ISFSArray
		{
			var newlist:ISFSArray = new SFSArray();
			
			for(i = 0; i < list.size(); i++)
			{
				if(list.getUtfString(i).toLowerCase().indexOf(req.toLowerCase()) != -1)
				{
					newlist.addUtfString(list.getUtfString(i));
				}
			}
			trace('ХУУУУУУУУЙ', newlist.size());
			trace('dasdasd', newlist.getUtfString(0));
			
			return newlist;
		}
		
		private static function loadList(list:ISFSArray, type:String = "", search:Boolean = false):void
		{
			dla.visible = true;
			
			Main.sfs.send(new ExtensionRequest("friendlist.incoming_requests_count"));
			
			for(i = friendsScreen.screen.field.content.numChildren; i > 0; i--)
			{
				friendsScreen.screen.field.content.getChildAt(i - 1).removeEventListener(MouseEvent.CLICK, itemClick);
				friendsScreen.screen.field.content.getChildAt(i - 1).removeEventListener(MouseEvent.CLICK, btnRemoveClick);
				friendsScreen.screen.field.content.removeChildAt(i - 1);
			}
			
			
			var friendlist:Array = new Array();
			
			switch(type)
			{
				case "friendlist": 
					Main.sfs.buddyManager.onlineBuddies.sort(Array.CASEINSENSITIVE);
					Main.sfs.buddyManager.offlineBuddies.sort(Array.CASEINSENSITIVE);
					
					trace('онлайн баддисов', Main.sfs.buddyManager.onlineBuddies.length);
					
					var buddy:Buddy;
					
					for(i = 0; i < Main.sfs.buddyManager.onlineBuddies.length; i++)
					{
						buddy = Main.sfs.buddyManager.onlineBuddies[i];
						
						trace('бляяядь', buddy.name);
						
						if(list.contains(buddy.name))
						{
						   friendlist.push(buddy.name);
						   
						   trace('онлайн');
						}
						else
						{
							trace('почему блядь');
						}
					}
					
					for(i = 0; i < Main.sfs.buddyManager.offlineBuddies.length; i++)
					{
						buddy = Main.sfs.buddyManager.offlineBuddies[i];
						
						if(list.contains(buddy.name))
						{
						   friendlist.push(buddy.name);
						   
						   trace('оффлайн');
						}
						else
						{
							trace('хули');
						}
					}
					
					break;
					
				case "incoming_requests": 
					for(i = 0; i < list.size(); i++)
					{
						friendlist.push(list.getUtfString(i));
					}
					
					break;
					
				case "outcoming_requests": 
					for(i = 0; i < list.size(); i++)
					{
						friendlist.push(list.getUtfString(i));
					}
					
					break; 
			}
			
			
			trace('сААаайз', friendlist.length);
			
			var h:Number = 0;
			
			if(friendlist.length == 0)
			{
				if(search)
				{
					friendsScreen.screen.lblEmpty.text = "Совпадений не найдено";
				}
				else
				{
					switch(type)
					{
						case "friendlist": friendsScreen.screen.lblEmpty.text = "Ваш список друзей пуст"; break;
						
						case "incoming_requests": friendsScreen.screen.lblEmpty.text = "Входящих заявок нет"; break;
							
						case "outcoming_requests": friendsScreen.screen.lblEmpty.text = "Исходящих заявок нет"; break;
					}
				}
			}
			else
			{
				friendsScreen.screen.lblEmpty.text = "";
			}
			
			for(i = 0; i < friendlist.length; i++)
			{
				
				
				var item:FriendlistItem = new FriendlistItem();
				
				if(type == "friendlist")
				{
					trace(friendlist[i], Main.sfs.buddyManager.getBuddyByName(friendlist[i]).isOnline);
					if(!Main.sfs.buddyManager.getBuddyByName(friendlist[i]).isOnline)
					{
						item.mcState.visible = false;
					}
				}
				else
				{
					item.mcState.visible = false;
				}
				
				item.stop();
				item.buttonMode = true;
				item.name = "item";
				item.lblName.text = friendlist[i];
				item.lblName.mouseEnabled = false;
				item.addEventListener(MouseEvent.CLICK, itemClick);
				item.btnRemove.addEventListener(MouseEvent.CLICK, btnRemoveClick);
				
				if(type != "incoming_requests")
				{
					item.btnAccept.visible = false;
				}
				else
				{
					item.lblName.width = 143.2;
					item.btnAccept.addEventListener(MouseEvent.CLICK, btnAcceptClick);
				}
				
				item.y = h;
				
				if(i % 2 != 0)
				{
					item.x = 222;
					h += 40.2;
				}
				
				friendsScreen.screen.field.content.addChild(item);
			}
			
			if(scrollbar)
			{
				scrollbar.destroy();
			}
			scrollbar = new ScrollBar(friendsScreen.screen.field, friendsScreen.screen.scrollbar, Main.main.stage, 40.2);
			
			dla.visible = false;
			
			function itemClick(event:MouseEvent)
			{
				if(event.target.name == "item")
				{
					var dataLoadingScreen:DataLoadingScreen = new DataLoadingScreen();
					dataLoadingScreen.name = "dls";
					Main.main.addChild(dataLoadingScreen);
					
					var params:ISFSObject = new SFSObject();
					params.putUtfString("name", event.target.lblName.text);
		
					Main.sfs.send(new ExtensionRequest("profile", params));
				}
			}
			
			function btnRemoveClick(event:MouseEvent)
			{
				var params:ISFSObject;
				var dataLoadingScreen:DataLoadingScreen;
				
				switch(type)
				{					
					case "friendlist":
						params = new SFSObject();
						params.putUtfString("name", event.target.parent.lblName.text);
						Main.sfs.send(new ExtensionRequest("friend_remove", params));
						
						dla.visible = true;
						
						params = new SFSObject();
						params.putUtfString("name", Main.sfs.mySelf.name);
			
						Main.sfs.send(new ExtensionRequest("friendlist", params));
						break;
						
					case "incoming_requests":
						
						params = new SFSObject();
						params.putUtfString("name", event.target.parent.lblName.text);
						Main.sfs.send(new ExtensionRequest("friend_request_remove", params));
						
						dla.visible = true;
						
						params = new SFSObject();
						params.putUtfString("name", Main.sfs.mySelf.name);
						
						Main.sfs.send(new ExtensionRequest("friendlist.incoming_requests_count"));
						Main.sfs.send(new ExtensionRequest("friendlist.incoming_requests", params));
						break;
						
					case "outcoming_requests":
						Main.sfs.send(new RemoveBuddyRequest(event.target.parent.lblName.text));
						
						dla.visible = true;
						
						Main.sfs.send(new ExtensionRequest("friendlist.outcoming_requests", params));
						break;
				}
			}
			
			function btnAcceptClick(event:MouseEvent)
			{
				Main.sfs.send(new AddBuddyRequest(event.target.parent.lblName.text));

				dla.visible = true;
				
				var params:ISFSObject = new SFSObject();
				params.putUtfString("name", Main.sfs.mySelf.name);
	
				Main.sfs.send(new ExtensionRequest("friendlist.incoming_requests", params));
			}
		}
		
		private static function btnFriendlistClick(event:MouseEvent):void
		{
			dla.visible = true;
			
			var params:ISFSObject = new SFSObject();
			params.putUtfString("name", Main.sfs.mySelf.name);

			Main.sfs.send(new ExtensionRequest("friendlist", params));
		}
		
		private static function btnIncomingRequestsClick(event:MouseEvent):void
		{
			dla.visible = true;
			
			var params:ISFSObject = new SFSObject();
			params.putUtfString("name", Main.sfs.mySelf.name);
			
			trace('ъйвфывфывфъыв');
			Main.sfs.send(new ExtensionRequest("friendlist.incoming_requests", params));
		}
		
		private static function btnOutcomingRequestsClick(event:MouseEvent):void
		{
			dla.visible = true;
			
			var params:ISFSObject = new SFSObject();
			params.putUtfString("name", Main.sfs.mySelf.name);

			Main.sfs.send(new ExtensionRequest("friendlist.outcoming_requests", params));
		}
		
		private static function overlayClick(event:MouseEvent):void
		{
			Main.main.removeChild(friendsScreen);
		}
		
		private static function txtSearchInput(event:Event):void
		{
			var param:String;
			var req:String = friendsScreen.screen.txtSearch.text;
			
			switch(friendsScreen.screen.lblTitle.text)
			{
				case "Список друзей": param = "friendlist"; break;
				case "Входящие заявки": param = "incoming_requests"; break;
				case "Исходящие заявки": param = "outcoming_requests"; break;
			}
			
			if(req == "")
			{
				loadList(list, param);
			}
			else
			{
				loadList(search(req), param, true);
			}
		}

	}
	
}
