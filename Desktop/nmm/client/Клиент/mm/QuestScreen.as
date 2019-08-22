package mm {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import com.greensock.*;
	import com.greensock.easing.*;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	public class QuestScreen extends MovieClip {
		
		public function QuestScreen(container:Main) {
			
			container.addChild(this);
			
			this.overlay.addEventListener(MouseEvent.CLICK, overlayClick);
			this.btnQuest.addEventListener(MouseEvent.CLICK, questClick);
			this.btnPromo.addEventListener(MouseEvent.CLICK, promoClick);
			
			this.name = "questscr";
			this.alpha = 0;
			
			TweenNano.to(this, 0.2, {alpha:1});
		}
		
		private function destroy():void
		{			
			this.overlay.removeEventListener(MouseEvent.CLICK, overlayClick);
			this.btnQuest.removeEventListener(MouseEvent.CLICK, questClick);
			this.btnPromo.removeEventListener(MouseEvent.CLICK, promoClick);
			
			this.parent.removeChild(this);
		}
		
		private function overlayClick(event:MouseEvent):void
		{
			TweenNano.to(this, 0.2, {alpha:0, onComplete:destroy});
		}
		
		private function questClick(event:MouseEvent):void
		{
			navigateToURL(new URLRequest("https://krotyara.site"), "_blank");
		}
		
		private function promoClick(event:MouseEvent):void
		{
			navigateToURL(new URLRequest('https://playxcat.ru/promocode'), "_blank");
		}
	}
	
}
