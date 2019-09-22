package mm.rooms {
	
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.InteractiveObject;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.Room;
	import com.smartfoxserver.v2.entities.User;
	import com.smartfoxserver.v2.entities.data.ISFSArray;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	import com.smartfoxserver.v2.requests.ExtensionRequest;
	import com.smartfoxserver.v2.requests.SetUserVariablesRequest;
	
	import mm.Main;
	import mm.entities.Avatar;
	import mm.screens.MapScreen;
	//halloween quest
	import mm.entities.tmp.Pumpkin;
	
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.greensock.plugins.TweenPlugin; 
	import com.greensock.plugins.VisiblePlugin;
	import fl.transitions.Tween;
	import com.smartfoxserver.v2.entities.variables.UserVariable;
	import com.smartfoxserver.v2.entities.variables.SFSUserVariable;
	
	public class Location extends MovieClip {
		
		public var _mc:MovieClip;
		internal var _room:Room;
		public var locationObjects:Array;
		private var reqPos;
		private var playersVisible:Boolean = true;
		
		public function	Location(mc:MovieClip, room:Room) 
		{
			_mc = mc;
			_room = room;
			
			Main.main.removeChild(Main.main.getChildByName("loadingScreen"));
			// добавление интерфейса при входе в игру
			
			Main.sfs.addEventListener(SFSEvent.USER_VARIABLES_UPDATE, sfsUserVarsUpdate);
			Main.sfs.addEventListener(SFSEvent.USER_EXIT_ROOM, sfsUserExitRoom);
			Main.sfs.addEventListener(SFSEvent.PUBLIC_MESSAGE, sfsPublicMessage);
			
			
			_mc.addEventListener(MouseEvent.MOUSE_DOWN, locationMouseDown);
			_mc.mouseChildren = true;
			_mc.dynamicObjects.mouseChildren = true;
			
			Main.gameScreen.setSound(_room.getVariable("hash").getStringValue());
			// halloween quest
			
			if(room.containsVariable("pumpkin")) {
				var request:URLRequest = new URLRequest("https://playxcat.ru/storage/pumpkin.swf?v" + Math.random());
				var loader:Loader = new Loader();
				loader.name = String(i);
				loader.load(request);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, PumpkinLoadComplete);
			}

			// Reset array containing all avatars
			// It is used for sprites sorting purposes
			locationObjects = new Array();
			
			// Вырубаем выделение элементов на tab
			
			
			var i:int;
			var child, container;
			var mcHandler:MovieClip;
			var btnHandler:SimpleButton;
			
			container = _mc.dynamicObjects;
			
			for(i = 0; i < container.numChildren; i++)
			{
				child = container.getChildAt(i);
				
				locationObjects.push(child);
				
				if(child is InteractiveObject) 
					child.tabEnabled = false;
					
				if (child.name.indexOf("_dm") >= 0)
				{
					mcHandler = child as MovieClip;
					mcHandler.mouseEnabled = false;
				}
				if (child.name.indexOf("gminfo") >= 0)
				{
					mcHandler = child as MovieClip;
					mcHandler.stop();
					mcHandler.buttonMode = true;
					trace("kinder");
				}
			}
			
			container = _mc.staticObjects;
			
			for(i = 0; i < container.numChildren; i++)
			{
				child = container.getChildAt(i);
				
				if(child is InteractiveObject) 
					child.tabEnabled = false;
					
				if (child.name.indexOf("gm") >= 0)
				{
					mcHandler = child as MovieClip;
					mcHandler.stop();
					mcHandler.buttonMode = true;
				}
				
				if (child.name.indexOf("pp_streetwear") >= 0)
				{
					btnHandler = child as SimpleButton;
					
					btnHandler.addEventListener(MouseEvent.CLICK, ppStreetwearClick);
				}
				
				if (child.name.indexOf("pp_catbox") >= 0)
				{
					btnHandler = child as SimpleButton;
					
					btnHandler.addEventListener(MouseEvent.CLICK, ppCatboxClick);
				}
				
			}
			
			function ppStreetwearClick(event:MouseEvent):void
			{				
				var dataLoadingScreen:DataLoadingScreen = new DataLoadingScreen();
				dataLoadingScreen.name = "dls"
				Main.main.addChild(dataLoadingScreen);
				
				Main.sfs.send(new ExtensionRequest("streetwear.data"));
			}
			
			function ppCatboxClick(event:MouseEvent):void
			{				
				var dataLoadingScreen:DataLoadingScreen = new DataLoadingScreen();
				dataLoadingScreen.name = "dls"
				Main.main.addChild(dataLoadingScreen);
				
				Main.sfs.send(new ExtensionRequest("catbox.data"));
			}
			
			// Create avatars of users in new room
			for each (var u:User in _room.userList)
			{
				createAvatar(u);
			}
			arrangeObjects();

			Main.gameScreen.addChildAt(_mc,0);
		}
		
		public function destroy():void
		{
			Main.sfs.removeEventListener(SFSEvent.USER_VARIABLES_UPDATE, sfsUserVarsUpdate);
			Main.sfs.removeEventListener(SFSEvent.USER_EXIT_ROOM, sfsUserExitRoom);
			Main.sfs.removeEventListener(SFSEvent.PUBLIC_MESSAGE, sfsPublicMessage);
			
			_mc.removeEventListener(MouseEvent.MOUSE_DOWN, locationMouseDown);
								
			for each (var user:User in _room.userList)
				removeAvatar(getAvatar(user.id));
			
			Main.gameScreen.destroySound();
			Main.gameScreen.removeChild(_mc);
		}
		
		public function locationMouseDown(event:MouseEvent):void
		{
			
			var ht:Boolean = false;
			var invis:Boolean;
			
			
			for each (var u:User in _room.userList)
			{
				if(u.containsVariable("invisible"))
				{
					invis = u.getVariable("invisible").getBoolValue();
				}
				else
				{
					invis = false;
				}
				
				// фикс хуй знает чего
				if(getAvatar(u.id))
					if(getAvatar(u.id).avatar.hitTestPoint(event.stageX, event.stageY, true) && !u.isItMe && !invis)
					   ht = true;
			}
			
			for each (var DO:DisplayObject in _mc.dynamicObjects)
			{
				var mcHandler:MovieClip;
				
				if (DO.name.indexOf("gminfo") >= 0)
				{
					if(DO.hitTestPoint(event.stageX, event.stageY, true))
					{
						var popup:PopupTicTacToeRules = new PopupTicTacToeRules();
						popup.overlay.addEventListener(MouseEvent.CLICK, btnOverlayClick);
						popup.name = "popupTicTacToeRules";
						Main.main.addChild(popup);
						
						function btnOverlayClick(event:MouseEvent):void
						{					
							Main.main.removeChild(Main.main.getChildByName("popupTicTacToeRules"));
						}
						
						//ht = true;
					}
				}
			}
			
			//halloween quest
			for each (var mc:MovieClip in locationObjects)
			{
				var mcHandler:MovieClip;
				
				if (mc.name.indexOf("pumpkin") >= 0)
				{
					
					var params:ISFSObject = new SFSObject();
			        params.putInt("pumpkin", 1);

			        Main.sfs.send(new ExtensionRequest("halloween.open", params));
				}
			}
			
			for each (var DO:DisplayObject in _mc.staticObjects)
			{
				var mcHandler:MovieClip;
				
			}
			
			if(ht != true)
			{
				var myAvatar:Avatar = getAvatar(Main.sfs.mySelf.id);
				
				var clickPoint = new Point(event.stageX, event.stageY);
				var startPoint = new Point(myAvatar.x, myAvatar.y);
				var goPoint = moveZone(clickPoint,startPoint);
	
				setPosition(goPoint.x, goPoint.y);
			}
			
			trace('хуууууууууй', event.stageX, event.stageY, ht);
		}
		
		public function locationMouseMove(event:MouseEvent):void
		{
			var avatar:Avatar = getAvatar(Main.sfs.mySelf.id);
			
			var dir:String = getAvatarDirection(avatar,event.stageX,event.stageY);
			var myDir:String = Main.sfs.mySelf.properties["dir"];			
			
			if (myDir != dir && reqPos != dir)
			{
				reqPos = dir;
				setDirection(dir);
			}
		}
		
		private function getAvatar(userId:int):Avatar
		{
			var avatar:Avatar = _mc.dynamicObjects.getChildByName("avt_" + String(userId));
			return avatar;
		}
		
		private function createAvatar(user:User):void
		{
			// Only users with set coordinates have an avatar;
			if (user.containsVariable("pos_x") && user.containsVariable("pos_y"))
			{
				var color:String = user.getVariable("color").getStringValue();
				var scale:int = _room.getVariable("scale").getIntValue();
				var wear:Object = user.getVariable("wear").getSFSObjectValue().toObject();
				var dir:String = user.getVariable("dir").getStringValue();
				var badge:int = 0;
				if(user.containsVariable("badge"))
					badge = user.getVariable("badge").getIntValue();
				
				if(user.privilegeId == 0)
					scale += 20;
				   
				
				// Instantiate avatar
				var avatar:Avatar = new Avatar(user.id, user.name, color, scale, wear, dir, badge);
				
				avatar.x = user.getVariable("pos_x").getIntValue();
				avatar.y = user.getVariable("pos_y").getIntValue();

				// Add avatar to locationObjects container;
				if(!user.isItMe)
				{
					avatar.mouseEnabled = false;
					avatar.mouseChildren = true;
					avatar.lblName.mouseEnabled = false;
					avatar.bubble.mouseEnabled = false;
					avatar.badge.mouseEnabled = false;
					
					avatar.avatar.mouseEnabled = true;
					avatar.avatar.mouseChildren = false;
					
					avatar.avatar.addEventListener(MouseEvent.CLICK, avatarClick);
				}
				else
				{
					avatar.mouseEnabled = false;
					avatar.mouseChildren = false;
					
					//Main.main.removeChild(Main.main.getChildByName("loadingScreen"));
					_mc.addEventListener(MouseEvent.MOUSE_MOVE, locationMouseMove);
				}
				
				var invis:Boolean = false;
				
				if(user.containsVariable("invisible"))
					invis = user.getVariable("invisible").getBoolValue();
				
				setInvis(avatar, invis, false);
				if(invis)
				{
					if(Main.sfs.mySelf.isModerator() || Main.sfs.mySelf.isAdmin())
					{
						avatar.avatar.alpha = 0.5;
					}
					else
					{
						avatar.alpha = 0;
						avatar.avatar.removeEventListener(MouseEvent.CLICK, avatarClick);
					}
				}
				
				/*if(user.containsVariable("state"))
				{
					avatar.state = user.getVariable("state").getStringValue();
				}*/
				
				_mc.dynamicObjects.addChild(avatar);

				// Add avatar to array used for sorting
				locationObjects.push(avatar);

				arrangeObjects();
			}
			
		}
		
		private function createNPC(user:User):void
		{
			
		}
		
		private function removeAvatar(avatar:Avatar):void
		{
			avatar.removeEventListener(MouseEvent.CLICK, avatarClick);

			// Remove avatar from stage;
			_mc.dynamicObjects.removeChild(avatar);

			// Remove avatar from array used for sorting purposes
			var index:int = locationObjects.indexOf(avatar);
			locationObjects.splice(index, 1);
			
			avatar.destroy();
		}
		
		private function avatarClick(event:MouseEvent)
		{
			var dataLoadingScreen:DataLoadingScreen = new DataLoadingScreen();
			dataLoadingScreen.name = "dls";
			Main.main.addChild(dataLoadingScreen);
			
			var params:ISFSObject = new SFSObject();
			params.putUtfString("name", event.target.parent.lblName.text);
			 
			Main.sfs.send(new ExtensionRequest("profile", params));
			
			trace("Профиль", event.target.parent.lblName.text);
		}

		public function setPosition(pos_x:int, pos_y:int):void
		{
			//trace('setposition');
			/*var params:ISFSObject = new SFSObject();
			params.putInt("pos_x", pos_x);
			params.putInt("pos_y", pos_y);
			Main.sfs.send(new ExtensionRequest("uservars_set.position", params));*/
			
			
			 var userVars:Array = [];
			 userVars.push(new SFSUserVariable("pos_x", pos_x));
			 userVars.push(new SFSUserVariable("pos_y", pos_y));
			Main.sfs.send(new SetUserVariablesRequest(userVars));
		}
		
		private function setDirection(dir:String):void 
		{ 
			var userVars:Array = []; 
			userVars.push(new SFSUserVariable("dir", dir)); 
			Main.sfs.send(new SetUserVariablesRequest(userVars)); 
		}

		public function arrangeObjects():void
		{
			// Sort locationObjects based on their y coordinate
			locationObjects.sortOn("y", Array.NUMERIC);

			var i:int = locationObjects.length;

			while(i--)
				if(_mc.dynamicObjects.getChildIndex(locationObjects[i]) != i)
					_mc.dynamicObjects.setChildIndex(locationObjects[i], i);
		}
		
		private function moveZone(pos:Point, stP:Point):Point
		{
			var startPoint:Point = new Point(Math.round(stP.x),Math.round(stP.y)); 
			var distance:Number = Math.round(Point.distance(pos,startPoint)); 
			var xx:Number = (pos.x - startPoint.x)/distance; 
			var yy:Number = (pos.y - startPoint.y)/distance; 
			var endPoint:Point=startPoint.clone(); 
			for (var i = distance; i >0; i--) 
			{
				var yy2:Number=endPoint.y+yy; 
				var xx2:Number=endPoint.x+xx;
				if (! _mc.moveArea.hitTestPoint(Math.round(xx2),Math.round(yy2),true) && Main.dzAllow == false) 
				{
					break; 
				}
				endPoint.x = xx2; 
				endPoint.y = yy2; 
			} 
			
			endPoint.x = Math.round(endPoint.x); 
			endPoint.y = Math.round(endPoint.y); 
			return endPoint; 
		}
		
		private var curdir;

		private function moveAvatar(avatar:Avatar, px:int, py:int, dir:String, isItMe:Boolean):void
		{	
			curdir = dir;
		
			if(avatar.x == px && avatar.y == py)
			{
				avatar.setDirection(dir);
			}
			else
			{
				// античит
				
				if(isItMe == true && Main.sfs.mySelf.privilegeId < 2)
					if(_mc.moveArea.x != 0 || _mc.moveArea.y != 0 || !_mc.moveArea.hitTestPoint(px,py, true))
						Main.sfs.send(new ExtensionRequest("ban"));
				
				
				if(TweenLite.getTweensOf(avatar, true).length != 0)
				{
					var tween:TweenLite = TweenLite.getTweensOf(avatar, true)[0];
					if(tween.vars.x == px && tween.vars.y == py)
						return;
				}
				
				var newdir = getAvatarDirection(avatar,px,py);
				avatar.setDirection(newdir);
				
				//if(isItMe)
				//	_mc.removeEventListener(MouseEvent.MOUSE_MOVE, locationMouseMove);
	
				var speed:Number = 150;
				var startPoint:Point = new Point(avatar.x,avatar.y);
				var endPoint:Point = new Point(px,py);
				var dis:Number = Point.distance(startPoint,endPoint);
				var time = dis / speed;
				
				TweenLite.to(avatar, time, {x:px, y:py, onUpdate:arrangeObjects, onComplete:tweenFinish});
				
				function tweenFinish():void
				{
					if(isItMe)
					{
						//_mc.addEventListener(MouseEvent.MOUSE_MOVE, locationMouseMove);
						avatar.setDirection(curdir);
						
						for each (var DO:DisplayObject in _mc.staticObjects)
						{
							if (DO.name.indexOf("pt_") >= 0 && DO.hitTestPoint(avatar.x,avatar.y,true))
							{								
								// фикс мз
								Main.sfs.removeEventListener(SFSEvent.USER_VARIABLES_UPDATE, sfsUserVarsUpdate);
								_mc.removeEventListener(MouseEvent.MOUSE_DOWN, locationMouseDown);
								
								var params:ISFSObject = new SFSObject();
								params.putInt("pointer_id", int(DO.name.slice(3)));
								Main.sfs.send(new ExtensionRequest("joinroom", params));
							}
							
							if (DO.name.indexOf("gm") >= 0 && DO.hitTestPoint(avatar.x,avatar.y,true))
							{
								var dataLoadingScreen:DataLoadingScreen = new DataLoadingScreen();
								dataLoadingScreen.name = "dls";
								Main.main.addChild(dataLoadingScreen);
								
								Main.sfs.send(new ExtensionRequest("joingame.tictactoe"));
							}
							
							if (DO.name.indexOf("pp_map") >= 0 && DO.hitTestPoint(avatar.x,avatar.y,true))
							{
								if(!Main.main.getChildByName("scrn_map"))
									var mapScreen:MapScreen = new MapScreen();
							}
						}
					}
				}
			}

		}

		private function getAvatarDirection(avatar:Avatar, px, py):String
		{
			var avatarDirection, distX, distY, calc;
			
			distX = px - avatar.x;
			distY = py - avatar.y;
			
			calc = Math.atan2(-distY,distX);
			
			if (calc > -7 * Math.PI / 8 && calc <= -5 * Math.PI / 8)
				avatarDirection = "SW";
			else if (calc > -5 * Math.PI / 8 && calc <= -3 * Math.PI / 8)
				avatarDirection = "S";
			else if (calc > -3 * Math.PI / 8 && calc <= (-Math.PI) / 8)
				avatarDirection = "SE";
			else if (calc > (-Math.PI) / 8 && calc <= Math.PI / 8)
				avatarDirection = "E";
			else if (calc > Math.PI / 8 && calc <= 3 * Math.PI / 8)
				avatarDirection = "NE";
			else if (calc > 3 * Math.PI / 8 && calc <= 5 * Math.PI / 8)
				avatarDirection = "N";
			else if (calc > 5 * Math.PI / 8 && calc <= 7 * Math.PI / 8)
				avatarDirection = "NW";
			else
				avatarDirection = "W";

			return avatarDirection;
		}
		
		private function setInvis(avatar:Avatar, enable:Boolean = true, anim:Boolean = true):void
		{	
			if(playersVisible)
			{
				if(avatar.getChildByName("anim"))
					avatar.removeChild(avatar.getChildByName("anim"));
					
				if(anim)
				{
					var animInvisible:AnimInvisible = new AnimInvisible();
					animInvisible.name = "anim";
					animInvisible.y = -82.5;
					
					avatar.addChild(animInvisible);
				}
				
				if(enable)
				{
					if(!Main.sfs.mySelf.isModerator() && !Main.sfs.mySelf.isAdmin())
					{
						if(anim)
							TweenLite.to(avatar, 0.4, {visible:false, alpha:0, onComplete:tweenFinish});
						else
						{
							avatar.visible = false;
							avatar.alpha = 0;
						}
						
						avatar.avatar.removeEventListener(MouseEvent.CLICK, avatarClick);
					}
					else
					{
						if(anim)
							TweenLite.to(avatar.avatar, 0.4, {alpha:0.5, onComplete:tweenFinish});
						else
							avatar.avatar.alpha = 0.5;
					}
				}
				else
				{
					avatar.avatar.addEventListener(MouseEvent.CLICK, avatarClick);
					
					if(!Main.sfs.mySelf.isModerator() && !Main.sfs.mySelf.isAdmin())
					{
						if(anim)
							TweenLite.fromTo(avatar, 0.4, {alpha:0, visible:true}, {alpha:1, onComplete:tweenFinish});
						else
						{
							avatar.alpha = 1;
							avatar.visible = true;
						}
						
						//avatar.avatar.addEventListener(MouseEvent.CLICK, avatarClick);
					}
					else
					{
						if(anim)
							TweenLite.to(avatar.avatar, 0.4, {alpha:1, onComplete:tweenFinish});
						else
						{
							avatar.avatar.alpha = 1;
						}
					}
				}
			
			}
			else
			{
				avatar.mouseEnabled = false;
				avatar.mouseChildren = false;
				avatar.visible = false;
			}
			
			
			function tweenFinish():void
			{
				avatar.removeChild(animInvisible);
			}
		}
		
		public function showPlayers(show:Boolean = true):void
		{
			playersVisible = show;
			
			for each (var user:User in _room.userList)
				if(getAvatar(user.id))
				{
					var avatar:Avatar = getAvatar(user.id);
					
					if(show)
					{
						if(!user.isItMe)
						{
							avatar.mouseEnabled = false;
							avatar.mouseChildren = true;
							avatar.lblName.mouseEnabled = false;
							avatar.bubble.mouseEnabled = false;
							avatar.badge.mouseEnabled = false;
							
							avatar.avatar.mouseEnabled = true;
							avatar.avatar.mouseChildren = false;
							
							avatar.avatar.addEventListener(MouseEvent.CLICK, avatarClick);
						}
						else
						{
							avatar.mouseEnabled = false;
							avatar.mouseChildren = false;
							
							//Main.main.removeChild(Main.main.getChildByName("loadingScreen"));
							//_mc.addEventListener(MouseEvent.MOUSE_MOVE, locationMouseMove);
						}
						
						avatar.visible = true;
						
						var invis:Boolean = false;
						
						if(user.containsVariable("invisible"))
							invis = user.getVariable("invisible").getBoolValue();
						
						setInvis(avatar, invis, false);
					}
					else
					{
						setInvis(avatar);
						
						avatar.removeEventListener(MouseEvent.CLICK, avatarClick);
					}
				}
		}
			
		
		
		private function sfsPublicMessage(event:SFSEvent):void
		{
			var sender:User = event.params.sender;
			var msg:String = event.params.message;
			var invis:Boolean = false;
			
			if(sender.containsVariable("invisible"))
				invis = sender.getVariable("invisible").getBoolValue();

			if(!invis || (invis && (Main.sfs.mySelf.isModerator() || Main.sfs.mySelf.isAdmin())))
			{
				trace(sender + ": " + msg);
				
				var avatar:Avatar = getAvatar(sender.id);
				
				if(!avatar)
					return;
					
				if(msg.indexOf("#BUBBLE#::") >= 0)
				{
					avatar.setBubble(msg.substr(10), true);
				}
				else
				{
					avatar.setBubble(msg);
					Main.gameScreen.chpAddMessage(sender.name, msg);
				}
			}
		}
		
		//halloween quest
		private function PumpkinLoadComplete(event:Event):void
		{
			event.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, PumpkinLoadComplete);
			
			var object:MovieClip = event.target.loader.content.object as MovieClip;
			
			trace(object, _room.getVariable("scale").getIntValue());
			var pumpkin:Pumpkin = new Pumpkin(object, _room.getVariable("scale").getIntValue());

			pumpkin.x = _room.getVariable("pumpkin").getSFSObjectValue().getInt("x");
			pumpkin.y = _room.getVariable("pumpkin").getSFSObjectValue().getInt("y");
			pumpkin.name = "pumpkin";
			
			locationObjects.push(pumpkin);
			_mc.dynamicObjects.addChild(pumpkin);

			arrangeObjects();

			var pmpkn = _mc.dynamicObjects.getChildByName("pumpkin") as Pumpkin;
			pmpkn.buttonMode = true;			
			pmpkn.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent) { trace("kek"); });
			pmpkn.open(Math.round(Math.random()*4));
		}

		private function sfsUserVarsUpdate(event:SFSEvent):void
		{
			var changedVars:Array = event.params.changedVars as Array;
			var user:User = event.params.user as User;
			
			trace('updateVars', user.name, changedVars.toString());
			
			if(!getAvatar(user.id))
			{
				if(user.isJoinedInRoom(_room))
				{
					createAvatar(user);
				}
			}
			else
			{
				var avatar:Avatar = getAvatar(user.id);
				
				// смена одежды
				if (changedVars.indexOf("wear") != -1)
				{
					avatar.setWear(user.getVariable("wear").getSFSObjectValue().toObject());
				}
				
				// смена позиции
				if (changedVars.indexOf("pos_x") != -1 || changedVars.indexOf("pos_x") != -1 || changedVars.indexOf("dir") != -1)
				{
					var px:int = user.getVariable("pos_x").getIntValue();
					var py:int = user.getVariable("pos_y").getIntValue();
					var dir:String = user.getVariable("dir").getStringValue();
											
					moveAvatar(avatar, px, py, dir, user.isItMe);
				}
				
				// ожидание игры
				if (changedVars.indexOf("state") != -1)
				{
					avatar.state = user.getVariable("state").getStringValue()
					
					if(user.isItMe)
					{
						if(user.getVariable("state").getStringValue() == "")
						{
							_mc.addEventListener(MouseEvent.MOUSE_DOWN, locationMouseDown);
							_mc.addEventListener(MouseEvent.MOUSE_MOVE, locationMouseMove);
						}
						else
						{
							setPosition(avatar.x, avatar.y);
							setDirection("S");
							_mc.removeEventListener(MouseEvent.MOUSE_DOWN, locationMouseDown);
							_mc.removeEventListener(MouseEvent.MOUSE_MOVE, locationMouseMove);
						}
					}
				}
				
				// смена денег
				if (changedVars.indexOf("balance_regular") != -1 && user.isItMe == true)
				{
					Main.gameScreen.setBalanceRegular(String(user.getVariable("balance_regular").getIntValue()));
				}
				
				// смена денег
				if (changedVars.indexOf("balance_donate") != -1 && user.isItMe == true)
				{
					Main.gameScreen.setBalanceDonate(String(user.getVariable("balance_donate").getIntValue()));
				}
				
				// инвиз
				if (changedVars.indexOf("invisible") != -1)
				{
					setInvis(avatar, user.getVariable("invisible").getBoolValue());
				}
				
			}
		}
		
		private function sfsUserExitRoom(event:SFSEvent):void
		{
			// фикс крестов
			if(event.params.room == _room)
			{
				trace('дестрой');
				
				var user:User = event.params.user;
				
				if (! user.isItMe)
				{
					var avatar:Avatar = getAvatar(user.id);
	
					if (avatar != null)
					{
						removeAvatar(avatar);
					}
				}
				else
					destroy();
			}
		}
	}
	
}
