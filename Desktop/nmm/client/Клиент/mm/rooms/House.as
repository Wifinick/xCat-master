package mm.rooms {
	
	import mm.rooms.Location;
	import flash.display.MovieClip;
	import com.smartfoxserver.v2.entities.Room;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.display.Loader;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.smartfoxserver.v2.entities.data.ISFSArray;
	import mm.Main;
	import mm.screens.GameScreen;
	import com.smartfoxserver.v2.core.SFSEvent;
	import flash.events.MouseEvent;
	import mm.entities.Furniture;
	import flash.ui.Mouse;
	import flash.display.DisplayObject;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	import com.smartfoxserver.v2.requests.ExtensionRequest;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	import com.greensock.*;
	import com.greensock.easing.*;
	
	public class House extends Location {
				
		private var lc:Location;
		private var fr_count = 0;
				
		public function House(mc:MovieClip, room:Room) 
		{
			var loadingScreen:LoadingScreen = new LoadingScreen();
			loadingScreen.name = "loadingScreenFurniture";
			loadingScreen.lblProgress.text = "";
			loadingScreen.lblTarget.text = "Загрузка обстановки...";
			
			Main.main.addChild(loadingScreen);
			
			super(mc, room);
			lc = super;
			
			
			var furniture:ISFSArray = _room.getVariable("furniture").getSFSArrayValue();
			trace('фрсайзбля', furniture.size());
			loadingScreen.lblProgress.text = "0/" + furniture.size();
			
			if(furniture.size() > 0)
				setFurniture(furniture);
			else
				Main.main.removeChild(loadingScreen);
				
			var gs:GameScreen = Main.gameScreen as GameScreen;
			
			if(_room.getVariable("name_ru").getStringValue() == ("Дом " + Main.sfs.mySelf.name))
			{
				Main.sfs.addEventListener(SFSEvent.USER_EXIT_ROOM, sfsUserExitRoomHouse);
				gs.setHouseEditButton(true);
			}
			
			Main.sfs.addEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, roomVariablesUpdate);
		}
		
		private function roomVariablesUpdate(event:SFSEvent):void
		{
			var changedVars:Array = event.params.changedVars as Array;
			var room:Room = event.params.room as Room;
			
			trace('updateVars', room.name);
			
			if (changedVars.indexOf("furniture") != -1)
			{
				var furniture:ISFSArray = room.getVariable("furniture").getSFSArrayValue();
				
				setFurniture(furniture);
			}
		}
			
		private function setFurniture(fr:ISFSArray):void
		{
			arrangeContainer(_mc.dynamicObjects);
			arrangeContainer(_mc.staticObjects);
			
			for(var i = 0; i < fr.size(); i++)
			{
				var item:ISFSObject = fr.getSFSObject(i);
				var request:URLRequest = new URLRequest('https://playxcat.ru/storage/' + item.getUtfString("hash") + ".swf?v" + Math.random());
				var loader:Loader = new Loader();
				loader.name = String(i);
				loader.load(request);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, FurnitureLoadComplete);
			}
			
			function arrangeContainer(container:MovieClip)
			{
				for(var i:int = container.numChildren - 1; i >= 0; i--)
				{
					var child:DisplayObject = container.getChildAt(i);
	
					if (child.name.indexOf("frn") >= 0)
					{
						var fr:Furniture = child as Furniture;
						
						if(fr.type == 1)
							lc.locationObjects.splice(lc.locationObjects.indexOf(fr), 1);
						
						child.parent.removeChild(child);
					}
				}
			}
		}
		
		private function FurnitureLoadComplete(event:Event):void
		{
			event.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, FurnitureLoadComplete);
			
			var hash:String = event.target.loader.contentLoaderInfo.url.substr(29, 32);
			var object:MovieClip = event.target.loader.content.object as MovieClip;
			var item:ISFSObject = _room.getVariable("furniture").getSFSArrayValue().getSFSObject(event.target.loader.name);
			
			trace(object, item.getInt("id"), _room.getVariable("scale").getIntValue(), item.getInt("dir"), item.getInt("type"), hash);
			var furniture:Furniture = new Furniture(object, item.getInt("id"), _room.getVariable("scale").getIntValue(), item.getInt("dir"), item.getInt("type"), hash);
			
			/*trace('dir', item.getInt("dir"));
			object.graphic.gotoAndStop(item.getInt("dir"));
			object.x = item.getInt("pos_x");
			object.y = item.getInt("pos_y");
			object.scaleX = _room.getVariable("scale").getIntValue() / 100;
			object.scaleY = _room.getVariable("scale").getIntValue() / 100;
			object.name = "frn_" + item.getInt("id").toString();
			
			trace(item.getInt("dir"), item.getInt("type"));*/
			
			furniture.x = item.getInt("pos_x");
			furniture.y = item.getInt("pos_y");
			//furniture.name = "frn_" + item.getInt("id").toString();
			
			if(item.getInt("type") == 1)
			{
				_mc.dynamicObjects.addChild(furniture);
				lc.locationObjects.push(furniture);
				
			}
			else if(item.getInt("type") == 2)
				_mc.staticObjects.addChild(furniture);
			
			lc.arrangeObjects();
				
			if(Main.main.getChildByName("loadingScreenFurniture"))
			{
				var ls:LoadingScreen = Main.main.getChildByName("loadingScreenFurniture") as LoadingScreen;
				fr_count++;
				ls.lblProgress.text = fr_count + "/" + _room.getVariable("furniture").getSFSArrayValue().size();
				
				if(_room.getVariable("furniture").getSFSArrayValue().size() == fr_count)
					Main.main.removeChild(ls);
				
			}
			
		}
		
		private function sfsUserExitRoomHouse(event:SFSEvent):void
		{
			// фикс крестов
			if(event.params.room == _room)
			{
				var gs:GameScreen = Main.gameScreen as GameScreen;
			
				if(event.params.user.isItMe)
				{
					Main.sfs.removeEventListener(SFSEvent.USER_EXIT_ROOM, sfsUserExitRoomHouse);
					Main.sfs.removeEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, roomVariablesUpdate);
					
					if(_room.getVariable("name_ru").getStringValue() == ("Дом " + Main.sfs.mySelf.name))
					{
						// дестрой панели (cancel)
						//if(!Main.sfs.hasEventListener(SFSEvent.USER_VARIABLES_UPDATE)) // чек на выход из локи
						//{
							trace('дестрпан');
							//destroyDragFurniture();
							Main.gameScreen.destroyFurniturePanel();
				
							var dataLoadingScreen:DataLoadingScreen = new DataLoadingScreen();
							dataLoadingScreen.name = "dls";
							Main.main.addChild(dataLoadingScreen);
							
							cancelFurniture();
							Mouse.show();
						//}
						gs.setHouseEditButton(false);
					}
				}
			}
		}
		
		/*private function destroyDragFurniture():void
		{
			arrangeContainer(_mc.dynamicObjects);
			arrangeContainer(_mc.staticObjects);
			
			trace('драддестр');
			
			function arrangeContainer(container:MovieClip)
			{
				for(var i:int = 0; i < container.numChildren; i++)
				{
					var child:DisplayObject = container.getChildAt(i);
					
					if (child.name.indexOf("frn") >= 0)
					{
						var fr:Furniture = child as Furniture;
						
						if(fr.hasEventListener(MouseEvent.MOUSE_UP))
						{
							// копипаст из маусап
							
							Main.gameScreen.showFurniturePanel(true);
			
							Mouse.show();
							
							fr.stopDrag();
							fr.removeChild(fr.getChildByName("fix"));
							
							fr.removeEventListener(MouseEvent.MOUSE_UP, furnitureMouseUp);
							fr.removeEventListener(MouseEvent.MOUSE_MOVE, furnitureMouseMove);
							if(fr.type == 1)
								fr.removeEventListener(MouseEvent.MOUSE_WHEEL, furnitureMouseWheel);
							
							if(checkFurniture(fr) != 1)
							{
								if(fr.type == 1)
									lc.locationObjects.splice(lc.locationObjects.indexOf(fr), 1);
								
								Main.gameScreen.furniturePanelAddItem(fr);
								
								fr.parent.removeChild(fr);
							}
							
							allowDragFurniture(true);
						}
					}
				}
			}
		}*/
		
		public function allowDragFurniture(allow:Boolean = true, currentFurniture:Furniture = null):void
		{
			arrangeContainer(_mc.dynamicObjects);
			arrangeContainer(_mc.staticObjects);
			
			function arrangeContainer(container:MovieClip)
			{
				for(var i:int = 0; i < container.numChildren; i++)
				{
					var child:DisplayObject = container.getChildAt(i);
					
					if (child.name.indexOf("frn") >= 0)
					{
						var fr:Furniture = child as Furniture;
						
						if(allow)
						{
							fr.buttonMode = true;
							fr.mouseEnabled = true;
							fr.addEventListener(MouseEvent.MOUSE_DOWN, furnitureMouseDown);
						}
						else
						{
							if(fr != currentFurniture)
							{
								fr.buttonMode = false;
								fr.mouseEnabled = false;
								fr.removeEventListener(MouseEvent.MOUSE_DOWN, furnitureMouseDown);
							}
						}
					}
				}
			}
		}
		
		public function addFurniture(mc:MovieClip, item:ISFSObject):void
		{			
			var fr:Furniture = new Furniture(mc, item.getInt("id"), _room.getVariable("scale").getIntValue(), 2, item.getInt("type"));
		
			fr.buttonMode = true;
			fr.mouseEnabled = true;
			fr.addEventListener(MouseEvent.MOUSE_DOWN, furnitureMouseDown);
			
			if(item.getInt("type") == 1)
			{
				_mc.dynamicObjects.addChild(fr);
				lc.locationObjects.push(fr);
				
			}
			else if(item.getInt("type") == 2)
				_mc.staticObjects.addChild(fr);
			
			dragFurniture(fr);
		}
		
		private function dragFurniture(fr:Furniture):void
		{
			Mouse.hide();
			
			fr.addEventListener(MouseEvent.MOUSE_UP,  furnitureMouseUp);
			fr.addEventListener(MouseEvent.MOUSE_MOVE, furnitureMouseMove);
			if(fr.type == 1)
				fr.addEventListener(MouseEvent.MOUSE_WHEEL, furnitureMouseWheel);
			
			var fix:MovieClip = new MovieClip();
			fix.graphics.beginFill(0x000000, 0);
			fix.graphics.drawCircle(0,0,100);
			fix.name = "fix";
			fix.y = fr.graphic.y;
			fr.addChild(fix);
			
			fr.x = Main.main.mouseX;
			fr.y = Main.main.mouseY - fr.graphic.y;
			fr.startDrag();
			
			checkFurniture(fr, false);
			allowDragFurniture(false, fr);
		}
		
		private function furnitureMouseDown(event:MouseEvent):void
		{
			Main.gameScreen.showFurniturePanel(false);
			
			var fr:Furniture = event.target as Furniture;
			dragFurniture(fr);
		}
		
		private function furnitureMouseUp(event:MouseEvent):void
		{
			Main.gameScreen.showFurniturePanel(true);
			
			Mouse.show();
			
			var fr:Furniture = event.target as Furniture;
			
			fr.stopDrag();
			fr.removeChild(fr.getChildByName("fix"));
			
			fr.removeEventListener(MouseEvent.MOUSE_UP, furnitureMouseUp);
			fr.removeEventListener(MouseEvent.MOUSE_MOVE, furnitureMouseMove);
			if(fr.type == 1)
				fr.removeEventListener(MouseEvent.MOUSE_WHEEL, furnitureMouseWheel);
			
			if(checkFurniture(fr) != 1)
			{
				if(fr.type == 1)
					lc.locationObjects.splice(lc.locationObjects.indexOf(fr), 1);
				
				Main.gameScreen.furniturePanelAddItem(fr);
				
				fr.parent.removeChild(fr);
			}
			
			allowDragFurniture(true);
		}
		
		private function furnitureMouseWheel(event:MouseEvent):void
		{
			var fr:Furniture = event.target as Furniture;
			
			if (event.delta > 0)
				fr.graphic.nextFrame();
			else
				fr.graphic.prevFrame();
		}
		
		private function furnitureMouseMove(event:MouseEvent):void
		{
			lc.arrangeObjects();
			
			var fr:Furniture = event.target as Furniture;
			
			if(fr.type == 2)
			{
				if(_mc.leftWallArea.hitTestPoint(fr.x, fr.y, true))
					fr.graphic.gotoAndStop(3);
				else if(_mc.rightWallArea.hitTestPoint(fr.x, fr.y, true))
					fr.graphic.gotoAndStop(1);
				else
					fr.graphic.gotoAndStop(2);
			}
			
			checkFurniture(fr);
		}
		
		private function checkFurniture(fr:Furniture, anim:Boolean = true):Number
		{
			var opacity:Number = 0.5;
			
			if( Main.dzAllow || (fr.type == 1 && _mc.moveArea.hitTestPoint(fr.x, fr.y, true)) || (fr.type == 2 && (_mc.leftWallArea.hitTestPoint(fr.x, fr.y, true) || _mc.centralWallArea.hitTestPoint(fr.x, fr.y, true) || _mc.rightWallArea.hitTestPoint(fr.x, fr.y, true))))
				opacity = 1;
			
			var a:Number;
			
			TweenLite.killTweensOf(fr);
			
			if(anim)
				TweenLite.to(fr, 0.2, {alpha:opacity});
			else
				fr.alpha = opacity;
				
			return opacity;
		}
		
		public function saveFurniture():void
		{
			var inventory:ISFSArray = new SFSArray();
			
			arrangeContainer(_mc.dynamicObjects);
			arrangeContainer(_mc.staticObjects);
			
			var params:ISFSObject = new SFSObject();
			params.putSFSArray("inventory", inventory);
			Main.sfs.send(new ExtensionRequest("furniture.set", params));
			
			function arrangeContainer(container:MovieClip)
			{
				for(var i:int = 0; i < container.numChildren; i++)
				{
					var child:DisplayObject = container.getChildAt(i);
	
					if (child.name.indexOf("frn") >= 0)
					{
						var fr:Furniture = child as Furniture;
						var item:ISFSObject = new SFSObject();
						
						item.putInt("id", fr._id);
						item.putInt("pos_x", fr.x);
						item.putInt("pos_y", fr.y);
						item.putInt("dir", fr.dir);
						item.putInt("type", fr.type);
						
						inventory.addSFSObject(item);
					}
				}
			}
		}
		
		public function cancelFurniture():void
		{
			var inventory:ISFSArray = _room.getVariable("furniture").getSFSArrayValue();
			var params:ISFSObject = new SFSObject();
			
			params.putSFSArray("inventory", inventory);
			Main.sfs.send(new ExtensionRequest("furniture.set", params));
		}
		
	}
	
}
