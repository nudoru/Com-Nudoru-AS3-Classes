package com.nudoru.components.visual
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.nudoru.accessibility.AccUtilities;
	import com.nudoru.components.ComponentEvent;
	import com.nudoru.components.ComponentSettings;
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
	public class Button extends VisualComponent implements IVisualComponent
	{
		protected var _stateUp:Sprite;
		protected var _stateOver:Sprite;
		protected var _stateDown:Sprite;
		protected var _stateDisabled:Sprite;
		protected var _labelTB:TextBox;
		protected var _iconSpr:Sprite;
		protected var _highlightSpr:Sprite;
		protected var _selectedRect:Sprite;
		protected var _selectedGutter:Sprite;
		protected var _showFace:Boolean;
		protected var _faceUpColor:Number;
		protected var _faceOverColor:Number;
		protected var _faceDownColor:Number;
		protected var _faceDisabledColor:Number;
		protected var _labelText:String;
		protected var _labelShadowColor:Number;
		protected var _labelWidth:int;
		protected var _labelX:int=-1;
		protected var _labelY:int=-1;
		protected var _fontName:String;
		protected var _fontSize:int;
		protected var _fontUpColor:Number;
		protected var _fontOverColor:Number;
		protected var _fontDownColor:Number;
		protected var _fontDisabledColor:Number;
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
		public function Button():void
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
			_faceUpColor = data.facecolor;
			_faceOverColor = int(data.facecolorover);
			_faceDownColor = int(data.facecolordown);
			_faceDisabledColor = int(data.facecolordisabled);
			_labelText = data.label;
			_labelShadowColor = data.labelshadowcolor;
			_borderWidth = data.borderSize;
			_icon = data.icon;
			_emphasis = isBool(data.emphasis);
			_fontName = data.font;
			_fontSize = int(data.size);
			_fontUpColor = int(data.color);
			_fontOverColor = int(data.colorover);
			_fontDownColor = int(data.colordown);
			_fontDisabledColor = int(data.colordisabled);
			_fontAlign = data.labelalign;
			_fontUnderline = isBool(data.underline);
			_toggle = isBool(data.toggle);

			validateData();

			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INITIALIZED));
		}

		override protected function validateData():void
		{
			if(!_faceUpColor) _faceUpColor = ComponentSettings.buttonColor;
			
			if(!_fontName) _fontName = ComponentSettings.fontName;
			if(!_fontSize) _fontSize = ComponentSettings.fontSize;
			// if there is not color defined and to make sure it's just not black
			if(!_fontUpColor && _initializationData.color != 0x000000) 
			{
				_fontUpColor = ComponentSettings.buttonLabelColor;
				// auto guess best label font color disabel in favor of getting it from settings
				//if(blackValue > 127) _fontColor = 0xffffff;
					//else _fontColor = 0x000000;
			}
			
			if(_faceUpColor == ComponentSettings.buttonColor)
			{
				if(!_faceOverColor) _faceOverColor = ComponentSettings.buttonOverColor;
				if(!_faceDownColor) _faceDownColor = ComponentSettings.buttonDownColor;
				if(!_faceDisabledColor) _faceDisabledColor = ComponentSettings.buttonDisabledColor;
				if(!_fontOverColor && _initializationData.colorover != 0x000000) _fontOverColor = ComponentSettings.buttonOverLabelColor;
				if(!_fontDownColor && _initializationData.colordown != 0x000000) _fontDownColor = ComponentSettings.buttonDownLabelColor;
				if(!_fontDisabledColor && _initializationData.colordisabled != 0x000000) _fontDisabledColor = ComponentSettings.buttonDisabledLabelColor;
			}
			else
			{
				if(!_faceOverColor) _faceOverColor = ColorUtils.getLighterColorBy(_faceUpColor, .05);
				if(!_faceDownColor) _faceDownColor = ColorUtils.getDarkerColorBy(_faceUpColor, .1);
				if(!_faceDisabledColor) _faceDisabledColor = ComponentSettings.buttonDisabledColor;
				if(!_fontOverColor && _initializationData.colorover != 0x000000) _fontOverColor = _fontUpColor;
				if(!_fontDownColor && _initializationData.colordown != 0x000000) _fontDownColor = _fontUpColor;
				if(!_fontDisabledColor && _initializationData.colordisabled != 0x000000) _fontDisabledColor = _fontUpColor;
			}
			
			var upLabelBlackValue:int = ColorUtils.convertHexToGreyScale(_fontUpColor);
			
			if(!_fontAlign) _fontAlign = "center";
			if(!_borderWidth) _borderWidth = ComponentSettings.buttonBorder;

			if(!_labelShadowColor) 
			{
				if(upLabelBlackValue > 127) _labelShadowColor = ColorUtils.getDarkerColorBy(_faceUpColor, 0.5);
					else _labelShadowColor = ColorUtils.getLighterColorBy(_faceUpColor, 0.5);
			}
		}

		/**
		 * Draw the view
		 */
		override public function render():void
		{
			super.render();

			_labelWidth = _width - (_borderWidth * 2);
			if(_icon)
			{
				_labelWidth -= _icon.width + _borderWidth;
			}

			_stateUp = createUpState();
			_stateOver = createOverState();
			_stateDown = createDownState();
			_stateDisabled = createDisabledState();

			_highlightSpr = ComponentSettings.skin.createHighlight({x:0, y:0, width:_width, height:_height});
			_highlightSpr.alpha = 0;

			if(_showFace) _highlightSpr.blendMode = BlendMode.HARDLIGHT;
				else _highlightSpr.blendMode = BlendMode.NORMAL;

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
	
			this.addChild(_stateDisabled);
			this.addChild(_stateDown);
			this.addChild(_stateOver);
			this.addChild(_stateUp);
			this.addChild(_selectedGutter);
			this.addChild(_highlightSpr);
			this.addChild(_iconSpr);
			this.addChild(_selectedRect);

			hideAllStates();
			_stateUp.visible = true;

			this.buttonMode = true;
			this.mouseChildren = false;
			this.addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
			this.addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);
			this.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			this.addEventListener(MouseEvent.MOUSE_UP, onUp);
			this.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);

			this.name = _labelText + " Button";

			setAccessibilityProperties(this, _labelText + " button", _labelText);

			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_RENDERED));
		}

		protected function createTextLabel(color:Number):Label
		{
			var label:Label = new Label();
			label.initialize({width:_labelWidth, 
				height:_height, 
				content:_labelText, 
				font:_fontName, 
				align:_fontAlign, 
				size:_fontSize, 
				underline:_fontUnderline,
				color:color});
			label.render();
			label.x = _borderWidth;
			label.addPopShadow(_labelShadowColor);
			return label;
		}

		protected function calculateLabelAlignment(label:Label):void
		{
			if(_icon && _icon.halign == "left") _labelX = _icon.width + (_borderWidth * 2);
				else _labelX = _borderWidth;
			if(_height)
			{
				_labelY = int((_height / 2) - (label.textHeight / 2));
			}
			else
			{
				_height = label.textHeight + (_borderWidth * 2);
				_labelY = _borderWidth;
			}
		}

		protected function createUpState():Sprite
		{
			var state:Sprite = new Sprite();
			var label:Label = createTextLabel(_fontUpColor);
			calculateLabelAlignment(label);
			label.x = _labelX;
			label.y = _labelY;
			var face:Sprite = ComponentSettings.skin.createButtonFaceUp({x:0, y:0, width:_width, height:_height, radius:ComponentSettings.buttonRadius, color:_faceUpColor, emphasis:_emphasis});			if(!_showFace) face.alpha = 0;
			state.addChild(face);
			state.addChild(label);
			return state;
		}

		protected function createOverState():Sprite
		{
			var state:Sprite = new Sprite();			
			var label:Label = createTextLabel(_fontOverColor);
			label.x = _labelX;
			label.y = _labelY;
			var face:Sprite = ComponentSettings.skin.createButtonFaceOver({x:0, y:0, width:_width, height:_height, radius:ComponentSettings.buttonRadius, color:_faceOverColor, emphasis:_emphasis});
			if(!_showFace) face.alpha = 0;
			state.addChild(face);
			state.addChild(label);
			return state;
		}
		
		protected function createDownState():Sprite
		{
			var state:Sprite = new Sprite();
			var label:Label = createTextLabel(_fontDownColor);
			label.x = _labelX;
			label.y = _labelY+1;
			var face:Sprite = ComponentSettings.skin.createButtonFaceDown({x:0, y:0, width:_width, height:_height, radius:ComponentSettings.buttonRadius, color:_faceDownColor, emphasis:_emphasis});
			if(!_showFace) face.alpha = 0;
			state.addChild(face);
			state.addChild(label);
			return state;
		}
		
		protected function createDisabledState():Sprite
		{
			var state:Sprite = new Sprite();
			var label:Label = createTextLabel(_fontDisabledColor);
			label.x = _labelX;
			label.y = _labelY;
			var face:Sprite = ComponentSettings.skin.createButtonFaceDisabled({x:0, y:0, width:_width, height:_height, radius:ComponentSettings.buttonRadius, color:_faceDisabledColor, emphasis:_emphasis});
			if(!_showFace) face.alpha = 0;
			state.addChild(face);
			state.addChild(label);
			return state;
		}

		protected function hideAllStates():void
		{
			_stateUp.visible = false;
			_stateOver.visible = false;
			_stateDown.visible = false;
			_stateDisabled.visible = false;
		}

		/**
		 * Button over
		 */
		protected function onRollOver(e:Event):void
		{
			if(!_enabled) return;

			if(_showFace)
			{
				hideAllStates();
				_stateOver.visible = true;
			}
			else
			{
				TweenMax.to(_highlightSpr, .25, {alpha:ComponentSettings.highlightMaxAlpha, ease:Quad.easeOut});
			}
			
			
			dispatchActivateEvent();
		}

		/**
		 * Button out
		 */
		protected function onRollOut(e:Event):void
		{
			if(!_enabled) return;

			if(_showFace)
			{
				hideAllStates();
				_stateUp.visible = true;
			}
			else
			{
				TweenMax.to(_highlightSpr, .5, {alpha:0, ease:Quad.easeOut});
			}
			
			dispatchDeactivateEvent();
		}

		protected function onDown(e:Event):void
		{
			if(!_enabled) return;

			if(_showFace)
			{
				hideAllStates();
				_stateDown.visible = true;
			}
			else
			{
				TweenMax.to(_highlightSpr, .5, {alpha:0, ease:Quad.easeOut});
			}
			
			dispatchDeactivateEvent();
		}
		
		
		protected function onUp(e:Event):void
		{
			if(!_enabled) return;

			if(_showFace)
			{
				hideAllStates();
				_stateUp.visible = true;
			}
			else
			{
				TweenMax.to(_highlightSpr, .5, {alpha:0, ease:Quad.easeOut});
			}
			
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
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
			this.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			this.removeEventListener(MouseEvent.CLICK, onClick);

			if(_icon)
			{
				_iconSpr.removeChildAt(0);
				_icon.symbol = null;
				_icon = null;
			}

			this.removeChild(_stateUp);
			this.removeChild(_stateOver);
			this.removeChild(_stateDown);
			this.removeChild(_stateDisabled);
			this.removeChild(_iconSpr);
			this.removeChild(_highlightSpr);
			this.removeChild(_selectedRect);
			this.removeChild(_selectedGutter);

			_stateUp = null;
			_stateOver = null;
			_stateDown = null;
			_stateDisabled = null;
			_highlightSpr = null;
			_selectedRect = null;
			_selectedGutter = null;
			_iconSpr = null;

			AccUtilities.exclude(this);

			super.destroy();
		}
	}
}