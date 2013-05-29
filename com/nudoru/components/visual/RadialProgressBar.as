package com.nudoru.components.visual
{
	import com.nudoru.components.ComponentEvent;
	import com.nudoru.components.ComponentSettings;
	import com.nudoru.components.visual.skins.ASGradientSkin;
	import com.nudoru.visual.BMUtils;
	import flash.display.Sprite;


	/**
	 * Progress bar
	 * 
	 * Sample:
	 * 
	import com.nudoru.components.NudoruRadialProgressBar;

	var rbar:NudoruRadialProgressBar = new NudoruRadialProgressBar();
	rbar.x = 10;
	rbar.y = 450;
	rbar.initialize({
	radius:25,
	size:15,
	barcolor:0x00cc00, 
	progress:50,
	border:-5
	});
	rbar.render();
	this.addChild(rbar);
	rbar.addPopShadow(0xffffff);
	 */
	public class RadialProgressBar extends VisualComponent implements IVisualComponent
	{
		protected var _radius:int;
		protected var _size:int;
		protected var _barColor:Number;
		protected var _progress:int;
		protected var _border:int;
		protected var _segments:int = 50;
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

		/**
		 * 3.6 since there are 360 degrees in a circle. 100% = 100x3.6 = 360
		 */
		public function get progressDegrees():int
		{
			return progress * 3.6;
		}

		/**
		 * Segments in the arc, Higher is smoother
		 */
		public function get segments():int
		{
			return _segments;
		}

		public function set segments(value:int):void
		{
			_segments = value;
		}

		/**
		 * Constructor
		 */
		public function RadialProgressBar():void
		{
			super();
		}

		/**
		 * Initialize the view
		 */
		override public function initialize(data:*=null):void
		{
			super.initialize(data);
			
			_radius = data.radius;
			_size = data.size;
			_barColor = data.barcolor;
			_progress = data.progress;
			_border = data.border;

			if(! _size) _size = ComponentSettings.scrollBarSize;

			if(! _barColor) _barColor = ComponentSettings.colors[0];

			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INITIALIZED));
		}

		/**
		 * Draw the view
		 */
		override public function render():void
		{
			super.render();

			if(! _barFillSprite)
			{
				_barFillSprite = ComponentSettings.skin.createNegativeAreaRing({x:x, y:y, radius:_radius, size:_size, border:_border, segments:_segments});
				this.addChild(_barFillSprite);
			}

			if(_barSprite)
			{
				this.removeChild(_barSprite);
				_barSprite = null;
			}

			if(progressDegrees > 0)
			{
				_barSprite = ComponentSettings.skin.createArc({degrees:progressDegrees, radius:_radius, size:_size, segments:_segments, color:_barColor});
				this.addChild(_barSprite);
				BMUtils.applyGlowFilter(_barSprite, 0x000000, .5, 5, 1, false);
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