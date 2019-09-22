package mm.screens.shop
{

	import flash.display.MovieClip;
	import flash.events.*;
	import com.smartfoxserver.v2.entities.data.ISFSArray;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import mm.screens.shop.CatalogItem;

	import com.greensock.*;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	

	public class Catalog extends MovieClip
	{

		private var pagesCount:int;
		private var pageNum:int = 1;
		public var _catalog:ISFSArray;
		public var catalog:ISFSArray;
		private var printing:Timer;
		private var types:Array = [1,2,3,4,5];

		public function Catalog(params:ISFSArray)
		{
			_catalog = params;
			catalog = params;

			pagesCount = params.size() / 15 + 1;

			sidebar.price_biggest.text = "";

			sidebar.lblPage.text = pageNum + "/" + pagesCount;
			sidebar.btnNext.addEventListener(MouseEvent.CLICK, btnNextClick);
			sidebar.btnPrev.addEventListener(MouseEvent.CLICK, btnPrevClick);
			sidebar.txtSearch.addEventListener(Event.CHANGE, startTimer);
			sidebar.price_lowest.addEventListener(Event.CHANGE, startTimer);
			sidebar.price_biggest.addEventListener(Event.CHANGE, startTimer);


			checkboxInit();

			loadPage(pageNum, field, catalog);
		}

		private function checkboxInit():void
		{
			for (var i:uint = 0; i < sidebar.numChildren; i++)
			{
				if (sidebar.getChildAt(i).name.indexOf("cb_") >= 0)
				{
					sidebar.getChildAt(i).addEventListener(MouseEvent.CLICK, checkboxLogic);
				}
			}
		}

		private function checkboxLogic(event:MouseEvent):void
		{
			if (types.length == 1 && event.target.currentFrame == 1)
			{
				return;
			}
			updateTypes(int(event.target.name.substr(3)));

			event.target.gotoAndStop((event.target.currentFrame == 1) ? "false" : "true");
		}

		private function updateTypes(type:int):void
		{
			var typesLength:int = types.length;
			for (var i = 0; i < typesLength; i++)
			{
				if (types[i] == type)
				{
					types.splice(i, 1);
				}
			}
			if (typesLength == types.length)
			{
				types.push(type);
			}

			startTimer(null);
		}

		private function btnNextClick(event:MouseEvent):void
		{
			if (pageNum < pagesCount)
			{
				pageNum++;
				sidebar.lblPage.text = pageNum + "/" + pagesCount;
				loadPage(pageNum, field, catalog);
			}
		}

		private function btnPrevClick(event:MouseEvent):void
		{
			if (pageNum > 1)
			{
				pageNum--;
				sidebar.lblPage.text = pageNum + "/" + pagesCount;
				loadPage(pageNum, field, catalog);
			}
		}

		private function searchArgsEmpty():Boolean
		{
			var name = sidebar.txtSearch.text;
			var price_lowest = sidebar.price_lowest.text;
			var price_biggest = sidebar.price_biggest.text;

			if (name == "")
			{
				if (price_lowest == "" || price_biggest == "0")
				{
					if (price_biggest == "" || price_biggest == "0")
					{
						if (types.length == 5)
						{
							return true;
						}

					}
				}
			}
			return false;

		}

		private function startTimer(event:Event):void
		{
			var newCatalog:ISFSArray = new SFSArray();
			var byName:Boolean = sidebar.txtSearch.text != "";
			var atLowestPrice:Boolean = sidebar.price_lowest.text != "" && sidebar.price_lowest.text != "0";
			var atBiggestPrice:Boolean = sidebar.price_biggest.text != "" && sidebar.price_biggest.text != "0";

			if (searchArgsEmpty())
			{
				printing.stop();

				pagesCount = _catalog.size() / 15 + 1;
				sidebar.lblPage.text = pageNum + "/" + pagesCount;
				catalog = _catalog;

				return loadPage(pageNum, field, _catalog);
			}

			if (printing != null && printing.running)
				printing.stop();
			

			printing = new Timer(1000,1);
			printing.addEventListener(TimerEvent.TIMER_COMPLETE, search);

			printing.start();
		}

		public function search(e:TimerEvent)
		{
			var newCatalog:ISFSArray = new SFSArray();

			var name = sidebar.txtSearch.text;
			var price_lowest = sidebar.price_lowest.text;
			var price_biggest = sidebar.price_biggest.text;

			if (price_lowest != "" && price_biggest != "0")
			{
				if (price_biggest != "" && price_biggest != "0")
				{
					if (price_lowest > price_biggest)
					{
						sidebar.price_biggest.text = price_lowest;
					}

				}
			}
			pageNum = 1;

			for (var i = 0; i < _catalog.size(); i++)
			{
				if (name != "")
				{
					if (!(_catalog.getSFSObject(i).getUtfString("name").toLowerCase().indexOf(name.toLowerCase()) != -1))
					{
						continue;
					}

				}
				if (price_lowest != "" && price_biggest != "0")
				{
					if (!(_catalog.getSFSObject(i).getInt("price") >= price_lowest))
					{
						continue;
					}

				}
				if (price_biggest != "" && price_biggest != "0")
				{
					if (!(_catalog.getSFSObject(i).getInt("price") <= price_biggest))
					{
						continue;
					}


				}
				for (var j = 0; j < types.length; j++)
				{
					if (types[j] == _catalog.getSFSObject(i).getInt("type"))
					{
						newCatalog.addSFSObject(_catalog.getSFSObject(i));
					}
				}

			}
			catalog = newCatalog;


			if (catalog.size() == 0)
			{
				loadPage(pageNum, field, catalog);
				pagesCount = 0;
				sidebar.lblPage.text = "0";
				this.lblEmpty.visible = true;
				return;
			}
			
			this.lblEmpty.visible = false;

			loadPage(pageNum, field, catalog);
			pagesCount = catalog.size() / 15 + 1;
			sidebar.lblPage.text = pageNum + "/" + pagesCount;
		}


		public function loadPage(num:int, field, catalogData:ISFSArray):void
		{

			for (var k:int = field.numChildren - 1; k >= 0; k--)
			{
				field.removeChildAt(k);
			}

			for (var i:int = 0; i < 3; i++)
			{
				for (var j:int = 0; j < 5; j++)
				{
					if (!catalogData.isNull(5 * i + j + 15 * (num - 1)))
					{
						var item:ISFSObject = catalogData.getSFSObject(5 * i + j + 15 * (num - 1) );
						var sci:CatalogItem = new CatalogItem(item);

						sci.x = 158 * j;
						sci.y = 200 * i;

						if (item.getInt("balance_type_id") == 1)
						{
							sci.mcIcon.gotoAndStop(16);
						}
						else if (item.getInt("balance_type_id") == 2)
						{
							sci.mcIcon.gotoAndStop(17);

						}
						field.addChild(sci);
						sci.alpha = 0;

						TweenNano.to(sci, 0.3, {alpha:1, delay:0.05*(5 * i + j)});

					}
				}

			}
		}

	}

}