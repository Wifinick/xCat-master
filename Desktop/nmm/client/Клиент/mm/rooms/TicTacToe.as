/**
 * SmartFoxServer 2X Examples - Tris
 * https://www.smartfoxserver.com
 * (c) 2011 gotoAndPlay
 */
package mm.rooms
{
	import com.smartfoxserver.v2.SmartFox;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.User;
	import com.smartfoxserver.v2.entities.Room;
	import com.smartfoxserver.v2.entities.data.ISFSArray;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	import com.smartfoxserver.v2.requests.*;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.geom.ColorTransform;
	import flash.text.*;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	
	import com.adobe.crypto.MD5;
	
	import mm.Main;
	import mm.ScrollBar;
	import mm.entities.Avatar;
	
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.greensock.plugins.TweenPlugin; 
	import com.greensock.plugins.VisiblePlugin;
	

	public class TicTacToe extends MovieClip
	{
		//[Embed(source="../../../assets/assets.swf", symbol="mainStage")]
		private var MainStage:Class;
		
		private var mainMC:MovieClip;
		private var sfs:SmartFox;
		private var container:Object
		private var extensionName:String;
		private var statusTF:TextField;
		private var statsTF:TextField;
		private var board:MovieClip;
		private var myOpponent:User			// My opponent user object
		private var player1Id:int			// Id of player 1
		private var player2Id:int			// Id of player 2
		private var player1Name:String		// Name of player 1
		private var player2Name:String		// Name of player 2
		private var player1:User;
		private var player2:User;
		private var players:Object;
		private var players_mc:Object;
		private var whoseTurn:int
		private var gameStarted:Boolean
		private var ballColors:Array
		private var startParams;
		private var tweenMessage:Array;
		private var gameInited;
		
		private var wgs:WaitingGameScreen;
		
		public function TicTacToe()
		{
			//mainMC = new MainStage()
			extensionName = "tictactoe"
		}
		
		/**
		 * Initialize the game
		 */
		public function initGame(params:Object = null):void
		{
			if (params != null)
			{
				container = params.container
				gameStarted = false
				gameInited = false;
				
				ballColors = []
				ballColors[1] = "cross"
				ballColors[2] = "nought"
				
				// Register to SmartFox events
				sfs = params.sfs
				sfs.addEventListener(SFSEvent.EXTENSION_RESPONSE, onExtensionResponse)
				sfs.addEventListener(SFSEvent.USER_ENTER_ROOM, onUserEnterRoom);
				sfs.addEventListener(SFSEvent.PUBLIC_MESSAGE, onPublicMessage);
				
				container.removeChild(container.getChildByName("dls"));
			
				wgs = new WaitingGameScreen();
				var player1:User = sfs.lastJoinedRoom.userList[0];
				var player2:User = sfs.lastJoinedRoom.userList[1];
				
				wgs.screen.firstPlayerItem.lblName.text = player1.name;
				if(player2)
				{
					wgs.screen.secondPlayerItem.lblName.text = player2.name;
				}
				else
				{
					wgs.screen.secondPlayerItem.lblName.text = "Ожидание игрока...";
				}
				
				wgs.overlay.addEventListener(MouseEvent.CLICK, overlayClick);
				container.addChild(wgs);
				
				// Tell extension I'm ready to play
				sfs.send( new ExtensionRequest("ready", new SFSObject(), sfs.lastJoinedRoom) )
			}
			else
				trace("UNEXPECTED: params doesn't contain any data!")
		}
		
		private function prepareGame(params:ISFSObject):void
		{
			var gs = Main.gameScreen;
			startParams = params;
			
			if(!gameInited)
			{
				
				if(container.contains(wgs))
					container.removeChild(wgs);
				
				gs.locationPanel.visible = false;
				gs.modPanel.visible = false;
				gs.balancePanel.visible = false;
				gs.chatPanel.visible = false;
				gs.chatPanelMinimised.visible = true;
				gs.smilesPanel.x = 270;
									
				Main.sfs.addEventListener(SFSEvent.PUBLIC_MESSAGE, onPublicMessage);
				
				var loadingScreen:LoadingScreen = new LoadingScreen();
				loadingScreen.name = "loadingScreen";
				loadingScreen.lblTarget.text = "Загрузка игры...";
				container.addChild(loadingScreen);
				
				var request:URLRequest = new URLRequest('https://playxcat.ru/gameres/92073d2fe26e543ce222cc0fb0b7d7a0/' + MD5.hash("gm_" + extensionName) + ".swf?v" + Math.random());
				var loader:Loader = new Loader();
				loader.load(request);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadComplete);
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,loadProgress);
	
				function loadComplete(event:Event):void
				{
					event.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loadComplete);
					loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,loadProgress);
	
					container.removeChild(container.getChildByName("loadingScreen"));
	
					mainMC = event.target.loader.content;
					
					mainMC.btnExit.addEventListener(MouseEvent.CLICK, btnExitClick);
					
					// Show stage
					Main.gameScreen.addChildAt(mainMC,0);
					//addChild(mainMC)
					statusTF = mainMC.getChildByName("gameStatus") as TextField
					statsTF = mainMC.getChildByName("stats") as TextField
					board = mainMC.getChildByName("board") as MovieClip
					
					statusTF.text = "Ожидание игрока...";
					statsTF.text = "Победы: 0\n\nПоражения: 0\n\nНичьи: 0";
					
					resetGameBoard();
					
					// Show "wait" message
					/*var message:String = "Waiting for player " + ((sfs.mySelf.playerId == 1) ? "2" : "1")*/
						
					gameInited = true;
						
					startGame(params);
				}
			
				function loadProgress(event:ProgressEvent):void
				{
					var percent = event.bytesLoaded / event.bytesTotal;
	
					loadingScreen.lblProgress.text = Math.floor(percent*100) + "%";
				}
			}
			else
			{
				// Show stage
				Main.gameScreen.addChildAt(mainMC,0);
				//addChild(mainMC)
				statusTF = mainMC.getChildByName("gameStatus") as TextField
				board = mainMC.getChildByName("board") as MovieClip
				
				resetGameBoard();
				
				startGame(params);
			}
		}
		
		/**
		 * Destroy the game instance
		 */
		public function destroy(params:Object = null):void
		{
			sfs.removeEventListener(SFSEvent.EXTENSION_RESPONSE, onExtensionResponse);
			sfs.removeEventListener(SFSEvent.PUBLIC_MESSAGE, onPublicMessage);
		}
		
		/**
		 * Start the game
		 */
		private function startGame(params:ISFSObject):void
		{
			whoseTurn = params.getInt("t");
			player1Id = params.getInt("p1i");
			player2Id = params.getInt("p2i");
			player1Name = params.getUtfString("p1n");
			player2Name = params.getUtfString("p2n");
			player1 = sfs.userManager.getUserById(player1Id);
			player2 = sfs.userManager.getUserById(player2Id);
			
			
			tweenMessage = new Array();
			players = new Object();
			players_mc = new Object();
			players_mc[1] = mainMC.player1;
			players_mc[2] = mainMC.player2;
			players_mc[1].lblName.text = "Игрок 1";
			players_mc[2].lblName.text = "Игрок 2";
			
			var players_dir:Array = new Array();
			players_dir[1] = "SE";
			players_dir[2] = "SW";
			
			for (var i:int = 1; i < 3; i++)
			{				
				players[i] = sfs.userManager.getUserById(params.getInt("p" + i + "i"));
				
				if(!players[i])
					return;
				
				//вот тут
				players_mc[i].lblName.text = players[i].name;
				
				if(!players_mc[i].getChildByName("avt"))
				{
					var avatar:Avatar = new Avatar(players[i].id, "", players[i].getVariable("color").getStringValue(), 230, players[i].getVariable("wear").getSFSObjectValue().toObject(), players_dir[i]); 
					avatar.x = 0;
					avatar.name = "avt";
					if(i == 1)
						avatar.y = 355;
					else
						avatar.y = 400;
					players_mc[i].addChild(avatar);
				}
			}
			
	
			// Reset the game board			
			resetGameBoard();
			
			// Remove the "waiting for other player..." popup
			//container.removeGamePopUp()
			setTurn();
			enableBoard();
				
			gameStarted = true;
		}
		
		/**
		 * Set the "Player's turn" status message
		 */
		private function setTurn():void
		{
			statusTF.text = (sfs.mySelf.playerId == whoseTurn) ? "Ваш ход" : "Ход вашего противника";
		}
		
		/**
		 * Clear the game board
		 */
		private function resetGameBoard():void
		{
			for (var i:int = 1; i <= 3; i++)
			{
				for (var j:int = 1; j <= 3; j++)
				{
					var square:MovieClip = board["sq_" + i + "_" + j] as MovieClip
					var tictac:MovieClip = square.tictac as MovieClip
					tictac.gotoAndStop("off")
				}
			}
		}
		
		/**
		 * Enable board click
		 */
		private function enableBoard(enable:Boolean = true):void
		{
			if (sfs.mySelf.playerId == whoseTurn)
			{
				for (var i:int = 1; i <= 3; i++)
				{
					for (var j:int = 1; j <= 3; j++)
					{
						var square:MovieClip = board["sq_" + i + "_" + j] as MovieClip;
						var tictac:MovieClip = square.tictac as MovieClip;
						
						if (tictac.currentFrame == 1)
						{
							square.buttonMode = enable;
							
							if (enable)
								square.addEventListener(MouseEvent.CLICK, makeMove)
							else
								square.removeEventListener(MouseEvent.CLICK, makeMove)
						}
					}
				}
			}
		}
		
		/**
		 * On board click, send move to other players
		 */
		private function makeMove(evt:MouseEvent):void
		{
			var square:MovieClip = evt.target as MovieClip
			square.tictac.gotoAndStop(ballColors[sfs.mySelf.playerId])
			square.buttonMode = false;
			square.removeEventListener(MouseEvent.CLICK, makeMove)
			
			enableBoard(false)
			
			var x:int = parseInt(square.name.substr(3,1))
			var y:int = parseInt(square.name.substr(5,1))

			var sfso:ISFSObject = new SFSObject()
			sfso.putInt("x", x)
			sfso.putInt("y", y)
				
			sfs.send( new ExtensionRequest("move", sfso, sfs.lastJoinedRoom) );			
		}
		
		/**
		 * Handle the opponent move
		 */
		private function moveReceived(params:ISFSObject):void
		{
			var movingPlayer:int = params.getInt("t")
			whoseTurn = (movingPlayer == 1) ? 2 : 1
		
			if (movingPlayer != sfs.mySelf.playerId)
			{
				var square:MovieClip = board["sq_" + params.getInt("x") + "_" + params.getInt("y")] as MovieClip
				var tictac:MovieClip = square.tictac as MovieClip
				tictac.gotoAndStop(ballColors[movingPlayer])
			}
			
			setTurn()
			enableBoard()
		}
		
		/**
		 * Declare game winner
		 */
		private function showWinner(cmd:String, params:ISFSObject):void
		{
			
			gameStarted = false
			statusTF.text = ""
			
			enableBoard(false);
			
			var message:String = ""
			var win_amount:String = "";
			
			if (cmd == "win")
			{
				if (sfs.mySelf.playerId == params.getInt("w"))
				{
					// I WON! In the next match, it will be my turn first
					message = "Вы выиграли!"
					if(!params.getBool("limit"))
					{
						win_amount = " Вам начислено 15 клубков.";
					}
					
				}
				
				else
				{
					// I've LOST! Next match I will be the second to move
					message = "Вы проиграли!"
				}
			}
			
			else if (cmd == "tie")
			{
				message = "Ничья!"
				
				if(!params.getBool("limit"))
					win_amount = " Вам начислено 5 клубков."
			}
			
			// Show "winner" message
			statusTF.text = message;
			
			var popup:PopupYesNo = new PopupYesNo();
			popup.screen.lblName.text = "Крестики-Нолики";
			popup.screen.lblMessage.text = message + win_amount + " Продолжить игру?";
			popup.screen.btnNo.addEventListener(MouseEvent.CLICK, btnNoClick);
			popup.screen.btnYes.addEventListener(MouseEvent.CLICK, btnYesClick);
			popup.name = "popupYesNo";
			Main.main.addChild(popup);
			
			function btnNoClick(event:MouseEvent):void
			{					
				Main.main.removeChild(Main.main.getChildByName("popupYesNo"));
				leaveGame();
			}
			
			function btnYesClick(event:MouseEvent):void
			{					
				Main.main.removeChild(Main.main.getChildByName("popupYesNo"));
				sfs.send( new ExtensionRequest("restart", new SFSObject(), sfs.lastJoinedRoom) )
				statusTF.text = "Ожидание второго игрока...";
			}
		}
		
		/**
		 * Restart the game
		 */
		private function restartGame():void
		{
			container.removeGamePopUp()
			
			sfs.send( new ExtensionRequest("restart", new SFSObject(), sfs.lastJoinedRoom) )
		}
		
		/**
		 * One of the players left the game
		 */
		private function userLeft():void
		{
			//if(gameInited)
			//{
				gameInited = false;
				
				gameStarted = false
				var message:String = "Второй игрок покинул игру"
				
				if(statusTF)
					statusTF.text = message
				
				// Show "wait" message
				/*message = "Your opponent left the game" + "\n" + "Waiting for a new player"
				container.showGamePopUp("wait", message, null)*/
				
				var popup:PopupOK = new PopupOK();
				popup.screen.lblName.text = "Крестики-Нолики";
				popup.screen.lblMessage.text = message;
				popup.screen.btnOK.addEventListener(MouseEvent.CLICK, btnOKClick);
				popup.name = "popupOK";
				Main.main.addChild(popup);
				
				function btnOKClick(event:MouseEvent):void
				{
					if(Main.main.getChildByName("popupYesNo"))
						Main.main.removeChild(Main.main.getChildByName("popupYesNo"));
					Main.main.removeChild(Main.main.getChildByName("popupOK"));
					leaveGame();
				}
			//}
		}
		
		//------------------------------------------------------------------------------------
		
		public function onExtensionResponse(evt:SFSEvent):void
		{
			var params:ISFSObject = evt.params.params
			var cmd:String = evt.params.cmd
			
			switch(cmd)
			{
				case "start":
					prepareGame(params)
					break
				
				case "stop":
					userLeft()
					break
				
				case "move":
					moveReceived(params)
					break
				
				case "win":
				case "tie":
					showWinner(cmd, params)
					break
				case "stats":
					updateStats(params)
					break;
			}
		}
		
		private function updateStats(params:ISFSObject):void
		{
			statsTF.text = "Победы: " + params.getInt("win") + "\n\nПоражения: " + params.getInt("lose") + "\n\nНичьи: " + params.getInt("tie");
		}
		
		private function overlayClick(event:MouseEvent):void
		{
			sfs.send( new ExtensionRequest("leave", new SFSObject(), sfs.lastJoinedRoom) )
			
			container.removeChild(wgs);
			destroy();
			//Main.sfs.addEventListener(SFSEvent.PUBLIC_MESSAGE, Location.sfsPublicMessage);
		}
		
		private function btnExitClick(event:MouseEvent):void
		{
			leaveGame();
		}
		
		private function onUserEnterRoom(event:SFSEvent):void
		{
			var room:Room = event.params.room as Room;
			var user:User = event.params.user as User;
			
			if(room.id == sfs.lastJoinedRoom.id && user.name != sfs.mySelf.name)
			{
				wgs.screen.secondPlayerItem.lblName.text = user.name;
			}
		}
		
		private function onPublicMessage(event:SFSEvent):void
		{
			var sender:User = event.params.sender;
			var msg:String = event.params.message;
			var invis:Boolean;
			var bubble_mc:MovieClip;
			var i:int;
			var gs = Main.gameScreen;
			
			for(i = 1; i < 3; i++)
				if(players_mc[i].lblName.text == sender.name)
				{
					bubble_mc = players_mc[i].bubble;
					break;
				}
			
			trace(sender + ": " + msg);
			trace(bubble_mc);
			
			bubble_mc.gotoAndStop(1);
			
			if(msg.indexOf("#BUBBLE#::") >= 0)
			{
				bubble_mc.gotoAndStop(msg.substr(10));
				if(i == 2)
					bubble_mc.smile.scaleY = -1;
			}
			else
			{
				bubble_mc.message.text = msg;
				bubble_mc.message.wordWrap = true;
				bubble_mc.message.autoSize = TextFieldAutoSize.CENTER;
				
				bubble_mc.background.height = bubble_mc.message.height + 10;
				bubble_mc.background.y = -bubble_mc.background.height;
				bubble_mc.message.y = bubble_mc.background.y + 5;
				
				if(i == 2)
				{
					trace('хууууууууй');
					bubble_mc.message.scaleY = -1;
					bubble_mc.message.y = bubble_mc.message.y + bubble_mc.message.height;
				}
				else
				trace(i, 'хуууууууууууууй');
				
				Main.gameScreen.chpAddMessage(sender.name, msg);
			}
			
			TweenLite.killTweensOf(bubble_mc);
			TweenLite.fromTo(bubble_mc, 0.3, {visible:true, alpha:0}, {alpha:1});
			TweenLite.to(bubble_mc, 0.3, {delay:5.3, visible:false, alpha:0});
		}
		
		private function leaveGame():void
		{
			destroy();
			
			sfs.send( new ExtensionRequest("leave", new SFSObject(), sfs.lastJoinedRoom) );
			
			var gs = Main.gameScreen;
			
			gs.removeChild(mainMC);
			
			if(Main.sfs.mySelf.isModerator() || Main.sfs.mySelf.isAdmin())
				gs.modPanel.visible = true;
				
			gs.balancePanel.visible = true;
			gs.locationPanel.visible = true;
			gs.chatPanel.visible = true;
			gs.chatPanelMinimised.visible = false;
			gs.smilesPanel.x = 190;
			
			var params:ISFSObject = new SFSObject();
			params.putUtfString("location", "beach");
			
			sfs.send(new ExtensionRequest("joinroom", params));
		}
	}
}
