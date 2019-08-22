package mm.CalendarDay {
	import com.greensock.*;
	import flash.display.*;
	import flash.events.*;
	import mm.*;
	import mm.CalendarDay.*;
	import mm.CalendarDay.Elements.*;

	public class Calendar extends MovieClip {
		private var M:Main;
		private var D:CWin;
		public function Calendar(m:Main):void {
			M = m;
		}
		public function Init(e:MouseEvent):void {
			D = new CWin(M);
			D.name = 'Calendar';
			D.Window.alpha = 0;
			D.Window.y = 50;
			D.Close.alpha = 0;
			M.stage.addChild(D);
			TweenNano.to(D.Window, 0.3, {alpha: 1, y: 25});
			TweenNano.to(D.Close, 0.3, {alpha: 1});
		}
	}
}