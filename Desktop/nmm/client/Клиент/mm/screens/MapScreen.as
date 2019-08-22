package mm.screens {
	
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.*;
	import mm.Main;
	
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	import com.smartfoxserver.v2.requests.*;
	import com.smartfoxserver.v2.entities.Room;
	import com.smartfoxserver.v2.core.SFSEvent;
	
	import com.greensock.*;
	import com.greensock.plugins.TweenPlugin; 
	import com.greensock.plugins.VisiblePlugin;
	
	public class MapScreen extends MovieClip {
		
		
		public function MapScreen() {
			init();
		}
		
		private function init():void
		{
			this.name = "scrn_map";
			this.overlay.addEventListener(MouseEvent.CLICK, overlayClick);
			TweenPlugin.activate([VisiblePlugin]);
			
			for each (var DO:DisplayObject in this.screen)
			{
				var mcHandler:MovieClip;
				
				if (DO.name.indexOf("bubble") >= 0)
				{
					mcHandler = this.screen.getChildByName(DO.name) as MovieClip;
					mcHandler.visible = false;
				}
			}
			
			for each (var IO:InteractiveObject in this.screen)
			{
				var ioHandler:InteractiveObject;
				
				if (IO.name.indexOf("btn") >= 0)
				{
					ioHandler = this.screen.getChildByName(IO.name) as InteractiveObject;
					ioHandler.tabEnabled = false;
					
					ioHandler.addEventListener(MouseEvent.CLICK, btnClick);
					ioHandler.addEventListener(MouseEvent.MOUSE_OVER, btnOver);
					ioHandler.addEventListener(MouseEvent.MOUSE_OUT, btnOut);
				}
			}
			
			Main.main.addChild(this);
		}
		
		private function destroy():void
		{
			for each (var IO:InteractiveObject in this.screen)
			{
				var ioHandler:InteractiveObject;
				
				if (IO.name.indexOf("btn") >= 0)
				{
					ioHandler = this.screen.getChildByName(IO.name) as InteractiveObject;
					
					ioHandler.removeEventListener(MouseEvent.CLICK, btnClick);
					ioHandler.removeEventListener(MouseEvent.MOUSE_OVER, btnOver);
					ioHandler.removeEventListener(MouseEvent.MOUSE_OUT, btnOut);
				}
			}
			
			this.overlay.removeEventListener(MouseEvent.CLICK, overlayClick);
			Main.main.removeChild(this);
		}
		
		private function overlayClick(event:MouseEvent):void
		{
			destroy();
		}
		
		private function btnClick(event:MouseEvent):void
		{
			if(Main.sfs.lastJoinedRoom != event.target.name.slice(4))
			{				
				var params:ISFSObject = new SFSObject();
				params.putUtfString("location", event.target.name.slice(4));
				
				Main.sfs.send(new ExtensionRequest("joinroom", params));
			}
			
			this.destroy();
		}
		
		private function btnOver(event:MouseEvent):void
		{
			var loc:String =  event.target.name.slice(4);
			var bubble = this.screen.getChildByName("bubble_" + loc);
			var room:Room = Main.sfs.roomManager.getRoomByName(loc);
					
			bubble.lblName.text = room.getVariable("name_ru").getStringValue();
			bubble.lblCount.text = room.userCount.toString();
			
			TweenLite.killTweensOf(bubble);
			TweenLite.fromTo(bubble, 0.2, {visible:true, alpha:0}, {alpha:1});
		}
		
		private function btnOut(event:MouseEvent):void
		{
			var bubble = this.screen.getChildByName("bubble_" + event.target.name.slice(4));
			
			TweenLite.killTweensOf(bubble);
			TweenLite.to(bubble, 0.2, {visible:false, alpha:0});
		}
	}
	
}
