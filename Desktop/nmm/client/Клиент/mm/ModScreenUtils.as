package mm {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.*;
	import com.smartfoxserver.v2.requests.*;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.hurlant.crypto.symmetric.NullPad;
	
	import mm.utils.StringEdit;
	
	public class ModScreenUtils {
		
		private static var modScreen:ModScreen;
		
		public function ModScreenUtils() {
			super();
		}
		
		public static function init(username:String = ""):void
		{
			modScreen = new ModScreen();
			
			Main.sfs.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsExtensionResponse);
			
			modScreen.overlay.addEventListener(MouseEvent.CLICK, overlayClick);
			modScreen.panel.btnBanUser.addEventListener(MouseEvent.CLICK, btnBanUserClick);
			modScreen.panel.btnKickUser.addEventListener(MouseEvent.CLICK, btnKickUserClick);
			
			modScreen.panel.txtTarget.text = username;
			
			if(Main.sfs.mySelf.isAdmin())
			{
				modScreen.panel.btnBanIP.addEventListener(MouseEvent.CLICK, btnBanIPClick);
				modScreen.panel.btnBanIP.visible = true;
				modScreen.panel.lblTarget.text = "Пользователь/IP";
			}
			else
			{
				modScreen.panel.btnBanIP.visible = false;
			}
			
			if(!Main.main.contains(modScreen))
			{
				Main.main.addChild(modScreen);
			}
		}
		
		private static function overlayClick(event:MouseEvent):void
		{
			Main.main.removeChild(modScreen);
		}
		
		private static function btnBanUserClick(event:MouseEvent):void
		{
			var dataLoadingScreen:DataLoadingScreen = new DataLoadingScreen();
			dataLoadingScreen.name = "dls";
			Main.main.addChild(dataLoadingScreen);
			
			var day:Number = int(StringEdit.trim(modScreen.panel.txtDay.text));
			var hour:Number = int(StringEdit.trim(modScreen.panel.txtHour.text));
			var minute:Number = int(StringEdit.trim(modScreen.panel.txtMinute.text));
			
			var params:ISFSObject = new SFSObject();
			params.putUtfString("username", modScreen.panel.txtTarget.text);
			params.putUtfString("reason", modScreen.panel.txtReason.text);
			params.putLong("time", day*24*3600 + hour*3600 + minute*60);

			Main.sfs.send(new ExtensionRequest("mod.ban_user", params));
		}
		
		private static function btnBanIPClick(event:MouseEvent):void
		{
			var dataLoadingScreen:DataLoadingScreen = new DataLoadingScreen();
			dataLoadingScreen.name = "dls";
			Main.main.addChild(dataLoadingScreen);
			
			var day:Number = int(StringEdit.trim(modScreen.panel.txtDay.text));
			var hour:Number = int(StringEdit.trim(modScreen.panel.txtHour.text));
			var minute:Number = int(StringEdit.trim(modScreen.panel.txtMinute.text));
			
			var params:ISFSObject = new SFSObject();
			params.putUtfString("ip", modScreen.panel.txtTarget.text);
			params.putUtfString("reason", modScreen.panel.txtReason.text);
			params.putLong("time", day*24*3600 + hour*3600 + minute*60);

			Main.sfs.send(new ExtensionRequest("mod.ban_ip", params));
		}
		
		private static function btnKickUserClick(event:MouseEvent):void
		{
			var dataLoadingScreen:DataLoadingScreen = new DataLoadingScreen();
			dataLoadingScreen.name = "dls";
			Main.main.addChild(dataLoadingScreen);
			
			var params:ISFSObject = new SFSObject();
			params.putUtfString("username", modScreen.panel.txtTarget.text);
			params.putUtfString("reason", modScreen.panel.txtReason.text);

			Main.sfs.send(new ExtensionRequest("mod.kick", params));
		}
		
		public static function sfsExtensionResponse(evt:SFSEvent):void
		{			
			if (evt.params.cmd == "mod_response")
			{
				var responseParams = evt.params.params as SFSObject;
				
				modScreen.panel.txtResponse.text = responseParams.getUtfString("msg");
				
				Main.main.removeChild(Main.main.getChildByName("dls"));
			}
		}
	}
	
}
