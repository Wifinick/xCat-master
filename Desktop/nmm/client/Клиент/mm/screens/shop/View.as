package mm.screens.shop {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import mm.entities.Avatar;
	import mm.Main
	
	public class View extends MovieClip {
		
		private var wear:Object;
		private var item:ISFSObject;
		
		public function View(shop:String, _item:ISFSObject)
		{
			item = _item;
			
			lblName.text = item.getUtfString("name");
			lblDescr.text = item.getUtfString("descr");
			
			var balance:String = (item.getInt("balance_type_id") == 1) ? "клубков" : "рыбок";
			lblPrice.text = item.getInt("price") + " " + balance;
			
			switch(shop)
			{
				case "streetwear": initWear(); break;
				case "catbox": initWear(); break;
			}
		}
		
		private function initWear():void
		{
			btnPrev.addEventListener(MouseEvent.CLICK, wearBtnPrev);
			btnNext.addEventListener(MouseEvent.CLICK, wearBtnNext);
			
			var wear:Object = [null,0,0,0,0,0];
			
			wear[item.getInt("type")] = item.getInt("id");
			trace(wear[item.getInt("type")]);
			
			//wear[item.getInt("type")] = 
			var avatar:Avatar = new Avatar(0, "", Main.sfs.mySelf.getVariable("color").getStringValue(), 230, wear); 
			avatar.x = 225;
			avatar.y = 425;
			
			
			mcShowcase.addChild(avatar);
		}
		
		private function wearBtnPrev(event:MouseEvent):void
		{
			var dirs:Array = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
			var avatar:Avatar = mcShowcase.getChildByName("avt_0") as Avatar;
			
			var dir:String = avatar.getDirection();
			if(dirs.indexOf(dir) == dirs.length - 1)
				dir = dirs[0];
			else
				dir = dirs[dirs.indexOf(dir) + 1];
			
			avatar.setDirection(dir);
		}
		
		private function wearBtnNext(event:MouseEvent):void
		{
			var dirs:Array = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
			var avatar:Avatar = mcShowcase.getChildByName("avt_0") as Avatar;
			
			var dir:String = avatar.getDirection();
			if(dirs.indexOf(dir) == 0)
				dir = dirs[dirs.length - 1];
			else
				dir = dirs[dirs.indexOf(dir) - 1];
			
			avatar.setDirection(dir);
		}
		
		
	}
	
}
