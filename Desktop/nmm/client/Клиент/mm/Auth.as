package mm
{
	import com.smartfoxserver.v2.SmartFox;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.*;
	import com.smartfoxserver.v2.entities.UserPrivileges;
	import com.smartfoxserver.v2.entities.data.*;
	import com.smartfoxserver.v2.entities.variables.*;
	import com.smartfoxserver.v2.requests.*;
	import com.smartfoxserver.v2.requests.buddylist.InitBuddyListRequest;
	import com.adobe.serialization.json.JSON;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import mm.Main;
	import flash.display3D.IndexBuffer3D;
	import flash.ui.GameInput;
	import flash.net.*;

	public class Auth
	{
		public static var nologin = true;
		
		public function Auth()
		{
			super();
		}

		public static function sfsConnection(event:SFSEvent):void
		{
			if (event.params.success)
			{
				trace("Connection Success!");

				var sfs = event.target;
				if(Main.debugMode){
					var rnd:String = (Math.round(Math.random()*1) + 1).toString();
					trace(rnd);
					sfs.send(new LoginRequest("а)))", "token", sfs.config.zone));
					
				}
				else
				{
					var loader:URLLoader = new URLLoader();
					var request:URLRequest=new URLRequest('https://playxcat.ru/script/gettoken.php'); // адрес вашего скрипта
					request.method=URLRequestMethod.POST;
					var vars:URLVariables = new URLVariables();
					vars['27e534fe98702739fc2d3b605ebadeaf'] = 1;
					request.data=vars;
					loader.addEventListener(Event.COMPLETE, onComplete);
					loader.load(request);
					 
					function onComplete(event:Event):void {
						var resultObj:Object = com.adobe.serialization.json.JSON.decode(loader.data);
						
						if(resultObj["username"] && resultObj["token"])
						{
							sfs.send(new LoginRequest(resultObj["username"], resultObj["token"], sfs.config.zone));
						}
						else
						{
							Main.sfs.disconnect();
						}
					}
				}
			}
			else
			{
				trace("Connection Failure: " + event.params.errorMessage);
				
				/*var lostConnectionScreen:LostConnectionScreen = new LostConnectionScreen();
				lostConnectionScreen.txtReason.text = "Сервер недоступен.\nПопробуйте зайти позже.";
				Main.main.addChild(lostConnectionScreen);*/
				
				var loadingScreen = Main.main.getChildByName("loadingScreen");
				loadingScreen.lblTarget.text = "Сервер недоступен, попробуйте зайти позже";
				loadingScreen.icon.gotoAndStop("offline");
				
			}
		}
		
		public static function sfsLogin(event:SFSEvent):void
		{
			var sfs = event.target;
			
			nologin = Main.sfs.mySelf.isGuest();
			
			if (sfs.mySelf.privilegeId != UserPrivileges.GUEST)
			{
				trace(sfs.mySelf.privilegeId);
				//mainView.selectedChild = view_inside;
				trace("You are logged in as " + sfs.mySelf.name);
				
				//removeChild(authScreen);
				
				//authScreen.btnLogin.removeEventListener(MouseEvent.CLICK, btnLoginClick);
				
				
				//Main.main.removeChild(Main.main.getChildByName("authScreen"));
				
				Main.sfs.send(new InitBuddyListRequest());
				
				//Game.init();
				
				//Main.main.removeChild("authScreen");
			}
		}
		
		public static function sfsLoginError(event:SFSEvent):void
		{
			trace(event.params["errorMessage"], "Login Error");
			var loadingScreen = Main.main.getChildByName("loadingScreen");
			loadingScreen.icon.gotoAndStop("error");
			loadingScreen.lblTarget.text = "Ошибка подключения";
			//Main.sfs.disconnect();
		}

	}

}