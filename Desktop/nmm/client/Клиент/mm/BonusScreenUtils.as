package mm {
	
	import flash.display.*;
	import flash.events.*;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.*;
	import com.smartfoxserver.v2.requests.*;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.hurlant.crypto.symmetric.NullPad;
	import flash.utils.*;
	
	public class BonusScreenUtils {
		
		private static var bonusScreen:BonusScreen;
		private static var currentBonus:Number;
		private static var bonus:Array;
		private static var bonusAmount:Array;
		private static var i;
		
		public function BonusScreenUtils() {
			super();
		}
		
		public static function init():void
		{
			Main.sfs.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsExtensionResponse);
			
			bonusScreen = new BonusScreen();
			
			bonusScreen.overlay.addEventListener(MouseEvent.CLICK, overlayClick);
			
			bonus = new Array();
			
			for each (var DO:DisplayObject in bonusScreen.screen)
			{
				if (DO.name.indexOf("bonus") >= 0)
				{
					var mcHandler:MovieClip = bonusScreen.screen.getChildByName(DO.name) as MovieClip;
					mcHandler.stop();
					mcHandler.btnBonus.addEventListener(MouseEvent.CLICK, btnBonusClick);
					
					var number:int = int(mcHandler.name.substr(6));
					bonus[number] = mcHandler;
				}
			}

			Main.gameScreen.addChild(bonusScreen);
		}
		
		private static function overlayClick(event:MouseEvent):void
		{
			Main.gameScreen.removeChild(bonusScreen);
		}
		
		private static function btnBonusClick(event:MouseEvent):void
		{
			currentBonus = int(event.currentTarget.parent.name.substr(6));
			
			for(i = 1; i < 4; i++)
			{
				bonus[i].gotoAndStop("loading");
			}
			
			var params:ISFSObject = new SFSObject();
			params.putInt("number", currentBonus);

			Main.sfs.send(new ExtensionRequest("bonus", params));
		}
		
		public static function sfsExtensionResponse(evt:SFSEvent):void
		{			
			if (evt.params.cmd == "bonus_response")
			{
				var responseParams = evt.params.params as SFSObject;
				
				bonusAmount = new Array();
				
				for(i = 1; i < 4; i++)
				{
					bonusAmount[i] = responseParams.getInt(i);
				}
				
				bonus[currentBonus].mcAnim.play();
				
				var currentBonusTimer = setTimeout(currentBonusLblOpen, 600);
				
				function currentBonusLblOpen():void
				{
					bonusScreen.screen.lblMessage.text = "Вы получаете " + bonusAmount[currentBonus] + " клубков";
					
					bonus[currentBonus].gotoAndStop("current_bonus");
					bonus[currentBonus].lblBonus.text = bonusAmount[currentBonus];
					
					var bonusTimer = setTimeout(bonusOpen, 600);
					
					function bonusOpen():void
					{
						for(i = 1; i < 4; i++)
						{
							if(i != currentBonus)
							{
								bonus[i].mcAnim.play();
							}
						}
						
						var bonusTimer = setTimeout(bonusLblOpen, 600);
						
						function bonusLblOpen():void
						{
							for(i = 1; i < 4; i++)
							{
								if(i != currentBonus)
								{
									bonus[i].gotoAndStop("bonus");
									bonus[i].lblBonus.text = bonusAmount[i];
								}
							}
						}
					}
				}
			}
		}
	}
	
}
