package mm.profile {
	
	import flash.display.MovieClip;
	import flash.events.*;
	
	import com.smartfoxserver.v2.SmartFox;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	import com.smartfoxserver.v2.requests.ExtensionRequest;
	
	import mm.Main;
	
	public class Profile {
		
		internal var _page;
		internal var profileScreen:ProfileScreen;
		internal var wear:Object;
		internal var avatar:Avatar;
		internal var background;

		public function Profile(username:String) {
			
			var dataLoadingScreen:DataLoadingScreen = new DataLoadingScreen();
			dataLoadingScreen.name = "dls";
			Main.main.addChild(dataLoadingScreen);
			
			var params:ISFSObject = new SFSObject();
			params.putUtfString("name", username);

			Main.sfs.send(new ExtensionRequest("profile", params));
			
			Main.sfs.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsExtensionResponse);
			
		}
		
		private function sfsExtensionResponse(evt:SFSEvent):void
		{
			var responseParams;
			
			if (evt.params.cmd == "profile_info")
			{
				responseParams = evt.params.params as SFSObject;
				
				if(_page)
				{
					_page.destroy();
				}
				
				init(responseParams);
				
				//_page = new Information(responseParams);
			}
			
			if (evt.params.cmd == "profile_inventory")
			{
				responseParams = evt.params.params as SFSObject;
				
				if(_page)
				{
					_page.destroy();
				}
				
				//_page = new Inventory(responseParams);
			}
			
			if (evt.params.cmd == "profile_backgrounds")
			{
				responseParams = evt.params.params as SFSObject;
				
				if(_page)
				{
					_page.destroy();
				}
				
				//_page = new Backgrounds(responseParams);
			}
		}
		
		internal function init(params:SFSObject)
		{
			trace("Профиль");
			
			// удаление открытого профиля при повторном открытии
			/*
			if(profileScreen)
				if(Main.main.contains(profileScreen))
					Main.main.removeChild(profileScreen);
			
			*/
			
			profileScreen = new ProfileScreen();
			
			wear = new Object();
			avatar = null;
			background = new Object();
			
			//profileParams = null;
			//inventoryParams = null;
			//backgroundsParams = null;
			
			// включение/выключение кнопки редактора аватара
			if(params.getUtfString("name") == Main.sfs.mySelf.name)
			{
				profileScreen.profile.btnInfo.visible = true;
				profileScreen.profile.btnInventory.visible = true;
				profileScreen.profile.btnBackgrounds.visible = true;
				
				//profileScreen.profile.btnInfo.addEventListener(MouseEvent.CLICK, btnInfoClick);
				//profileScreen.profile.btnInventory.addEventListener(MouseEvent.CLICK, btnInventoryClick);
				//profileScreen.profile.btnBackgrounds.addEventListener(MouseEvent.CLICK, btnBackgroundsClick);
			}
			else
			{
				profileScreen.profile.btnInfo.visible = false;
				profileScreen.profile.btnInventory.visible = false;
				profileScreen.profile.btnBackgrounds.visible = false;
			}
			
			Main.main.removeChild(Main.main.getChildByName("dls"));
			Main.main.addChild(profileScreen);
			
			// остальные события
			//profileScreen.overlay.addEventListener(MouseEvent.CLICK, overlayClick);
			
			//_page = new Information(params);
		}

	}
	
}
