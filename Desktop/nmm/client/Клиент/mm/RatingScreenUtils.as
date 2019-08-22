package mm {
	import com.smartfoxserver.v2.entities.Buddy;
	import flash.display.MovieClip;
	
	public class RatingScreenUtils {
		
		import flash.events.*;
		import com.smartfoxserver.v2.SmartFox;
		import com.smartfoxserver.v2.core.SFSEvent;
		import com.smartfoxserver.v2.entities.*;
		import com.smartfoxserver.v2.entities.data.*;
		import com.smartfoxserver.v2.entities.variables.*;
		import com.smartfoxserver.v2.requests.*;
		import com.smartfoxserver.v2.requests.buddylist.*;
		
		private static var ratingScreen:RatingScreen;
		private static var i;
		private static var ratinglist:SFSArray;

		public function RatingScreenUtils() {
			// constructor code
		}
		
		public static function init(params:SFSObject) {
			trace('Рейтинг');
			
			if(ratingScreen)
				if(Main.main.contains(ratingScreen))
					Main.main.removeChild(ratingScreen);
			
			ratingScreen = new RatingScreen();
			
			ratinglist = params.getSFSArray("rating") as SFSArray;
			
			//ratingScreen.name = "fs";
			
			//ratingScreen.screen.btnFriendlist.addEventListener(MouseEvent.CLICK, btnFriendlistClick);
			//ratingScreen.screen.btnIncomingRequests.addEventListener(MouseEvent.CLICK, btnIncomingRequestsClick);
			//ratingScreen.screen.btnOutcomingRequests.addEventListener(MouseEvent.CLICK, btnOutcomingRequestsClick);
			ratingScreen.overlay.addEventListener(MouseEvent.CLICK, overlayClick);
			//ratingScreen.screen.txtSearch.addEventListener(Event.CHANGE, txtSearchInput);
			ratingScreen.screen.lblUserRating.text += params.getInt("user_rating");
			
			for(i = 0; i < 10; i++)
			{
				var item:RatingListItem = new RatingListItem();
				
				item.lblPlace.text = i + 1;
				
				item.lblName.text = "-";
				
				if(ratinglist.getSFSObject(i))
					if(ratinglist.getSFSObject(i).getInt("rating") != 0)
						item.lblName.text = ratinglist.getSFSObject(i).getUtfString("username") + " - " + ratinglist.getSFSObject(i).getInt("rating") + " б.";
				
				item.y = 40.1 * i;
				
				ratingScreen.screen.list.addChild(item);
			}
			
			// проверка, загружается ли страница в первый раз
			if(!Main.main.contains(ratingScreen))
			{
				Main.main.removeChild(Main.main.getChildByName("dls"));
				Main.main.addChild(ratingScreen);
			}
		}
		
		private static function overlayClick(event:MouseEvent):void
		{
			Main.main.removeChild(ratingScreen);
		}

	}
	
}
