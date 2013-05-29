package com.nudoru.components.visual
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.nudoru.accessibility.AccUtilities;
	import com.nudoru.components.ComponentEvent;
	import com.nudoru.components.ComponentSettings;
	import com.nudoru.components.visual.skins.ASGradientSkin;
	import com.nudoru.utilities.ColorUtils;
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;


	/**
	 * Button
	 * 
	 * Sample:
	 * 
	var button:NudoruButton = new NudoruButton();
	button.initialize({
	width:100,
	// height:100,
	label:"Click Me",
	showface:true,
	font:"Verdana",
	size:12,
	// underline:true,
	color:0x333333,
	bordersize:5
	});
	button.render();
	button.x = 10;
	button.y = 350;
	this.addChild(button);

	button.addEventListener(NudoruComponentEvent.EVENT_CLICK, onButtonClick);
	function onButtonClick(e:NudoruComponentEvent):void
	{
	trace("You clicked me!");
	}
	 */
	public class SimpleButton extends VisualComponent implements IVisualComponent
	{
		protected var _shapeSpr:Sprite;
		protected var _labelTB:TextBox;
		protected var _iconSpr:Sprite;
		protected var _highlightSpr:Sprite;
		protected var _selectedRect:Sprite;
		protected var _selectedGutter:Sprite;
		protected var _showFace:Boolean;
		protected var _faceColor:Number;
		protected var _label:String;
		protected var _labelShadowColor:Number;
		protected var _fontName:String;
		protected var _fontSize:int;
		protected var _fontColor:int;
		protected var _fontUnderline:Boolean;
		protected var _fontAlign:String;
		protected var _emphasis:Boolean;
		protected var _icon:Object;
		protected var _toggle:Boolean;
		protected var _selected:Boolean = false;
		protected var _borderWidth:int;
		protected var _data:String;

		public function get data():String
		{
			return _data;
		}

		public function set data(value:String):void
		{
			_data = value;
		}

		public function set selected(value:Boolean):void
		{
			_selected = value;
			if(_toggle)
			{
				var sEvt:ComponentEvent;
				if(_selected)
				{
					showSelected();
					sEvt = new ComponentEvent(ComponentEvent.EVENT_SELECTED);
				}
				else
				{
					showUnselected();
					sEvt = new ComponentEvent(ComponentEvent.EVENT_UNSELECTED);
				}
				sEvt.data = data;
				dispatchEvent(sEvt);
			}
		}

		public function get selected():Boolean
		{
			return _selected;
		}

		public function get iconMC():MovieClip
		{
			if(_iconSpr)
			{
				return _iconSpr.getChildAt(0) as MovieClip;
			}
			return undefined;
		}

		/**
		 * Constructor
		 */
		public function SimpleButton():void
		{
			super();
		}

		/**
		 * Initialize the view
		 */
		override public function initialize(data:*=null):void
		{
			super.initialize(data);

			_showFace = isBool(data.showface);
			_faceColor = data.facecolor;
			_label = data.label;
			_labelShadowColor = data.labelshadowcolor;
			_borderWidth = data.borderSize;
			_icon = data.icon;
			_emphasis = isBool(data.emphasis);
			_fontName = data.font;
			_fontSize = int(data.size);
			_fontColor = int(data.color);
			_fontAlign = data.labelalign;
			_fontUnderline = isBool(data.underline);
			_toggle = isBool(data.toggle);

			if(!_faceColor) _faceColor = ComponentSettings.buttonColor;
			
			var faceBlackValue:int = ColorUtils.convertHexToGreyScale(_faceColor);
			
			if(!_fontName) _fontName = ComponentSettings.fontName;
			if(!_fontSize) _fontSize = ComponentSettings.fontSize;
			if(!_fontColor) 
			{
				_fontColor = ComponentSettings.buttonLabelColor;
				//if(blackValue > 127) _fontColor = 0xffffff;
					//else _fontColor = 0x000000;
			}
			
			var upLabelBlackValue:int = ColorUtils.convertHexToGreyScale(_fontColor);
			
			if(!_fontAlign) _fontAlign = "center";
			if(!_borderWidth) _borderWidth = int(ComponentSettings.borderSize / 2);

			if(!_labelShadowColor) 
			{
				if(upLabelBlackValue > 127) _labelShadowColor = ColorUtils.getDarkerColorBy(_faceColor, 0.5);
					else _labelShadowColor = ColorUtils.getLighterColorBy(_faceColor, 0.5);
			}

			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INITIALIZED));
		}

		/**
		 * Draw the view
		 */
		override public function render():void
		{
			super.render();

			var labelWidth:int = _width - (_borderWidth * 2);
			if(_icon)
			{
				labelWidth -= _icon.width + _borderWidth;
			}

			_labelTB = new TextBox();
			_labelTB.initialize({width:labelWidth, 
				height:_height, 
				content:_label, 
				font:_fontName, 
				align:_fontAlign, 
				size:_fontSize, 
				underline:_fontUnderline,
				color:_fontColor});
			_labelTB.render();
			_labelTB.x = _borderWidth;
			if(_icon && _icon.halign == "left") _labelTB.x = _icon.width + (_borderWidth * 2);
			if(_height)
			{
				_labelTB.y = int((_height / 2) - (_labelTB.textHeight / 2));
			}
			else
			{
				_height = _labelTB.textHeight + (_borderWidth * 2);
				_labelTB.y = _borderWidth;
			}
			_labelTB.addPopShadow(_labelShadowColor);

			_shapeSpr = ComponentSettings.skin.createButtonFaceUp({x:0, y:0, width:_width, height:_height, radius:ComponentSettings.buttonRadius, color:_faceColor, emphasis:_emphasis});
			
			// flip it so that the light color is at the top
			//_shapeSpr.rotation = 180;
			//_shapeSpr.x = _width;
			//_shapeSpr.y = _height;
			
			if(!_showFace) _shapeSpr.alpha = 0;

			_highlightSpr = ComponentSettings.skin.createHighlight({x:0, y:0, width:_width, height:_height});
			_highlightSpr.alpha = 0;

			_iconSpr = new Sprite();
			// icon:{symbol:new Smile(), width:16, height:16, halign:"left"},
			if(_icon)
			{
				_iconSpr.addChild(_icon.symbol as MovieClip);
				_iconSpr.x = _borderWidth;
				_iconSpr.y = int((_height / 2) - (_icon.height / 2));
				if(_icon.halign == "right") _iconSpr.x = _width - _borderWidth - _icon.width;
				if(_icon.valign == "top") _iconSpr.y = _borderWidth;
				if(_icon.valign == "bottom") _iconSpr.y = _height - _icon.height - _borderWidth;

				iconMC.gotoAndStop(1);
			}

			_selectedGutter = new Sprite();
			_selectedGutter.addChild(ComponentSettings.skin.createNegativeArea({x:0, y:0, width:_width, height:_height}));
			_selectedGutter.blendMode = BlendMode.MULTIPLY;
			_selectedGutter.alpha = 0;

			_selectedRect = new Sprite();
			_selectedRect.addChild(ComponentSettings.skin.createOutline({x:0, y:0, width:_width, height:_height, expand:-1, color:ComponentSettings.highlightColor}));
			_selectedRect.alpha = 0;

			this.addChild(_shapeSpr);
			this.addChild(_selectedGutter);
			this.addChild(_highlightSpr);
			this.addChild(_labelTB);
			this.addChild(_iconSpr);
			this.addChild(_selectedRect);

			/* MOVED TO SKIN
			 if(_emphasis)
			{
				this.addChild(ComponentSettings.skin.createOutline({x:0, y:0, width:_width, height:_height, expand:-1, color:ComponentSettings.highlightColor}));
			}*/

			this.buttonMode = true;
			this.mouseChildren = false;
			this.addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
			this.addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);
			this.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);

			this.name = _label + " Button";

			setAccessibilityProperties(this, _label + " button", _label);

			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_RENDERED));
		}

		/**
		 * Button over
		 */
		protected function onRollOver(e:Event):void
		{
			if(!_enabled) return;

			TweenMax.to(_highlightSpr, .25, {alpha:ComponentSettings.highlightMaxAlpha, ease:Quad.easeOut});
			//_shapeSpr.rotation = 0;
			///_shapeSpr.x = 0;
			///_shapeSpr.y = 0;

			dispatchActivateEvent();
		}

		/**
		 * Button out
		 */
		protected function onRollOut(e:Event):void
		{
			if(!_enabled) return;

			TweenMax.to(_highlightSpr, .5, {alpha:0, ease:Quad.easeOut});
			///_shapeSpr.rotation = 180;
			//_shapeSpr.x = _width;
			//_shapeSpr.y = _height;

			dispatchDeactivateEvent();
		}

		/**
		 * Button click
		 */
		protected function onClick(e:Event):void
		{
			if(!_enabled) return;

			dispatchClickEvent(data);

			if(_toggle)
			{
				if(selected) selected = false;
				else selected = true;
			}
		}

		override protected function showEnabled():void
		{
			super.showEnabled();
			TweenMax.to(_highlightSpr, .25, {alpha:0, ease:Quad.easeOut});
			this.buttonMode = true;
		}

		override protected function showDisabled():void
		{
			super.showDisabled();
			TweenMax.to(_highlightSpr, .25, {alpha:0, ease:Quad.easeOut});
			this.buttonMode = false;
		}

		/**
		 * Display the button in the selected state
		 */
		public function showSelected():void
		{
			iconMC.gotoAndStop("selected");
			TweenMax.to(_selectedGutter, .25, {alpha:.25, ease:Quad.easeOut});
			TweenMax.to(_selectedRect, .25, {alpha:1, ease:Quad.easeOut});
		}

		/**
		 * Display the button in the unselected state
		 */
		public function showUnselected():void
		{
			iconMC.gotoAndStop("unselected");
			TweenMax.to(_selectedGutter, .5, {alpha:0, ease:Quad.easeOut});
			TweenMax.to(_selectedRect, .5, {alpha:0, ease:Quad.easeOut});
		}

		/**
		 * Get the size of the component
		 * @return Object with width and heigh props
		 */
		override public function measure():Object
		{
			var mObject:Object = new Object();
			mObject.width = _width;
			mObject.height = _height;
			return mObject;
		}

		/**
		 * Remove event listeners and remove DisplayObjects from containters
		 */
		override public function destroy():void
		{
			this.removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
			this.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
			this.removeEventListener(MouseEvent.CLICK, onClick);

			if(_icon)
			{
				_iconSpr.removeChildAt(0);
				_icon.symbol = null;
				_icon = null;
			}

			_labelTB.destroy();
			this.removeChild(_labelTB);
			_labelTB = null;

			this.removeChild(_shapeSpr);
			this.removeChild(_iconSpr);
			this.removeChild(_highlightSpr);
			this.removeChild(_selectedRect);
			this.removeChild(_selectedGutter);

			_shapeSpr = null;
			_highlightSpr = null;
			_selectedRect = null;
			_selectedGutter = null;
			_iconSpr = null;

			AccUtilities.exclude(this);

			super.destroy();
		}
	}
}