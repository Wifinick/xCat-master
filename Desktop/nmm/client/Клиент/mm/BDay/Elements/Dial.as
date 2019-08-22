package mm.BDay.Elements {
	import com.greensock.*;
	import flash.display.*;
	import flash.filters.*;
	import flash.events.*;
	import fl.transitions.easing.*;
	import mm.*;
	
	public class Dial extends MovieClip {
		private var M:Main;
		
		private const TEXT:Array = [[null, '\n\nУра! МиркоМир отмечает День Рождения!'], ['\n\nМы хотим на память снять праздничное видео.', null], ['\n\nС песнями, танцами и красивыми нарядами!', '\n\nИ шариками.'], ['\n\nПомоги нам, пожалуйста, снять моменты из списка.', '\nА после этого тебя ждёт\n сюрприз!'], ['\n\nЭтот блокнот поможет тебе в поисках.', null]];
		private const Glow:GlowFilter = new GlowFilter(0xFFFFFF, 1, 3, 3, 25, BitmapFilterQuality.HIGH, false, false);

		private var Step:int;
		public function Dial(m:Main):void {
			M = m;
			this.Close.addEventListener(MouseEvent.CLICK, CloseWin);
			this.Dialogue.Next.addEventListener(MouseEvent.CLICK, NextBubble);
			InitDialogue();
		}
		private function InitDialogue():void {
			var CurrentStep:Array = TEXT[Step];
			this.Dialogue.alpha = 0;
			this.Dialogue.y = 85;
			this.Dialogue.Next.y = (CurrentStep[0] && CurrentStep[1] ? 150 : 115);
			if(CurrentStep[0] && CurrentStep[1]){
				//Мила и Пушик
				this.Dialogue.Txt.text = CurrentStep[0];
				this.Dialogue.TwoTxt.text = CurrentStep[1];
				this.Dialogue.Bubble.gotoAndStop(3);
				this.Mila.filters = [Glow];
				this.Pushik.filters = [Glow];
				TweenNano.to(this.Mila, 0.5, {alpha: 1, y: 550});
				TweenNano.to(this.Pushik, 0.5, {alpha: 1, y: 550});
			}
			else if(CurrentStep[0]){
				//Мила
				this.Dialogue.Txt.text = CurrentStep[0];
				this.Dialogue.TwoTxt.text = '';
				this.Dialogue.Bubble.gotoAndStop(2);
				this.Mila.filters = [Glow];
				this.Pushik.filters = [];
				TweenNano.to(this.Mila, 0.5, {y: 550});
				TweenNano.to(this.Pushik, 0.5, {y: 575});
			}
			else if(CurrentStep[1]){
				//Пушик
				this.Dialogue.Txt.text = CurrentStep[1];
				this.Dialogue.TwoTxt.text = '';
				this.Dialogue.Bubble.gotoAndStop(1);
				this.Mila.filters = [];
				this.Pushik.filters = [Glow];
				TweenNano.to(this.Mila, 0.5, {y: 575});
				TweenNano.to(this.Pushik, 0.5, {y: 550});
			}
			TweenNano.to(this.Dialogue, 0.5, {alpha: 1, y: 60});
		}
		private function NextBubble(e:MouseEvent):void {
			TweenNano.to(this.Dialogue, 0.3, {alpha: 0, y: 35});
			if(Step + 1 < TEXT.length){
				Step++;
				InitDialogue();
			}
			else{
				CloseWin();
			}
		}
		private function CloseWin(e:MouseEvent=null):void {
			TweenNano.to(this.Dialogue, 0.3, {alpha: 0, y: 35});
			TweenNano.to(this.Mila, 0.3, {ease:Regular.easeOut, alpha: 0, y: 525});
			TweenNano.to(this.Pushik, 0.3, {ease:Regular.easeOut, alpha: 0, y: 525});
			TweenNano.to(this.Close, 0.3, {ease:Regular.easeOut, alpha: 0, onComplete:function(){
				M.stage.removeChild(M.stage.getChildByName('Dialogue'));
			}});
		}
	}
}
