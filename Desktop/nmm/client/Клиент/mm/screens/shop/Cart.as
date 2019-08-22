package mm.screens.shop {
	
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	import com.smartfoxserver.v2.entities.data.ISFSArray;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import mm.screens.shop.CartItem;
	import mm.ScrollBar;
	import mm.Main;
	import flash.events.MouseEvent;
	
	public class Cart extends MovieClip {
		
		private var items:ISFSArray = new SFSArray();
		private var scrollBar;
		
		public function Cart() {
			this.blendMode = BlendMode.LAYER;
			this.visible = false;
			
			scrollbar.area.slider.stop();
			scrollbar.mouseEnabled = false;
		}
		
		public function addItem(item:ISFSObject):void
		{
			var check:Boolean = false;
			
			for(var i:int = 0; i < items.size(); i++)
				if(items.getSFSObject(i).getInt("id") == item.getInt("id"))
				{
					check = true;
					break;
				}
			
			if(!check)
			{
				items.addSFSObject(item);
				updateItems();
			}
		}
		
		public function removeItem(id:int):void
		{
			for(var i:int = 0; i < items.size(); i++)
				if(items.getSFSObject(i).getInt("id") == id)
				{
					items.removeElementAt(i);
					updateItems();
					break;
				}
		}
		
		private function updateItems():void
		{
			for(var i:int = field.content.numChildren - 1; i >= 0; i--)
			{
				var ci:CartItem = field.content.getChildAt(i) as CartItem;
				var check:Boolean = false;
				
				for(var j:int = 0; j < items.size(); j++)
					if(items.getSFSObject(j).getInt("id").toString() == ci.name) // тут потом добавить чеккаунт (см в апдейтфурн)
					{
						check = true;
						break;
					}
				
				if(!check)
				{
					ci.btnRemove.removeEventListener(MouseEvent.CLICK, ciBtnRemoveClick);
					
					field.content.removeChild(ci);
					
					if(field.content.x <= -40)
					   field.content.x += 40;
				}
			}
			
			var mod:int = 0;
			
			for(var i:int = 0; i < items.size(); i++)
			{
				if(field.content.getChildByName(items.getSFSObject(i).getInt("id")))
				{
					var ci:CartItem = field.content.getChildByName(items.getSFSObject(i).getInt("id")) as CartItem;
					ci.y = mod*40;
					//ci.counter.lblCount.text = inv.getSFSObject(i).getInt("count"); потом добавить для мебели
					
					/*var colorTrans = new ColorTransform();
					
					if(mod%2 == 0)
						colorTrans.color = 0x7EB7BE
					else
						colorTrans.color = 0x68ABB3;
						
					fli.background.transform.colorTransform = colorTrans;*/
					field.content.setChildIndex(ci, 0);
				}
				else //if(inv.getSFSObject(i).getInt("count") > 0)
				{
					var ci:CartItem = new CartItem(items.getSFSObject(i));
					ci.y = mod*40;
					ci.btnRemove.addEventListener(MouseEvent.CLICK, ciBtnRemoveClick);
					
					/*fli.counter.visible = true;
					fli.counter.lblCount.text = inv.getSFSObject(i).getInt("count");
					
					var colorTrans = new ColorTransform();
					
					if(mod%2 == 0)
						colorTrans.color = 0x7EB7BE
					else
						colorTrans.color = 0x68ABB3;
						
					fli.background.transform.colorTransform = colorTrans;*/
					
					field.content.addChildAt(ci, 0);
				}
				
				//if(inv.getSFSObject(i).getInt("count") > 0)
					mod++;
			}
			
			if(field.content.numChildren == 0)
				lblEmpty.text = "Корзина пуста";
			else
				lblEmpty.text = "";
				
			if(field.content.height > field.mask.height)
			{
				scrollbar.mouseEnabled = true;
				
				if(scrollBar)
					scrollBar.destroy();
					
				scrollBar = new ScrollBar(field, scrollbar, Main.main.stage, 40);
			}
			
		}
		
		private function ciBtnRemoveClick(event:MouseEvent):void
		{
			removeItem(int(event.target.parent.name));
		}
	}
	
}
