package com.nudoru.components.visual
{
	import flash.display.BlendMode;
	import com.greensock.TweenMax;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Quad;
	import com.nudoru.components.ComponentEvent;
	import com.nudoru.components.ComponentSettings;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	/**
	 * Scroll Bar
	 * 
	var sb:ScrollBar = new ScrollBar();
	sb.initialize({width:20,height:250,direction:ScrollBar.VERTICAL, targetSize:1000});
	sb.render();
	sb.x = 50;
	sb.y = 50;
	this.addChild(sb);
	sb.addEventListener(ScrollBarEvent.EVENT_SCROLL, onScroll);
	 */
	public class ScrollBar extends VisualComponent implements IVisualComponent
	{

		protected var _BarSize:int;
		protected var _Direction:String;
		protected var _ScrollPosition:int;
		
		protected var _BarOffsetMin:int = 0;
		protected var _BarOffsetMax:int = 0;
		
		protected var _Track:Sprite;
		protected var _TrackBorder:int;
		protected var _Thumb:Sprite;
		protected var _ThumbHighlight:Sprite;
		
		protected var _MinButton:Sprite;
		protected var _MaxButton:Sprite;
		protected var _ObjectSize:int;
		protected var _ThumbSize:int;
		protected var _TrackSize:int;
		protected var _ButtonSize:int;
		
		protected var _ScrollRatio:Number;
		
		protected var _ButtonScrollAmount:Number = .75;
		protected var _KeyBoardScrollAmount:int = 10;
		protected var _WheelScrollAmount:int = -2;
		
		protected var _OnMouseWheel:Boolean = true;
		
		protected var _ScrollingApplied:Boolean = false;
		
		protected var _ThumbColor:Number;
		
		protected var _IsActivelyScrolling:Boolean = false;
		
		public static var VERTICAL:String = "vertical";
		public static var HORIZONTAL:String = "horizontal";

		/**
		 * Current position of the scroll object
		 */
		public function get position():Number
		{
			var position:int;
			if(_Direction == ScrollBar.VERTICAL) position = scrollPosition;
				else position = scrollPosition;
			return  position / _TrackSize;
		}

		public function get objectToPosition():int
		{
			var position:int;
			if(_Direction == ScrollBar.VERTICAL) position = scrollPosition;
				else position = scrollPosition;
			return  _ScrollRatio * position * -1;
		}

		public function get scrollPosition():int
		{
			return _ScrollPosition;
		}

		public function set scrollPosition(scrollPosition:int):void
		{
			_ScrollPosition = scrollPosition;
			animateThumbToScrollPosition();
		}

		public function get buttonScrollAmount():Number
		{
			return _ButtonScrollAmount;
		}

		public function set buttonScrollAmount(buttonScrollAmount:Number):void
		{
			_ButtonScrollAmount = buttonScrollAmount;
		}

		public function get keyBoardScrollAmount():int
		{
			return _KeyBoardScrollAmount;
		}

		public function set keyBoardScrollAmount(keyBoardScrollAmount:int):void
		{
			_KeyBoardScrollAmount = keyBoardScrollAmount;
		}

		public function get wheelScrollAmount():int
		{
			return _WheelScrollAmount;
		}

		public function set wheelScrollAmount(wheelScrollAmount:int):void
		{
			_WheelScrollAmount = wheelScrollAmount;
		}
		
		/**
		 * Top most scroll position
		 */
		public function get scrollMin():Number
		{
			return 0;
		}

		/**
		 * Bottom most scroll position
		 */
		public function get scrollMax():Number
		{
			return _TrackSize - _BarOffsetMax;
		}

		public function get scrollOnMouseWheel():Boolean
		{
			return _OnMouseWheel;
		}

		public function set scrollOnMouseWheel(value:Boolean):void
		{
			_OnMouseWheel = value;
		}

		public function ScrollBar():void
		{
			super();
		}

		override public function initialize(data:*=null):void
		{
			super.initialize(data);

			_ObjectSize = data.targetSize;
			_Direction = data.direction;
			_ThumbColor = data.thumbcolor;
			_TrackBorder = int(data.border);
			
			if(_Direction == ScrollBar.VERTICAL) _BarSize = _width;
				else _BarSize = _height;
				
			_ButtonSize = _BarSize;

			validateData();

			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INITIALIZED));
		}

		override protected function validateData():void
		{
			if(!_ThumbColor) _ThumbColor = ComponentSettings.handleColor;
			if(!_BarSize) _BarSize = ComponentSettings.scrollBarSize;
			if(!_Direction) _Direction = ScrollBar.VERTICAL;
			if(!_TrackBorder && _initializationData.border != 0) _TrackBorder = ComponentSettings.scrollBarBorder;
		}

		override public function render():void
		{
			super.render();

			if(_Direction == ScrollBar.VERTICAL && _ObjectSize > _height ||
				_Direction == ScrollBar.HORIZONTAL && _ObjectSize > _width)
			{
				_ScrollingApplied = true;
				addScrolling();
			}

			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_RENDERED));
		}

		protected function addScrolling():void
		{
			createContainers();
			
			// calculate the height of the thumb so that it's proportional to the height of the area and the amount of content overflow
			if(_Direction == ScrollBar.VERTICAL) calculateSizesForVertical();
				else calculateSizesForHorizontal();

			// ratio determins how much to move the object based on how much the thumb moves
			_ScrollRatio = (_ObjectSize - _TrackSize - _ThumbSize - (_BarOffsetMax * 2)) / _TrackSize;

			if(_Direction == ScrollBar.VERTICAL) createVerticalElements();
				else createHorizontalElements();
				
			_ThumbHighlight.blendMode = BlendMode.HARDLIGHT;
				
			setEventsOnScrollThumb();
			setEventsOnScrollTrack();
			if(ComponentSettings.scrollBarArrowButton) setEventsOnScrollButtons();	
			
			if(scrollOnMouseWheel)
			{
				this.addEventListener(MouseEvent.ROLL_OVER, onScrollBarOver, false, 0, true);
				this.addEventListener(MouseEvent.ROLL_OUT, onScrollBarOut, false, 0, true);
			}

			fadeToInactiveState();
		}

		protected function createContainers():void
		{
			_Track = new Sprite();
			_Thumb = new Sprite();
			_ThumbHighlight = new Sprite();

			this.addChild(_Track);
			this.addChild(_Thumb);
		}

		protected function calculateSizesForVertical():void
		{
			if(ComponentSettings.scrollBarArrowButton)
			{
				_height -= _ButtonSize * 2;
				_BarOffsetMax = _ButtonSize;

				_ThumbSize = _height * (_height / _ObjectSize);
				if(_ThumbSize < 20) _ThumbSize = 20;
				_TrackSize = _height - _ThumbSize;
			}
			else
			{
				_ThumbSize = _height * (_height / _ObjectSize);
				if(_ThumbSize < 20) _ThumbSize = 20;
				_TrackSize = _height - _ThumbSize;
			}
		}

		protected function calculateSizesForHorizontal():void
		{
			if(ComponentSettings.scrollBarArrowButton)
			{
				_width -= _ButtonSize * 2;
				_BarOffsetMax = _ButtonSize;

				_ThumbSize = _width * (_width / _ObjectSize);
				if(_ThumbSize < 20) _ThumbSize = 20;
				_TrackSize = _width - _ThumbSize;
			}
			else
			{
				_ThumbSize = _width * (_width / _ObjectSize);
				if(_ThumbSize < 20) _ThumbSize = 20;
				_TrackSize = _width - _ThumbSize;
			}
		}

		protected function createVerticalElements():void
		{
			var radius:int = _BarSize + (_TrackBorder*-1);
			//_Track.addChild(ComponentSettings.skin.createNegativeArea({x:0, y:_BarOffsetMax, width:_BarSize, height:_height, radius:radius}));
			_Track.addChild(ComponentSettings.skin.createNegativeArea({x:_TrackBorder, y:_BarOffsetMax+_TrackBorder, width:_BarSize-(_TrackBorder*2), height:_height-(_TrackBorder*2), radius:radius}));
			_Thumb.addChild(ComponentSettings.skin.createDraggableHandle({x:0, y:_BarOffsetMax, width:_BarSize, height:_ThumbSize, radius:radius, color:_ThumbColor}));
			_ThumbHighlight.addChild(ComponentSettings.skin.createHighlight({x:0, y:_BarOffsetMax, width:_BarSize, height:_ThumbSize, expand:0, radius:radius}));
			_Thumb.addChild(_ThumbHighlight);
			_ThumbHighlight.alpha = 0;

			if(ComponentSettings.scrollBarArrowButton) createVerticalArrows();
		}

		protected function createVerticalArrows():void
		{
			_MinButton = ComponentSettings.skin.createArrowButton({width:_BarSize, height:_ButtonSize, contract:6});
			_MaxButton = ComponentSettings.skin.createArrowButton({width:_BarSize, height:_ButtonSize, contract:6});

			_MinButton.x = 0;
			_MinButton.y = 0;

			_MaxButton.rotation = 180;
			_MaxButton.x = _BarSize;
			_MaxButton.y = _Track.y + _Track.height + (_ButtonSize * 2);

			this.addChild(_MinButton);
			this.addChild(_MaxButton);
		}

		protected function createHorizontalElements():void
		{
			var radius:int = _BarSize + (_TrackBorder*-1);
			//_Track.addChild(ComponentSettings.skin.createNegativeArea({x:_BarOffsetMax, y:0, width:_width, heigth:_BarSize, radius:radius}));
			_Track.addChild(ComponentSettings.skin.createNegativeArea({x:_BarOffsetMax+_TrackBorder, y:_TrackBorder, width:_width-(_TrackBorder*2), heigth:_BarSize-(_TrackBorder*2), radius:radius}));
			_Thumb.addChild(ComponentSettings.skin.createDraggableHandle({x:_BarOffsetMax, y:0, width:_width, heigth:_BarSize, radius:radius, color:_ThumbColor}));
			_ThumbHighlight.addChild(ComponentSettings.skin.createHighlight({x:_BarOffsetMax, y:0, width:_width, heigth:_BarSize, radius:radius}));
			_Thumb.addChild(_ThumbHighlight);
			_ThumbHighlight.alpha = 0;

			if(ComponentSettings.scrollBarArrowButton) createHorizontalArrows();
		}

		protected function createHorizontalArrows():void
		{
			_MinButton = ComponentSettings.skin.createArrowButton({width:_BarSize, height:_ButtonSize, contract:6});
			_MaxButton = ComponentSettings.skin.createArrowButton({width:_BarSize, height:_ButtonSize, contract:6});

			_MinButton.x = 0;
			_MinButton.y = _ButtonSize;
			_MinButton.rotation = -90;
			
			_MaxButton.rotation = 90;
			_MaxButton.x = _Track.x + _Track.width + (_ButtonSize * 2);
			_MaxButton.y = 0;

			this.addChild(_MinButton);
			this.addChild(_MaxButton);
		}

		protected function setEventsOnScrollThumb():void
		{
			_Thumb.buttonMode = true;
			_Thumb.mouseChildren = false;
			_Thumb.addEventListener(MouseEvent.ROLL_OVER, onThumbOver, false, 0, true);
			_Thumb.addEventListener(MouseEvent.ROLL_OUT, onThumbOut, false, 0, true);
			_Thumb.addEventListener(MouseEvent.MOUSE_DOWN, onThumbDown, false, 0, true);
			_Thumb.addEventListener(FocusEvent.FOCUS_IN, onThumbFocusIn, false, 0, true);
			_Thumb.addEventListener(FocusEvent.FOCUS_OUT, onThumbFocusOut, false, 0, true);
			setAccessibilityProperties(_Thumb, "Scroll bar handle");
		}

		protected function setEventsOnScrollTrack():void
		{
			_Track.buttonMode = true;
			_Track.mouseChildren = false;
			_Track.addEventListener(MouseEvent.ROLL_OVER, onTrackOver, false, 0, true);
			_Track.addEventListener(MouseEvent.ROLL_OUT, onTrackOut, false, 0, true);
			_Track.addEventListener(MouseEvent.MOUSE_DOWN, onTrackDown, false, 0, true);
			excludeFromAccessibility(_Track);
		}

		protected function setEventsOnScrollButtons():void
		{
			_MaxButton.buttonMode = _MinButton.buttonMode = true;
			_MaxButton.mouseChildren = _MinButton.mouseChildren = false;

			_MinButton.addEventListener(MouseEvent.ROLL_OVER, onScrollButtonOver, false, 0, true);
			_MaxButton.addEventListener(MouseEvent.ROLL_OVER, onScrollButtonOver, false, 0, true);
			_MinButton.addEventListener(MouseEvent.ROLL_OUT, onScrollButtonOut, false, 0, true);
			_MaxButton.addEventListener(MouseEvent.ROLL_OUT, onScrollButtonOut, false, 0, true);

			_MinButton.addEventListener(MouseEvent.CLICK, onScrollMinButtonClick, false, 0, true);
			_MaxButton.addEventListener(MouseEvent.CLICK, onScrollMaxButtonClick, false, 0, true);
			
			setAccessibilityProperties(_MinButton, "Scroll up button");
			setAccessibilityProperties(_MaxButton, "Scroll down button");
		}

		private function animateThumbToScrollPosition():void
		{
			TweenMax.killTweensOf(_Thumb);
			
			if(_IsActivelyScrolling)
			{
				//
			}
			else
			{
				if(_Direction == ScrollBar.VERTICAL)
				{
					 TweenMax.to(_Thumb, .5, {y:_ScrollPosition, ease:Expo.easeOut});
				}
				else
				{
					 TweenMax.to(_Thumb, .5, {x:_ScrollPosition, ease:Expo.easeOut});
				}
			}
			
		}

		private function onScrollBarOver(e:MouseEvent):void
		{
			this.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onScrollWheel, false, 0, true);
		}

		private function onScrollBarOut(e:MouseEvent):void
		{
			this.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onScrollWheel);
		}

		/**
		 * Scroll vertically on mouse wheel
		 */
		protected function onScrollWheel(e:MouseEvent):void
		{
			if(!_ScrollingApplied) return;

			scollOnScrollWheelDelta(e.delta);
		}

		public function scollOnScrollWheelDelta(delta:Number):void
		{
			scrollBy(delta * _WheelScrollAmount);
		}

		/**
		 * Scroll by the number of pixels
		 */
		public function scrollBy(pixels:int):void
		{
			scrollPosition += pixels;

			if(scrollPosition < 0)
			{
				scrollPosition = 0;
			}
			if(scrollPosition > _TrackSize)
			{
				scrollPosition = _TrackSize;
			}
			
			updateScrollObjectPosition();
		}

		/**
		 * Handles tab focus on the scroll bar
		 * @param	e
		 */
		protected function onThumbFocusIn(e:FocusEvent):void
		{
			this.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressWithThumbFocus, false, 0, true);
			this.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, onKeyFocusChange, false, 0, true);
		}

		// Handles tab focus out on the scroll bar
		protected function onThumbFocusOut(e:FocusEvent):void
		{
			this.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPressWithThumbFocus);
			this.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, onKeyFocusChange);
		}

		// Handles key presss on the bar when it has tab focus
		protected function onKeyPressWithThumbFocus(e:KeyboardEvent):void
		{
			if(_IsActivelyScrolling || !_enabled) return;
			
			var offset:int;
			
			// up
			if(_Direction == ScrollBar.VERTICAL && e.keyCode == 38) offset = -1;
			// down
			if(_Direction == ScrollBar.VERTICAL && e.keyCode == 40) offset = 1;
			// left
			if(_Direction == ScrollBar.HORIZONTAL && e.keyCode == 37) offset = -1;
			// right
			if(_Direction == ScrollBar.HORIZONTAL && e.keyCode == 39) offset = 1;
			
			scrollBy(offset * _KeyBoardScrollAmount);
		}

		// Traps the arrow keys, which normally change focus, to allow them to control the scrolling
		protected function onKeyFocusChange(e:FocusEvent):void
		{
			if(_Direction == ScrollBar.VERTICAL && e.keyCode == 38 || e.keyCode == 40) e.preventDefault();
			if(_Direction == ScrollBar.HORIZONTAL && e.keyCode == 37 || e.keyCode == 39) e.preventDefault();
		}

		/**
		 * Fades the vbars down to a normal state
		 */
		protected function fadeToInactiveState():void
		{
			TweenMax.to(_Track, .75, {alpha:.1, ease:Quad.easeOut});
			// TweenMax.to(_Thumb, 1, { alpha:.5, ease:Quad.easeOut } );
			TweenMax.to(_ThumbHighlight, .5, {alpha:0, ease:Quad.easeOut});
		}

		/**
		 * Scrolling buttons over or under the scroll bar
		 * @param	e
		 */
		protected function onScrollButtonOver(e:Event):void
		{
			if(_IsActivelyScrolling || !_enabled) return;
			TweenMax.to(e.target.getChildByName("hi_mc"), .25, {alpha:ComponentSettings.highlightMaxAlpha, ease:Quad.easeOut});
			onTrackOver(undefined);
		}

		/**
		 * Scrolling buttons over or under the scroll bar
		 * @param	e
		 */
		protected function onScrollButtonOut(e:Event):void
		{
			if(_IsActivelyScrolling || !_enabled) return;
			TweenMax.to(e.target.getChildByName("hi_mc"), .5, {alpha:0, ease:Quad.easeOut});
			onTrackOut(undefined);
		}

		/**
		 * scroll up
		 * @param	e
		 */
		protected function onScrollMinButtonClick(e:Event):void
		{
			scrollBy(-_ThumbSize * _ButtonScrollAmount);
		}

		/**
		 * scroll down
		 * @param	e
		 */
		protected function onScrollMaxButtonClick(e:Event):void
		{
			scrollBy(_ThumbSize * _ButtonScrollAmount);
		}

		/**
		 * Handlers for the track events
		 */
		protected function onTrackOver(event:Event):void
		{
			if(_IsActivelyScrolling || !_enabled) return;
			TweenMax.killTweensOf(_Track);
			TweenMax.killTweensOf(_Thumb);
			TweenMax.to(_Track, .25, {alpha:.75, ease:Quad.easeOut});
			TweenMax.to(_Thumb, .5, {alpha:1, ease:Quad.easeOut});
		}

		/**
		 * Handlers for the track events
		 */
		protected function onTrackOut(event:Event):void
		{
			if(_IsActivelyScrolling || !_enabled) return;
			TweenMax.killTweensOf(_Track);
			TweenMax.killTweensOf(_Thumb);
			fadeToInactiveState();
		}

		/**
		 * Handlers for the track events
		 */
		protected function onTrackDown(event:Event):void
		{
			if(!_enabled) return;

			TweenMax.killTweensOf(_Track);
			TweenMax.killTweensOf(_Thumb);
			
			if(_Direction == ScrollBar.VERTICAL)
			{
				// where on the track was the click
				var clickY:int = event.target.mouseY - _BarOffsetMax;
				// adjust based on click over or under the thumb
				var thumbY:int = clickY < scrollPosition ? clickY:clickY - _ThumbSize;
				// make sure it doesn't go off the bottom of the track
				if(thumbY > (scrollMin + _TrackSize)) thumbY = scrollMin + _TrackSize;
				scrollPosition = thumbY;
			}
			else
			{
				// where on the track was the click
				var clickX:int = event.target.mouseX - _BarOffsetMax;
				// adjust based on click over or under the thumb
				var thumbX:int = clickX < scrollPosition ? clickX:clickX - _ThumbSize;
				// make sure it doesn't go off the bottom of the track
				if(thumbX > (scrollMin + _TrackSize)) thumbX = scrollMin + _TrackSize;
				scrollPosition = thumbX;	
			}
				
			updateScrollObjectPosition();

			fadeToInactiveState();
		}

		/**
		 * Handlers for the thumb events
		 */
		protected function onThumbOver(event:Event):void
		{
			if(_IsActivelyScrolling || !_enabled) return;
			TweenMax.killTweensOf(_Track);
			TweenMax.killTweensOf(_Thumb);
			TweenMax.to(_Track, .5, {alpha:.5, ease:Quad.easeOut});
			TweenMax.to(_Thumb, .25, {alpha:1, ease:Quad.easeOut});
			TweenMax.to(_ThumbHighlight, .25, {alpha:1, ease:Quad.easeOut});
			dispatchActivateEvent();
		}

		/**
		 * Handlers for the thumb events
		 */
		protected function onThumbOut(event:Event):void
		{
			if(_IsActivelyScrolling || !_enabled) return;
			TweenMax.killTweensOf(_Track);
			TweenMax.killTweensOf(_Thumb);
			fadeToInactiveState();
			TweenMax.to(_ThumbHighlight, .5, {alpha:0, ease:Quad.easeOut});
			dispatchDeactivateEvent();
		}

		/**
		 * Handlers for the thumb events
		 */
		protected function onThumbDown(event:Event):void
		{
			if(!_enabled) return;
			TweenMax.killTweensOf(_Track);
			TweenMax.killTweensOf(_Thumb);
			TweenMax.to(_Track, .25, {alpha:.75, ease:Quad.easeOut});
			TweenMax.to(_Thumb, .25, {alpha:1, ease:Quad.easeOut});

			_IsActivelyScrolling = true;
			
			if(_Direction == ScrollBar.VERTICAL) _Thumb.startDrag(false, new Rectangle(_Thumb.x, scrollMin, _Thumb.x, _TrackSize));
				else _Thumb.startDrag(false, new Rectangle(scrollMin, _Thumb.y,  _TrackSize, _Thumb.y));
			
			this.stage.addEventListener(MouseEvent.MOUSE_UP, onThumbRelease, false, 0, true);
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onThumbDrag, false, 0, true);

			dispatchClickEvent();
		}

		/**
		 * Handlers for the thumb events
		 */
		protected function onThumbRelease(event:Event):void
		{
			if(!_enabled) return;
			_IsActivelyScrolling = false;
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onThumbDrag);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, onThumbRelease);
			_Thumb.stopDrag();

			TweenMax.killTweensOf(_Track);
			TweenMax.killTweensOf(_Thumb);

			fadeToInactiveState();
		}

		/**
		 * Update the object's position as the thumb is being dragged
		 * @param	event
		 */
		protected function onThumbDrag(event:Event):void
		{
			if(_Direction == ScrollBar.VERTICAL) scrollPosition = _Thumb.y;
				else scrollPosition = _Thumb.x;
			
			updateScrollObjectPosition();
		}

		/**
		 * Animate the object to the new position
		 */
		protected function updateScrollObjectPosition():void
		{
			var evt:ScrollBarEvent = new ScrollBarEvent(ScrollBarEvent.EVENT_SCROLL);
			evt.position = position;
			evt.objectToPosition = objectToPosition;
			dispatchEvent(evt);
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
		 * Remove vertical scroll bar
		 */
		protected function removeScrolling():void
		{
			if(!_ScrollingApplied) return;

			_Thumb.removeEventListener(MouseEvent.ROLL_OVER, onThumbOver);
			_Thumb.removeEventListener(MouseEvent.ROLL_OUT, onThumbOut);
			_Thumb.removeEventListener(MouseEvent.MOUSE_DOWN, onThumbDown);
			_Track.removeEventListener(MouseEvent.ROLL_OVER, onTrackOver);
			_Track.removeEventListener(MouseEvent.ROLL_OUT, onTrackOut);
			_Track.removeEventListener(MouseEvent.MOUSE_DOWN, onTrackDown);
			
			if(_IsActivelyScrolling)
			{
				this.stage.removeEventListener(MouseEvent.MOUSE_UP, onThumbRelease);
				this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onThumbDrag);
			}

			_Thumb.removeEventListener(FocusEvent.FOCUS_IN, onThumbFocusIn);
			_Thumb.removeEventListener(FocusEvent.FOCUS_OUT, onThumbFocusOut);
			
			this.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPressWithThumbFocus);
			this.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, onKeyFocusChange);

			_Thumb.removeChild(_ThumbHighlight);
			this.removeChild(_Track);
			this.removeChild(_Thumb);
			_Track = undefined;
			_Thumb = undefined;
			_ThumbHighlight = undefined;

			if(scrollOnMouseWheel)
			{
				try
				{
					this.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onScrollWheel);
				}
				catch(e:*)
				{
				}
			}

			if(ComponentSettings.scrollBarArrowButton)
			{
				_MinButton.removeEventListener(MouseEvent.ROLL_OVER, onScrollButtonOver);
				_MaxButton.removeEventListener(MouseEvent.ROLL_OVER, onScrollButtonOver);
				_MinButton.removeEventListener(MouseEvent.ROLL_OUT, onScrollButtonOut);
				_MaxButton.removeEventListener(MouseEvent.ROLL_OUT, onScrollButtonOut);
				_MinButton.removeEventListener(MouseEvent.CLICK, onScrollMinButtonClick);
				_MaxButton.removeEventListener(MouseEvent.CLICK, onScrollMaxButtonClick);

				this.removeChild(_MinButton);
				this.removeChild(_MaxButton);

				_MaxButton = undefined;
				_MinButton = undefined;
			}
		}

		/**
		 * Remove event listeners and remove DisplayObjects from containters
		 */
		override public function destroy():void
		{
			removeScrolling();
			super.destroy();
		}

	}
}