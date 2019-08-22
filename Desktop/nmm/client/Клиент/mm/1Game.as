package mm
{
	import com.smartfoxserver.v2.SmartFox;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.*;
	import com.smartfoxserver.v2.entities.UserPrivileges;
	import com.smartfoxserver.v2.entities.data.*;
	import com.smartfoxserver.v2.entities.variables.*;
	import com.smartfoxserver.v2.requests.*;
	import com.smartfoxserver.v2.requests.buddylist.GoOnlineRequest;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import mm.Main;
	import flash.display3D.IndexBuffer3D;
	import flash.ui.GameInput;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import com.hurlant.crypto.symmetric.NullPad;
	import flash.ui.GameInput;
	import flash.ui.Keyboard;
	import flash.geom.ColorTransform;
	
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.media.SoundChannel;
	import flash.net.SharedObject;
	import flash.geom.Rectangle;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.greensock.plugins.TweenPlugin; 
	import com.greensock.plugins.VisiblePlugin;
	
	import com.adobe.crypto.MD5;
	
	import flash.text.*;
	
	import com.adobe.tvsdk.mediacore.info.Profile;
	import mm.profile.Profile;
	import mm.screens.MapScreen;
	import mm.ScrollBar;
	//import mm.rooms.player.Avatar

	import mm.screens.GameScreen;

	public class Game
	{
		public static var gameScreen:GameScreen;
		public static var dzAllow:Boolean = false;
		private static var profileScreen:ProfileScreen;

		public function Game()
		{
			super();
		}

		public static function init():void
		{
			//
			// Инициализация
			//
			
			TweenPlugin.activate([VisiblePlugin]);
			
			gameScreen = new GameScreen();
			
			gameScreen.setBalanceRegular(Main.sfs.mySelf.getVariable("balance_regular").getIntValue().toString());
			gameScreen.setBalanceDonate(Main.sfs.mySelf.getVariable("balance_donate").getIntValue().toString());
			
			Main.main.addChildAt(gameScreen, 0);
			
			BonusScreenUtils.init();
			
			// инит локи
			
			var locs:Array = new Array("forest","beach","square","club_square","playground")
			var rnd:Number = Math.round(Math.random()*4);
			
			var params:ISFSObject = new SFSObject();
			params.putUtfString("location", locs[rnd]);
			
			Main.sfs.send(new ExtensionRequest("joinroom", params));
			//
			
			Main.sfs.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsExtensionResponse);
			
			Main.sfs.send(new ExtensionRequest("friendlist.incoming_requests_count"));
		}
		
		public static function sfsExtensionResponse(evt:SFSEvent):void
		{
			var responseParams;
			
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
				
				if(!Main.main.getChildByName("fs"))
				{
					FriendsScreenUtils.init(responseParams);
				}
				else
				{
					FriendsScreenUtils.friendlist(responseParams);
				}
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