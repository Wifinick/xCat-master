package mm.CalendarDay.Elements {
	import com.greensock.*;
	import flash.display.*;
	import flash.events.*;
	import mm.*;
	import mm.CalendarDay.*;
	import mm.CalendarDay.Elements.*;

	public class CWin extends MovieClip {
		private var M:Main;
		private var Today:Date;
		
		public function CWin(m:Main) {
			M = m;
			Today = new Date();
			this.Window.Today.mouseEnabled = false;
			trace(Today.getDay()+1);
			this.Window.Today.x = 120+((Today.getDay() == 0 ? 7 : Today.getDay())*70);
			this.Window.Today.y = 60+((int((Today.getDate()+(Today.getDay() == 0 ? 3 : 4))/7)+1)*80);
			this.Window.Today.visible = Today.getMonth() == 2;

			this.Close.addEventListener(MouseEvent.CLICK, CloseWin);
		}
		private function CloseWin(e:MouseEvent):void {
			TweenNano.to(this.Window, 0.3, {alpha: 0, y: 0});
			TweenNano.to(this.Close, 0.3, {alpha: 0, onComplete:function(){
				M.stage.removeChild(M.stage.getChildByName('Calendar'));
			}});
		}
	}
}
