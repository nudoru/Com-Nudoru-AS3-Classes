package com.nudoru.components.visual
{
	import com.nudoru.components.ComponentEvent;
	import com.nudoru.components.ComponentSettings;
	import com.nudoru.components.visual.skins.ASGradientSkin;
	import flash.display.Sprite;


	/**
	 * Progress bar
	 * 
	 * Sample:
	 * 
	import com.nudoru.components.NudoruProgressBar;

	var b:NudoruProgressBar = new NudoruProgressBar();
	b.x = 100;
	b.y = 100;
	b.initialize({width:200, height:14, barcolor:0x00cc00, progress:50,border:0});
	b.render();
	this.addChild(b);
	 */
	public class LinearProgressBar extends VisualComponent implements IVisualComponent
	{
		protected var _pBarHeight:int;
		protected var _pBarWidth:int;
		protected var _barColor:Number;
		protected var _progress:int;
		protected var _mulitplier:Number;
		protected var _border:int;
		protected var _barFillSprite:Sprite;
		protected var _barSprite:Sprite;

		public function get progress():int
		{
			return _progress;
		}

		public function set progress(value:int):void
		{
			_progress = value;
			render();
		}

		public function get progressWidth():int
		{
			return progress * _mulitplier;
		}

		/**
		 * Constructor
		 */
		public function LinearProgressBar():void
		{
			super();
		}

		/**
		 * Initialize the view
		 */
		override public function initialize(data:*=null):void
		{
			super.initialize(data);

			_barColor = data.barcolor;
			_progress = data.progress;
			_border = data.border;

			if(!_height) _height = ComponentSettings.scrollBarSize;

			_pBarHeight = _height - (_border * 2);
			_pBarWidth = _width - (_border * 2);

			_mulitplier = _pBarWidth / 100;

			if(!_barColor) _barColor = ComponentSettings.colors[0];

			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INITIALIZED));
		}

		/**
		 * Draw the view
		 */
		override public function render():void
		{
			super.render();

			if(!_barFillSprite)
			{
				_barFillSprite = ComponentSettings.skin.createNegativeArea({x:0, y:0, width:_width, height:_height, radius:_height});
				_barFillSprite.alpha = .75;
				this.addChild(_barFillSprite);
			}

			if(_barSprite)
			{
				this.removeChild(_barSprite);
				_barSprite = null;
			}

			if(progressWidth > 0)
			{
				_barSprite = ComponentSettings.skin.createProgressBar({x:_border, y:_border, width:progressWidth, height:_pBarHeight, radius:_pBarHeight, color:_barColor});
				this.addChild(_barSprite);
			}

			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_RENDERED));
		}

		/**
		 * Update the display
		 */
		override public function update(data:*= null):void
		{
			progress = data.progress;
		}

		/**
		 * Remove event listeners and remove DisplayObjects from containters
		 */
		override public function destroy():void
		{
			this.removeChild(_barFillSprite);
			_barFillSprite = null;

			this.removeChild(_barSprite);
			_barSprite = null;

			super.destroy();
		}
	}
}