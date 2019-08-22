package mm {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.display.Stage;
	import flash.geom.Rectangle;
	import fl.transitions.Tween;
	import fl.transitions.easing.None;
	import flash.events.Event;
	import fl.transitions.TweenEvent;
	
	import com.greensock.*;
	import com.greensock.easing.*;
	
	public class ScrollBar extends MovieClip {
		
		private var _field:MovieClip;
		private var _scrollBar:MovieClip;
		private var _stage:Stage;
		private var _step:Number = 10;
		private var _sizeModifer:Number;
		private var _horizontal:Boolean;
		
		private var contentSize:Number;
		private var maskSize:Number;
		private var trackSize:Number;
		
		private var fieldLength:Number;
		private var trackLength:Number;
		private var goStep:Number;

		public function ScrollBar(field:MovieClip, scrollBar:MovieClip, stage:Stage, step = null, addStep:Boolean = false, sizeModifer = 0, horizontal:Boolean = false)
		{
			
			_field = field;
			_scrollBar = scrollBar;
			_stage = stage;
			_sizeModifer = sizeModifer;
			_horizontal = horizontal;
			
			if(step)
				this._step = step;
			else
				step = (-fieldLength) / 10;
			
			if(horizontal)
			{
				contentSize = _field.content.width;
				maskSize = _field.mask.width;
				trackSize = _scrollBar.area.track.width;
			}
			else
			{
				contentSize = _field.content.height;
				maskSize = _field.mask.height;
				trackSize = _scrollBar.area.track.height;
			}
			
			if(-contentSize + maskSize < 0) 
				init(addStep);
		}
		
		private function get sliderSize():Number
		{
			var size:Number;
			
			if(_horizontal)
				size = _scrollBar.area.slider.width;
			else
				size = _scrollBar.area.slider.height
				
			return size;
		}
		
		private function set sliderSize(size:Number)
		{
			if(_horizontal)
				_scrollBar.area.slider.width = size;
			else
				_scrollBar.area.slider.height = size;
		}
		
		private function get sliderPos():Number
		{
			var pos:Number;
			
			if(_horizontal)
				pos = _scrollBar.area.slider.x;
			else
				pos = _scrollBar.area.slider.y
				
			return pos;
		}
		
		private function set sliderPos(pos:Number)
		{
			if(_horizontal)
				_scrollBar.area.slider.x = pos;
			else
				_scrollBar.area.slider.y = pos;
		}
		
		private function get contentPos():Number
		{
			var pos:Number;
			
			if(_horizontal)
				pos = _field.content.x;
			else
				pos = _field.content.y
				
			return pos;
		}
		
		private function set contentPos(pos:Number)
		{
			if(_horizontal)
				_field.content.x = pos;
			else
				_field.content.y = pos;
		}
		
		public function destroy():void
		{
			_scrollBar.down.removeEventListener(MouseEvent.CLICK, downClick);
			_scrollBar.up.removeEventListener(MouseEvent.CLICK, upClick);
			_scrollBar.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);
			_scrollBar.area.slider.removeEventListener(MouseEvent.MOUSE_DOWN, sliderMouseDown);
			_field.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);
		}
		
		private function init(addStep:Boolean = false):void
		{
			_scrollBar.down.useHandCursor = false;
			_scrollBar.up.useHandCursor = false;
			
			_scrollBar.area.slider.stop();
			_scrollBar.area.slider.buttonMode = true;
			_scrollBar.area.slider.useHandCursor = false;
			
			_scrollBar.down.addEventListener(MouseEvent.CLICK, downClick);
			_scrollBar.up.addEventListener(MouseEvent.CLICK, upClick);
			_scrollBar.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);
			_field.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);
			
			_scrollBar.area.slider.addEventListener(MouseEvent.MOUSE_DOWN, sliderMouseDown);
			
			fieldLength = - (contentSize - maskSize - _sizeModifer);
			
			//trace(fieldLength, _field.mask.height);
			
			if(fieldLength >= 0)
				sliderSize = trackSize;
			else
			{
				sliderSize = (maskSize / (contentSize - _sizeModifer)) * trackSize;
				
				if(sliderSize < 20)
					sliderSize = 20;
			}
			
			trackLength = trackSize - sliderSize;
			
			goStep = contentPos;
			
			if(addStep)
				goStep -= _step;
			
			sliderPos = (goStep *(trackLength))/(fieldLength);
		}
		
		private function downClick(event:MouseEvent):void
		{
			goStep -=  _step;
			scrollManage();
		}
		
		private function upClick(event:MouseEvent):void
		{
			goStep +=  _step;
			scrollManage();
		}
		
		private function mouseWheel(event:MouseEvent):void
		{
			if (event.delta > 0)
			{
				goStep +=  _step;
				scrollManage();
			}
			else
			{
				goStep -= _step;
				scrollManage();
			}
		}
		
		private function sliderMouseDown(event:MouseEvent):void
		{
			var bounds:Rectangle;
			if(_horizontal)
				bounds = new Rectangle(0,0,trackLength,0);
			else
				bounds = new Rectangle(0,0,0,trackLength);
			
			_scrollBar.area.slider.startDrag(false, bounds);

			_stage.mouseChildren = false;
			_stage.addEventListener(MouseEvent.MOUSE_UP, scrollSliderUp);
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, scrollSliderMove);
			
			//trace(- _field.content.height + _field.mask.height);

			function scrollSliderUp(event:MouseEvent):void
			{
				_scrollBar.area.slider.stopDrag();
				_stage.mouseChildren = true;
				_stage.removeEventListener(MouseEvent.MOUSE_UP, scrollSliderUp);
				_stage.removeEventListener(MouseEvent.MOUSE_MOVE, scrollSliderMove);
			}

			function scrollSliderMove(event:MouseEvent):void
			{
				//trace((_scrollBar.area.slider.y)/(trackSize - _scrollBar.area.slider.height));
				contentPos = fieldLength * (sliderPos / trackLength);
				goStep = contentPos;
			}
		}
		
		private function scrollManage():void
		{
			if (goStep > 0)
			{
				goStep = 0;
			}
			else if (goStep < fieldLength)
			{
				goStep = fieldLength;
			}
			
			var sliderGo = (goStep *(trackLength))/(fieldLength);

			if(_horizontal)
			{
				TweenLite.to(_field.content, 0.2, {x:goStep});
				TweenLite.to(_scrollBar.area.slider, 0.2, {x:sliderGo});
			}
			else
			{
				TweenLite.to(_field.content, 0.2, {y:goStep});
				TweenLite.to(_scrollBar.area.slider, 0.2, {y:sliderGo});
			}

		}

	}
	
}
