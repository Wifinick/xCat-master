package mm.BDay {
	import com.greensock.*;
	import flash.display.*;
	import flash.events.*;
	import mm.*;
	import mm.BDay.*;
	import mm.BDay.Elements.*;

	public class BDay extends MovieClip {
		private var M:Main;
		private var D:Dial;
		public function BDay(m:Main):void {
			M = m;
		}
		public function Init(e:MouseEvent):void {
			D = new Dial(M);
			D.name = 'Dialogue';
			M.stage.addChild(D);
		}
	}
}
