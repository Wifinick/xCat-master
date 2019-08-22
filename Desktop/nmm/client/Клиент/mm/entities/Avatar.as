package mm.entities
{

	import flash.display.MovieClip;
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.ColorTransform;
	import com.smartfoxserver.v2.entities.User;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import com.adobe.crypto.MD5;
	import flash.display.DisplayObject;

	import com.greensock.*;
	import com.greensock.easing.*;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.VisiblePlugin;
	import flash.sampler.Sample;

	public class Avatar extends MovieClip
	{

		private var R = 0,G = 0,B = 0;
		private const BIRTHDAY:Array = ['пиг','ильена','ксавье','кcaвье','xcat','поздравляю','с открытием','кутепов','цветной текст'];
		private var rTact:Boolean = false,gTact:Boolean = false,bTact:Boolean = false;
		private var _color:String;
		private var _dir:String;
		private var _badge:int;
		public var wear:Object;
		

		public function Avatar(id:int, name:String, color:String, scale:Number = 100, wearids:Object = null, dir:String = "S", badge = null)
		{
			this.name = "avt_" + String(id);

			this.lblName.text = name;
			this.lblName.autoSize = TextFieldAutoSize.CENTER;

			this.bubble.visible = false;

			//this.smoothing = true;
			//this.cacheAsBitmap = true;

			scale /=  100;
			this.scaleX = scale;
			this.scaleY = scale;

			_color = color;
			if (_color == "rainbow")
			{
				addEventListener(Event.ENTER_FRAME, colorUpdate);
			}
			
			_dir = dir;

			wear = new Object();
			for (var i:int = 1; i < 6; i++)
			{
				var loader:Loader = new Loader();
				loader.name = String(i);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, wearLoadComplete);
				wear[i] = loader;
			}
			
			_badge = badge;

			if (_badge)
			{
				this.badge.gotoAndStop(_badge);
				this.badge.x = -(this.lblName.width / 2) - 4;
				this.badge.visible = true;
			}

			//wearids = [0, 12, 0, 0, 0, 0];

			setWear(wearids);

			setDirection(dir);
		}

		public function destroy()
		{
			removeEventListener(Event.ENTER_FRAME, colorUpdate);

			for (var i:int = 1; i < 6; i++)
			{
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, wearLoadComplete);
			}
		}

		private function wearLoadComplete(event:Event):void
		{
			//wear[user.name][event.target.loader.name] = event.target.loader.content.wear;
			//wear[user.name][event.target.loader.name].cacheAsBitmap = true;

			//AvatarUtilities.setAvatarDirection(avatar, user.getVariable("dir").getStringValue());

			setDirection(_dir);
		}

		//др
		private function IfBirthday(msg:String):Boolean
		{
			for (var i:int; i < BIRTHDAY.length; i++)
			{
				if (msg.toLowerCase().indexOf(BIRTHDAY[i]) != -1)
				{
					return true;
				}
			}
			return false;
		}

		public function setBubble(msg:String, frameLabel:Boolean = false, autoRemove:Boolean = true, anim:Boolean = true):void
		{
			if (frameLabel)
			{
				this.bubble.gotoAndStop(msg);
			}
			else
			{
				var Format:TextFormat = new TextFormat();
				Format.color = (IfBirthday(msg) ? Math.random() * 0xFFFFFF : 0x00042B);

				this.bubble.gotoAndStop(1);

				this.bubble.message.defaultTextFormat = Format;
				this.bubble.message.text = msg;
				this.bubble.message.wordWrap = true;
				this.bubble.message.autoSize = TextFieldAutoSize.CENTER;

				this.bubble.background.height = this.bubble.message.height + 10;
				this.bubble.background.y =  -  this.bubble.background.height;
				this.bubble.message.y = this.bubble.background.y + 5;
			}

			this.bubble.y = -160;

			TweenLite.killTweensOf(this.bubble);
			if (anim)
			{
				TweenLite.fromTo(this.bubble, 0.3, {visible:true, alpha:0, y:"20"}, {alpha:1, y:"-20"});
			}
			else
			{
				this.bubble.alpha = 1;
				this.bubble.visible = true;
			}
			if (autoRemove)
			{
				TweenLite.to(this.bubble, 0.3, {delay:5.3, visible:false, alpha:0});
			}
		}

		public function removeBubble():void
		{
			TweenLite.killTweensOf(this.bubble);
			TweenLite.to(this.bubble, 0.3, {visible:false, alpha:0});
		}

		public function set state(state:String):void
		{
			if (state != "")
			{
				setDirection("S");
				setBubble(state, true, false, false);
			}
			else
			{
				removeBubble();
			}
		}

		public function setWear(wearids:Object):void
		{
			for (var id:String in wearids)
			{
				var value:Object = wearids[id];

				wearids = value;
			}
			if (wearids)
			{
				for (var i:int = 1; i < 6; i++)
				{
					trace(wearids[i]);
					var loader:Loader = wear[i] as Loader;

					// убираем с перса текущую одежду
					if (loader.content)
					{
						this.avatar.removeChild(MovieClip(loader.content).wear);
					}

					// загружаем новую, если требуется
					if (wearids[i] != 0)
					{
						if (loader.name == wearids[i])
						{
							setDirection(_dir);
						}
						else
						{
							loader.load(new URLRequest('https://playxcat.ru/gameres/ff07673105bd3e6790eaec3b1d9deb88/' + MD5.hash("wear_" + wearids[i]) + ".swf?v" + Math.random()));
							//loader.contentLoaderInfo.addEventListener(Event.COMPLETE, setWearColor);
						}
					}
					else
					{
						loader.unload();

					}
					loader.name = wearids[i];
				}
			}
		}
		
		function setWearColor(e:Event){
			var colorTrans = new ColorTransform();
			var wear:MovieClip = e.target.loader.content.wear;
			
			colorTrans.color = "0xffffff"
			
			wear.background.transform.colorTransform = colorTrans;
		}
		

		public function setColor(color:String):void
		{
			if (color)
			{
				_color = color;
				var colorTrans = new ColorTransform();

				if (_color == "rainbow")
				{
					colorTrans = new ColorTransform(1,1,1,1,R,G,B,1);
					addEventListener(Event.ENTER_FRAME, colorUpdate);
				}
				else
				{
					removeEventListener(Event.ENTER_FRAME, colorUpdate);
					colorTrans.color = _color;

				}
				this.avatar.character.background.transform.colorTransform = colorTrans;
			}
		}

		public function setBadge(badge:int):void
		{
			_badge = badge;
			if (badge && badge != 0)
			{
				this.badge.gotoAndStop(_badge);
				this.badge.x = -(this.lblName.width / 2) - 4;
				this.badge.visible = true;
			} else if (badge == 0) {
				this.badge.visible = false;
			}
		}

		public function getDirection():String
		{
			return _dir;
		}

		public function setDirection(dir:String):void
		{
			_dir = dir;

			this.avatar.gotoAndStop(dir);

			// загрузка одежды;
			for (var i = 5; i > 0; i--)
			{
				var loader:Loader = wear[i] as Loader;

				if (loader.content)
				{
					var mcHandler:MovieClip = MovieClip(loader.content).wear;

					mcHandler.gotoAndStop(dir);
					this.avatar.addChild(mcHandler);
				}
			}

			// установка цвеиа
			var colorTrans = new ColorTransform();

			if (_color == "rainbow")
			{
				colorTrans = new ColorTransform(1,1,1,1,R,G,B,1);
			}
			else
			{
				colorTrans.color = _color;

			}
			
			this.avatar.character.background.transform.colorTransform = colorTrans;
			
		}

		private function colorUpdate(event:Event):void
		{
			if (! rTact)
			{
				R++;
				if (R > 150)
				{
					rTact = true;
				}
			}
			else
			{
				R--;
				if (R < -150)
				{
					rTact = false;
				}
			}
			if (! gTact)
			{
				G++;
				if (G > 100)
				{
					gTact = true;
				}
			}
			else
			{
				G--;
				if (G < -100)
				{
					gTact = false;
				}
			}
			if (! bTact)
			{
				B++;
				if (R > 50)
				{
					bTact = true;
				}
			}
			else
			{
				B--;
				if (B < -50)
				{
					bTact = false;
				}
			}

			var colorTrans = new ColorTransform(1,1,1,1,R,G,B,1);
			this.avatar.character.background.transform.colorTransform = colorTrans;
		}
	}

}