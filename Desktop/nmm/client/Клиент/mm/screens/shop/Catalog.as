package mm.screens.shop {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import com.smartfoxserver.v2.entities.data.ISFSArray;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import mm.screens.shop.CatalogItem;
	
	import com.greensock.*;
	import com.greensock.easing.*;
	
	public class Catalog extends MovieClip {
		
		private var pagesCount:int;
		private var pageNum:int = 1;
		private var catalog:ISFSArray;
		
		public function Catalog(params:ISFSArray)
		{
			catalog = params;
			
			pagesCount = params.size() / 15 + 1;
			
			sidebar.lblPage.text = pageNum + "/" + pagesCount;
			sidebar.btnNext.addEventListener(MouseEvent.CLICK, btnNextClick);
			sidebar.btnPrev.addEventListener(MouseEvent.CLICK, btnPrevClick);
			
			loadPage(pageNum, field);
		}
		
		private function btnNextClick(event:MouseEvent):void
		{
			if(pageNum < pagesCount)
			{
				pageNum++;
				sidebar.lblPage.text = pageNum + "/" + pagesCount;
				loadPage(pageNum, field);
			}
		}
		
		private function btnPrevClick(event:MouseEvent):void
		{
			if(pageNum > 1)
			{
				pageNum--;
				sidebar.lblPage.text = pageNum + "/" + pagesCount;
				loadPage(pageNum, field);
			}
		}
		
		private function loadPage(num:int, field):void
		{
			
			for(var k:int = field.numChildren - 1; k >= 0; k--)
				field.removeChildAt(k);
			
			for(var i:int = 0; i < 3; i++)
			{
				for(var j:int = 0; j < 5; j++)
				{
					if(!catalog.isNull(5 * i + j + 15 * (num - 1)))
					{
						var item:ISFSObject = catalog.getSFSObject(5 * i + j + 15 * (num - 1) );
						var sci:CatalogItem = new CatalogItem(item);
						
						sci.x = 158 * j;
						sci.y = 200 * i;
						
						if(item.getInt("balance_type_id") == 1)
							sci.mcIcon.gotoAndStop(16);
						else if(item.getInt("balance_type_id") == 2)
							sci.mcIcon.gotoAndStop(17);
						
						field.addChild(sci);
						sci.alpha = 0;
					
						TweenNano.to(sci, 0.3, {alpha:1, delay:0.05*(5 * i + j)});
						
					}
				}
				
			}
			
		}
	}
	
}
