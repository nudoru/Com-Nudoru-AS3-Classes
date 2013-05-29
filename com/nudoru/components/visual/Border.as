package com.nudoru.components.visual
{
	import com.nudoru.components.ComponentEvent;
	import com.nudoru.components.ComponentSettings;
	import com.nudoru.visual.drawing.GradBox;
	import com.nudoru.visual.drawing.RoundGradBox;
	import flash.display.BlendMode;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.MovieClip;



	/**
	 * Progress bar
	 * 
	 * Sample:
	 * 
		
	 */
	public class Border extends VisualComponent implements IVisualComponent
	{
		protected var _borderStyle:String;
		protected var _borderSize:int;
		protected var _colors:Array;
		protected var _borderMC:MovieClip;
		protected var _borderMCMetrics:Object;
		public static var NONE:String = "none";
		public static var MOVIECLIP:String = "movie_clip";
		public static var OUTLINE:String = "outline";
		public static var OUTLINE_J:String = "outline_j";
		public static var GRAD_SQUARE:String = "grad_square";
		public static var GRAD_ROUND:String = "grad_round";
		public static var SOLID_COLOR_RECT:String = "solid_color_rect";
		public static var SKIN_PANEL:String = "skin_panel";
		public static var SKIN_PANEL_EMPHASIS:String = "skin_panel_emphasis";

		/**
		 * Constructor
		 */
		public function Border():void
		{
			super();
		}

		/**
		 * Initialize the view
		 */
		override public function initialize(data:*=null):void
		{
			super.initialize(data);

			if(data.border is String)
			{
				_borderStyle = data.border;
				_borderSize = data.size;
				_colors = data.colors;

				if(! _borderSize) _borderSize = ComponentSettings.borderSize;
				if(! _borderStyle) _borderStyle = ComponentSettings.borderStyle;
				if(! _colors) _colors = ComponentSettings.colors;
			}
			else if(data.border is MovieClip)
			{
				_borderStyle = Border.MOVIECLIP;
				_borderMC = data.border;
				_borderMCMetrics = data.size;
			}
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INITIALIZED));
		}

		/**
		 * Draw the view
		 */
		override public function render():void
		{
			super.render();

			if(_borderStyle != Border.MOVIECLIP)
			{
				var halfBorder:int = _borderSize / 2;

				if(_borderStyle == Border.SOLID_COLOR_RECT)
				{
					this.graphics.beginFill(_colors[0],1);
					this.graphics.drawRect(-_borderSize, -_borderSize, _width+(_borderSize*2), _height+(_borderSize*2));
					this.graphics.endFill();
				}
				else if(_borderStyle == Border.SKIN_PANEL)
				{
					this.addChild(ComponentSettings.skin.createPanel({x:-_borderSize, y:-_borderSize, width:_width+(_borderSize*2), height:_height+(_borderSize*2), radius:undefined, color:_colors[0], outlinecolor:_colors[1], emphasis:false}));
				}
				else if(_borderStyle == Border.SKIN_PANEL_EMPHASIS)
				{
					this.addChild(ComponentSettings.skin.createPanel({x:-_borderSize, y:-_borderSize, width:_width+(_borderSize*2), height:_height+(_borderSize*2), radius:undefined, color:_colors[0], outlinecolor:_colors[1], emphasis:true}));
				}
				else if(_borderStyle == Border.GRAD_SQUARE)
				{
					var gb:GradBox = new GradBox(this, 0, 0, _width, _height, false, {bc:_colors[0]});
				}
				else if(_borderStyle == Border.GRAD_ROUND)
				{
					var rgb:RoundGradBox = new RoundGradBox(this, 0, 0, _width, _height, false, _borderSize, {bc:_colors[0]});
				}
				else if(_borderStyle == Border.OUTLINE)
				{
					this.graphics.lineStyle(_borderSize, _colors[0], 1, true, "normal", CapsStyle.SQUARE, JointStyle.MITER);
					this.graphics.drawRect(halfBorder, halfBorder, _width - _borderSize, _height - _borderSize);
				}
				else if(_borderStyle == Border.OUTLINE_J)
				{
					this.graphics.lineStyle(1, _colors[0], 1, true);
					this.graphics.drawRect(-halfBorder - 1, -halfBorder - 1, _width + (_borderSize + 1), _height + (_borderSize + 1));
					this.graphics.lineStyle(_borderSize, _colors[1], 1, true, "normal", CapsStyle.SQUARE, JointStyle.MITER);
					this.graphics.drawRect(halfBorder, halfBorder, _width - _borderSize, _height - _borderSize);
					this.blendMode = BlendMode.MULTIPLY;
				}
			}
			else
			{
				this.addChild(_borderMC);
			}
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_RENDERED));
		}

		/**
		 * Remove event listeners and remove DisplayObjects from containters
		 */
		override public function destroy():void
		{
			this.graphics.clear();

			if(_borderMC)
			{
				this.removeChild(_borderMC);
				_borderMC = null;
			}

			super.destroy();
		}
	}
}