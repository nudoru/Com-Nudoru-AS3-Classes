package com.nudoru.components.visual
{
	import flash.display.BlendMode;
	import com.greensock.TweenLite;
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
	 * Slider Bar
	 * 
	 * TODO mouse wheel and keyboard moves to next snap position
	 * 
	var sb:Slider = new Slider();
	sb.initialize({width:10,height:250,thumbcolor:0x333333, snap:10,direction:ScrollBar.VERTICAL});
	sb.render();
	sb.x = 660;
	sb.y = 10;
	this.addChild(sb);
	sb.addEventListener(SliderEvent.EVENT_CHANGE, onSlider);
	 */
	public class Slider extends VisualComponent implements IVisualComponent
	{
		protected var _SliderSize:int;
		protected var _SliderDirection:String;
		protected var _SliderPosition:int;
		protected var _Track:Sprite;
		protected var _TrackBorder:int;
		protected var _SnapTicks:Sprite;
		protected var _Thumb:Sprite;
		protected var _ThumbHighlight:Sprite;
		protected var _ThumbSize:int;
		protected var _TrackSize:int;
		protected var _Progress:Sprite;
		protected var _ProgressColor:Number;
		protected var _ShowProgressTexture:Boolean = false;
		protected var _Snap:Boolean;
		protected var _SnapPositions:Vector.<int> = new Vector.<int>();
		protected var _KeyBoardSlideAmount:int = 10;
		protected var _WheelSlideAmount:int = -2;
		protected var _SlideOnMouseWheel:Boolean = true;
		protected var _ThumbColor:Number;
		protected var _IsActivelySliding:Boolean = false;
		public static var VERTICAL:String = "vertical";
		public static var HORIZONTAL:String = "horizontal";

		/**
		 * Current position of the slide object
		 */
		public function get position():Number
		{
			var position:int;
			if(_SliderDirection == Slider.VERTICAL) position = _TrackSize - _SliderPosition;
				else position = _SliderPosition;

			return  position / _TrackSize;
		}

		public function set position(position:Number):void
		{
			var spos:Number = position * _TrackSize;
			if(_SliderDirection == Slider.VERTICAL) spos = _TrackSize - spos;
			sliderPosition = spos;
			//dispatchChangeEvent();
		}

		public function get sliderPosition():int
		{
			return _SliderPosition;
		}

		public function set sliderPosition(sliderPosition:int):void
		{
			_SliderPosition = sliderPosition;
			animateThumbToSliderPosition();
		}

		public function get keyBoardSlideAmount():int
		{
			return _KeyBoardSlideAmount;
		}

		public function set keyBoardSlideAmount(keyBoardSlideAmount:int):void
		{
			_KeyBoardSlideAmount = keyBoardSlideAmount;
		}

		public function get wheelSlideAmount():int
		{
			return _WheelSlideAmount;
		}

		public function set wheelSlideAmount(wheelSlideAmount:int):void
		{
			_WheelSlideAmount = wheelSlideAmount;
		}

		public function get slideOnMouseWheel():Boolean
		{
			return _SlideOnMouseWheel;
		}

		public function set slideOnMouseWheel(value:Boolean):void
		{
			_SlideOnMouseWheel = value;
		}

		public function get showProgress():Boolean
		{
			return _ProgressColor > 0;
		}

		public function Slider():void
		{
			super();
		}

		override public function initialize(data:*=null):void
		{
			super.initialize(data);

			_SliderDirection = data.direction;
			_ThumbColor = data.thumbcolor;
			_TrackBorder = int(data.border);
			_Snap = data.snap > 0;
			_ProgressColor = int(data.progresscolor);
			_ShowProgressTexture = data.progresstexture == true ? true : false;
			
			if(_SliderDirection == Slider.VERTICAL) 
			{
				_SliderSize = _width;
			}
			else
			{
				_SliderSize = _height;
			}

			validateData();

			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INITIALIZED));
		}

		override protected function validateData():void
		{
			if(!_ThumbColor) _ThumbColor = ComponentSettings.handleColor;
			if(!_SliderSize) _SliderSize = ComponentSettings.scrollBarSize;
			if(!_SliderDirection) _SliderDirection = Slider.VERTICAL;
			if(!_TrackBorder && _initializationData.border != 0) _TrackBorder = ComponentSettings.sliderBorder;
		}

		override public function render():void
		{
			super.render();

			addSliding();

			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_RENDERED));
		}

		protected function addSliding():void
		{
			createContainers();

			// calculate the height of the thumb so that it's proportional to the height of the area and the amount of content overflow
			if(_SliderDirection == Slider.VERTICAL) calculateSizesForVertical();
			else calculateSizesForHorizontal();

			if(_Snap) calculateSnapPositions(_initializationData.snap);

			if(_SliderDirection == Slider.VERTICAL) createVerticalElements();
				else createHorizontalElements();

			_ThumbHighlight.blendMode = BlendMode.HARDLIGHT;

			if(_SliderDirection == Slider.VERTICAL) 
			{
				_SliderPosition = _TrackSize;
			}

			setEventsOnSlideThumb();
			setEventsOnSlideTrack();

			if(slideOnMouseWheel)
			{
				this.addEventListener(MouseEvent.ROLL_OVER, onSlideBarOver, false, 0, true);
				this.addEventListener(MouseEvent.ROLL_OUT, onSlideBarOut, false, 0, true);
			}

			fadeToInactiveState();
		}

		protected function createContainers():void
		{
			_Track = new Sprite();
			_Progress = new Sprite();
			_Thumb = new Sprite();
			_ThumbHighlight = new Sprite();

			_SnapTicks = new Sprite();
			_Track.addChild(_SnapTicks);

			this.addChild(_Track);
			this.addChild(_Progress);
			this.addChild(_Thumb);
		}

		protected function calculateSizesForVertical():void
		{
			_ThumbSize = _SliderSize;
			_TrackSize = _height - _ThumbSize;
		}

		protected function calculateSizesForHorizontal():void
		{
			_ThumbSize = _SliderSize;
			_TrackSize = _width - _ThumbSize;
		}

		protected function createVerticalElements():void
		{
			var radius:int = _SliderSize + (_TrackBorder*-1);
			_Track.addChild(ComponentSettings.skin.createNegativeArea({x:_TrackBorder, y:_TrackBorder, width:_width-(_TrackBorder*2), height:_height-(_TrackBorder*2), radius:radius}));

			createTrackSnapTicks();

			_Thumb.addChild(ComponentSettings.skin.createDraggableHandle({x:0, y:0, width:_width, height:_SliderSize, radius:radius, color:_ThumbColor, emphasis:true}));
			_ThumbHighlight.addChild(ComponentSettings.skin.createHighlight({x:0, y:0, width:_width, height:_SliderSize, radius:radius}));
			_Thumb.addChild(_ThumbHighlight);
			_ThumbHighlight.alpha = 0;
			
			_Thumb.y = _TrackSize;
		}

		protected function createHorizontalElements():void
		{
			var radius:int = _SliderSize + (_TrackBorder*-1);
			_Track.addChild(ComponentSettings.skin.createNegativeArea({x:_TrackBorder, y:_TrackBorder, width:_width-(_TrackBorder*2), height:_height-(_TrackBorder*2), radius:radius}));

			createTrackSnapTicks();

			_Thumb.addChild(ComponentSettings.skin.createDraggableHandle({x:0, y:0, width:_SliderSize, height:_height, radius:radius, color:_ThumbColor, emphasis:true}));
			_ThumbHighlight.addChild(ComponentSettings.skin.createHighlight({x:0, y:0, width:_SliderSize, height:_height, radius:radius}));
			_Thumb.addChild(_ThumbHighlight);
			_ThumbHighlight.alpha = 0;
			
			_Thumb.x = _SliderPosition;
		}

		private function calculateSnapPositions(snap:int):void
		{
			var snappos:Number = 0;
			var spacing:Number = _TrackSize / snap;
			_SnapPositions.push(0);
			for(var i:int; i < (snap - 1); i++)
			{
				snappos += spacing;
				_SnapPositions.push(snappos);
			}

			_SnapPositions.push(_TrackSize);
		}

		protected function createTrackSnapTicks():void
		{
			var halfThumbSize:int = _ThumbSize / 2;

			_SnapTicks.graphics.lineStyle(0, ComponentSettings.gutterLineColor, .5, true);

			for(var i:int = 1,len:int = _SnapPositions.length - 1; i < len; i++)
			{
				if(_SliderDirection == Slider.VERTICAL)
				{
					_SnapTicks.graphics.moveTo(1+_TrackBorder, _SnapPositions[i] + halfThumbSize);
					_SnapTicks.graphics.lineTo(_width-2-(_TrackBorder*2), _SnapPositions[i] + halfThumbSize);
				}
				else
				{
					_SnapTicks.graphics.moveTo(_SnapPositions[i] + halfThumbSize, 2);
					_SnapTicks.graphics.lineTo(_SnapPositions[i] + halfThumbSize, _height-3);
				}
			}
		}

		protected function setEventsOnSlideThumb():void
		{
			_Thumb.buttonMode = true;
			_Thumb.mouseChildren = false;
			_Thumb.addEventListener(MouseEvent.ROLL_OVER, onThumbOver, false, 0, true);
			_Thumb.addEventListener(MouseEvent.ROLL_OUT, onThumbOut, false, 0, true);
			_Thumb.addEventListener(MouseEvent.MOUSE_DOWN, onThumbDown, false, 0, true);
			_Thumb.addEventListener(FocusEvent.FOCUS_IN, onThumbFocusIn, false, 0, true);
			_Thumb.addEventListener(FocusEvent.FOCUS_OUT, onThumbFocusOut, false, 0, true);
			setAccessibilityProperties(_Thumb, "Slider handle");
		}

		protected function setEventsOnSlideTrack():void
		{
			_Track.buttonMode = true;
			_Track.mouseChildren = false;
			_Track.addEventListener(MouseEvent.ROLL_OVER, onTrackOver, false, 0, true);
			_Track.addEventListener(MouseEvent.ROLL_OUT, onTrackOut, false, 0, true);
			_Track.addEventListener(MouseEvent.MOUSE_DOWN, onTrackDown, false, 0, true);
			excludeFromAccessibility(_Track);
			
			if(showProgress) 
			{
				_Progress.buttonMode = true;
				_Progress.mouseChildren = false;
				_Progress.addEventListener(MouseEvent.MOUSE_DOWN, onTrackDown, false, 0, true);
				excludeFromAccessibility(_Progress);
			}
	
		}

		private function animateThumbToSliderPosition():void
		{
			TweenMax.killTweensOf(_Thumb);
			
			if(_IsActivelySliding)
			{
				indicateProgress();
			}
			else
			{
				if(_SliderDirection == Slider.VERTICAL)
				{
					 TweenMax.to(_Thumb, .5, {y:_SliderPosition, ease:Expo.easeOut, onUpdate:indicateProgress});
				}
				else
				{
					 TweenMax.to(_Thumb, .5, {x:_SliderPosition, ease:Expo.easeOut, onUpdate:indicateProgress});
				}
			}
			
		}

		private function onSlideBarOver(e:MouseEvent):void
		{
			this.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onSlideWheel, false, 0, true);
		}

		private function onSlideBarOut(e:MouseEvent):void
		{
			this.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onSlideWheel);
		}

		/**
		 * Slide vertically on mouse wheel
		 */
		protected function onSlideWheel(e:MouseEvent):void
		{
			slideOnSlideWheelDelta(e.delta);
		}

		public function slideOnSlideWheelDelta(delta:Number):void
		{
			slideBy(delta * _WheelSlideAmount);
		}

		protected function adjustToNearestSnap(position:int):int
		{
			if(!_Snap) return position;
			if(position == _SnapPositions[0]) return _SnapPositions[0];
			if(position == _SnapPositions[_SnapPositions.length - 1]) return _SnapPositions[_SnapPositions.length - 1];
			var pair:Array = getSnapToMinMaxPair(position);
			var mid:int = getMidPoint(pair[0], pair[1]);
			if(position < mid) return pair[0];
			return pair[1];
		}

		protected function getSnapToMinMaxPair(position:int):Array
		{
			for(var i:int, len:int = _SnapPositions.length - 1; i < len; i++)
			{
				if(position > _SnapPositions[i] && position < _SnapPositions[i + 1]) return [_SnapPositions[i], _SnapPositions[i + 1]];
			}
			return [];
		}

		protected function getMidPoint(num1:int, num2:int):int
		{
			var dif:int = num2 - num1;
			return num1 + (dif / 2);
		}

		/**
		 * Slide by the number of pixels
		 */
		public function slideBy(pixels:int):void
		{
			sliderPosition += pixels;

			if(sliderPosition < 0)
			{
				sliderPosition = 0;
			}
			if(sliderPosition > _TrackSize)
			{
				sliderPosition = _TrackSize;
			}
			
			snapThumpPosition();

			dispatchChangeEvent();
		}

		/**
		 * Handles tab focus on the slide bar
		 * @param	e
		 */
		protected function onThumbFocusIn(e:FocusEvent):void
		{
			this.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressWithThumbFocus, false, 0, true);
			this.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, onKeyFocusChange, false, 0, true);
			
			dispatchEvent(new SliderEvent(SliderEvent.EVENT_HANDLE_OVER));
		}

		// Handles tab focus out on the slide bar
		protected function onThumbFocusOut(e:FocusEvent):void
		{
			this.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPressWithThumbFocus);
			this.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, onKeyFocusChange);
			
			dispatchEvent(new SliderEvent(SliderEvent.EVENT_HANDLE_OUT));
		}

		// Handles key presss on the bar when it has tab focus
		protected function onKeyPressWithThumbFocus(e:KeyboardEvent):void
		{
			if(_IsActivelySliding || !_enabled) return;

			var offset:int;

			// up
			if(_SliderDirection == Slider.VERTICAL && e.keyCode == 38) offset = -1;
			// down
			if(_SliderDirection == Slider.VERTICAL && e.keyCode == 40) offset = 1;
			// left
			if(_SliderDirection == Slider.HORIZONTAL && e.keyCode == 37) offset = -1;
			// right
			if(_SliderDirection == Slider.HORIZONTAL && e.keyCode == 39) offset = 1;

			slideBy(offset * _KeyBoardSlideAmount);
		}

		// Traps the arrow keys, which normally change focus, to allow them to control the Sliding
		protected function onKeyFocusChange(e:FocusEvent):void
		{
			if(_SliderDirection == Slider.VERTICAL && e.keyCode == 38 || e.keyCode == 40) e.preventDefault();
			if(_SliderDirection == Slider.HORIZONTAL && e.keyCode == 37 || e.keyCode == 39) e.preventDefault();
		}

		/**
		 * Fades the vbars down to a normal state
		 */
		protected function fadeToInactiveState():void
		{
			TweenMax.to(_Track, .75, {alpha:.5, ease:Quad.easeOut});
			// TweenMax.to(_SlideThumb, 1, { alpha:.5, ease:Quad.easeOut } );
			TweenMax.to(_ThumbHighlight, .5, {alpha:0, ease:Quad.easeOut});
		}

		/**
		 * Sliding buttons over or under the slide bar
		 * @param	e
		 */
		protected function onSlideButtonOver(e:Event):void
		{
			if(_IsActivelySliding || !_enabled) return;
			TweenMax.to(e.target.getChildByName("hi_mc"), .25, {alpha:ComponentSettings.highlightMaxAlpha, ease:Quad.easeOut});
			onTrackOver(undefined);
		}

		/**
		 * Sliding buttons over or under the slide bar
		 * @param	e
		 */
		protected function onSlideButtonOut(e:Event):void
		{
			if(_IsActivelySliding || !_enabled) return;
			TweenMax.to(e.target.getChildByName("hi_mc"), .5, {alpha:0, ease:Quad.easeOut});
			onTrackOut(undefined);
		}

		/**
		 * Handlers for the track events
		 */
		protected function onTrackOver(event:Event):void
		{
			if(_IsActivelySliding || !_enabled) return;
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
			if(_IsActivelySliding || !_enabled) return;
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

			if(_SliderDirection == Slider.VERTICAL)
			{
				// where on the track was the click
				var clickY:int = event.target.mouseY;
				// adjust based on click over or under the thumb
				var thumbY:int = clickY < sliderPosition ? clickY : clickY - _ThumbSize;
				// make sure it doesn't go off the bottom of the track
				if(thumbY > _TrackSize) thumbY = _TrackSize;
				sliderPosition = thumbY;
			}
			else
			{
				// where on the track was the click
				var clickX:int = event.target.mouseX;
				// adjust based on click over or under the thumb
				var thumbX:int = clickX < sliderPosition ? clickX : clickX - _ThumbSize;
				// make sure it doesn't go off the bottom of the track
				if(thumbX > _TrackSize) thumbX = _TrackSize;
				sliderPosition = thumbX;
			}
			snapThumpPosition();

			dispatchChangeEvent();

			fadeToInactiveState();
		}

		/**
		 * Handlers for the thumb events
		 */
		protected function onThumbOver(event:Event):void
		{
			if(_IsActivelySliding || !_enabled) return;
			TweenMax.killTweensOf(_Track);
			TweenMax.killTweensOf(_Thumb);
			TweenMax.to(_Track, .5, {alpha:.5, ease:Quad.easeOut});
			TweenMax.to(_Thumb, .25, {alpha:1, ease:Quad.easeOut});
			TweenMax.to(_ThumbHighlight, .25, {alpha:1, ease:Quad.easeOut});
			dispatchActivateEvent();
			
			dispatchEvent(new SliderEvent(SliderEvent.EVENT_HANDLE_OVER));
		}

		/**
		 * Handlers for the thumb events
		 */
		protected function onThumbOut(event:Event):void
		{
			if(_IsActivelySliding || !_enabled) return;
			TweenMax.killTweensOf(_Track);
			TweenMax.killTweensOf(_Thumb);
			fadeToInactiveState();
			TweenMax.to(_ThumbHighlight, .5, {alpha:0, ease:Quad.easeOut});
			dispatchDeactivateEvent();
			
			dispatchEvent(new SliderEvent(SliderEvent.EVENT_HANDLE_OUT));
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

			_IsActivelySliding = true;

			if(_SliderDirection == Slider.VERTICAL) _Thumb.startDrag(false, new Rectangle(_Thumb.x, 0, _Thumb.x, _TrackSize));
				else _Thumb.startDrag(false, new Rectangle(0, _Thumb.y, _TrackSize, _Thumb.y));

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
			_IsActivelySliding = false;
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onThumbDrag);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, onThumbRelease);
			_Thumb.stopDrag();

			TweenMax.killTweensOf(_Track);
			TweenMax.killTweensOf(_Thumb);

			snapThumpPosition();

			dispatchChangeEvent();

			fadeToInactiveState();
		}

		private function snapThumpPosition():void
		{
			sliderPosition = adjustToNearestSnap(sliderPosition);
		}

		/**
		 * Update the object's position as the thumb is being dragged
		 * @param	event
		 */
		protected function onThumbDrag(event:Event):void
		{
			
			if(_SliderDirection == Slider.VERTICAL) sliderPosition = _Thumb.y;
				else sliderPosition = _Thumb.x;
				
			dispatchChangeEvent();
		}

		/**
		 * Animate the object to the new position
		 */
		protected function dispatchChangeEvent():void
		{
			var evt:SliderEvent = new SliderEvent(SliderEvent.EVENT_CHANGE);
			evt.position = position;
			dispatchEvent(evt);
		}

		protected function indicateProgress():void
		{
			if(!showProgress) return;
			
			if(_Progress.numChildren) _Progress.removeChildAt(0);
			var vertYOrigin:int = _Thumb.y;
			
			if(_TrackBorder > 0)
			{
				if(_SliderDirection == Slider.HORIZONTAL) _Progress.addChild(ComponentSettings.skin.createProgressBar({x:_TrackBorder, y:_TrackBorder, width:_Thumb.x + _ThumbSize-(_TrackBorder*2), height:_SliderSize-(_TrackBorder*2), radius:_SliderSize, color:_ProgressColor, texture:_ShowProgressTexture}));
				else 
				{
					//disabled starts at top _Progress.addChild(ComponentSettings.skin.createProgressBar({x:_TrackBorder, y:_TrackBorder, width:_SliderSize-(_TrackBorder*2), height:_Thumb.y + _ThumbSize-(_TrackBorder*2), radius:_SliderSize, color:_ProgressColor, texture:_ShowProgressTexture}));
					_Progress.addChild(ComponentSettings.skin.createProgressBar({x:_TrackBorder, y:vertYOrigin, width:_SliderSize-(_TrackBorder*2), height:_height - vertYOrigin - (_TrackBorder*2), radius:_SliderSize, color:_ProgressColor, texture:_ShowProgressTexture}));
				}
			}
			else
			{
				if(_SliderDirection == Slider.HORIZONTAL) _Progress.addChild(ComponentSettings.skin.createProgressBar({x:0, y:0, width:_Thumb.x + _ThumbSize, height:_SliderSize, radius:_SliderSize, color:_ProgressColor, texture:_ShowProgressTexture}));
				else
				{
					//disabled starts at top_Progress.addChild(ComponentSettings.skin.createProgressBar({x:0, y:0, width:_SliderSize, height:_Thumb.y + _ThumbSize, radius:_SliderSize, color:_ProgressColor, texture:_ShowProgressTexture}));
					_Progress.addChild(ComponentSettings.skin.createProgressBar({x:0, y:vertYOrigin, width:_SliderSize, height:_height - vertYOrigin, radius:_SliderSize, color:_ProgressColor, texture:_ShowProgressTexture}));
				}	
			}
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
		 * Remove vertical slide bar
		 */
		protected function removeSliding():void
		{
			_Thumb.removeEventListener(MouseEvent.ROLL_OVER, onThumbOver);
			_Thumb.removeEventListener(MouseEvent.ROLL_OUT, onThumbOut);
			_Thumb.removeEventListener(MouseEvent.MOUSE_DOWN, onThumbDown);
			_Track.removeEventListener(MouseEvent.ROLL_OVER, onTrackOver);
			_Track.removeEventListener(MouseEvent.ROLL_OUT, onTrackOut);
			_Track.removeEventListener(MouseEvent.MOUSE_DOWN, onTrackDown);
			
			if(showProgress) _Progress.removeEventListener(MouseEvent.MOUSE_DOWN, onTrackDown);
			
			if(_IsActivelySliding)
			{
				this.stage.removeEventListener(MouseEvent.MOUSE_UP, onThumbRelease);
				this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onThumbDrag);
			}

			_Thumb.removeEventListener(FocusEvent.FOCUS_IN, onThumbFocusIn);
			_Thumb.removeEventListener(FocusEvent.FOCUS_OUT, onThumbFocusOut);

			this.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPressWithThumbFocus);
			this.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, onKeyFocusChange);

			_Track.removeChild(_SnapTicks);
			_Thumb.removeChild(_ThumbHighlight);
			this.removeChild(_Track);
			this.removeChild(_Thumb);
			this.removeChild(_Progress);
			_Track = undefined;
			_Thumb = undefined;
			_ThumbHighlight = undefined;
			_SnapTicks = undefined;
			_Progress = undefined;

			if(slideOnMouseWheel)
			{
				try
				{
					this.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onSlideWheel);
				}
				catch(e:*)
				{
				}
			}
		}

		public function getPositionAtPixelLocation(pixelloc:int):Number
		{
			if(pixelloc < 0) pixelloc = 0;
			if(pixelloc > _TrackSize) pixelloc = _TrackSize;
			return pixelloc / _TrackSize;
		}

		/**
		 * Remove event listeners and remove DisplayObjects from containters
		 */
		override public function destroy():void
		{
			removeSliding();
			super.destroy();
		}

	}
}