package mm.utils
{
 
        import flash.display.Sprite;
 
        /**
         * @author      Maxim Sidorkin aka hitab
         * @site        http://byflasher.com/
         */
        public class Mask extends Sprite
        {
                private var _screen:Sprite;
                private var _x:Number;
                private var _y:Number;
                private var _width:Number;
                private var _height:Number;
 
                /**
                 * _screen - MovieClip или Sprite, для которого будет применена маска
                 * _width - ширина маски, если не установлена, то будет использована _screen.width (однако надо быть увереным, что _screen не пуст!)
                 * _height - высота маски, если не установлена будет использована _screen.height
                 * _x - положение макси по x
                 * _y - положение маски по y
                 */
                public function Mask(_screen:Sprite,  _width:Number = 0, _height:Number = 0, _x:Number = 0, _y:Number = 0)
                {
 
                        this._screen = _screen;
                        this._width = _width;
                        this._height = _height;
                        this._x = _x;
                        this._y = _y;
 
                        addMask();
                }
 
                private function addMask():void
                {
                        /*
                         * Убедитесь, что _screen.width и _screen.height не раны 0
                         */
                        _width  = _width  == 0  ? _screen.width  : _width;
                        _height = _height == 0  ? _screen.height : _height;
 
                        /*
                         * Рисуем черыхугольник для маски
                         */
                        graphics.beginFill(0x000000, 1);
                        graphics.drawRect(_x, _y, _width, _height);
                        graphics.endFill();
                        /*
                         * Добавляем маску в список отображения(при скэйлинге маска тоже будет скэйлится) и устанавливаем маску
                         */
                        _screen.addChild(this);
                        _screen.mask = this;
 
                }
 
        }
 
}