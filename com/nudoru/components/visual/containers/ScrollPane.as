package com.nudoru.components.visual.containers
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Quad;
	import com.nudoru.components.ComponentEvent;
	import com.nudoru.components.ComponentSettings;
	import com.nudoru.components.visual.ScrollBar;
	import com.nudoru.components.visual.ScrollBarEvent;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;

	/**
	 * Nudoru Scroll Area
	sb = new NudoruScrollArea();
	sb.initialize( { barsize:14, content:container, orientation:NudoruScrollArea.VERTICAL, width:200, height:300} );
	this.addChild(sb);
	sb.render();
	 */
	public class ScrollPane extends ComponentContainer implements IComponentContainer
	{
		protected var _OriginX:int;
		protected var _OriginY:int;

		protected var _ScrollObject:*;
		protected var _ScrollObjectMask:Sprite;
		protected var _ScrollObjectHolder:Sprite;

		protected var _ScrollObjectOrigParent:*;
		protected var _ScrollObjectWidth:int;
		protected var _ScrollObjectHeight:int;

		protected var _TrimArea:Boolean;

		protected var _HorizontalScrollBar:ScrollBar;
		protected var _VerticalScrollBar:ScrollBar;

		protected var _ScrollOnMouseWheel:Boolean = true;

		/**
		 * Object being scrolled 
		 */
		public function get content():Sprite
		{
			return _ScrollObject;
		}

		public function get requiresVerticalScrolling():Boolean
		{
			return _ScrollObjectHeight > _height;
		}
		
		public function get requiresHorizontalScrolling():Boolean
		{
			return _ScrollObjectWidth > _width;
		}
			
		public function ScrollPane():void
		{
			super();
			
			_maxChildren = 1;
		}

		/**
		 * Initialize the view
		 */
		override public function initialize(data:*=null):void
		{
			super.initialize(data);

			_ScrollObject = data.content;
			_TrimArea = data.trim;
			_OriginX = _ScrollObject.x;
			_OriginY = _ScrollObject.y;

 			validateData();

			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INITIALIZED));
		}

		override protected function validateData():void
		{
			/*
			 disabled
			 if(! _ScrollObject)
			{
				throw(new Error("Must pass a target"));
				return;
			}

			if(! _width && ! _height)
			{
				throw(new Error("Must pass either a width or a height"));
				return;
			}*/

		}

		/**
		 * Draw the view
		 */
		override public function render():void
		{
			super.render();

			onComponentAdded();

			this.x = _OriginX;
			this.y = _OriginY;

			if(_TrimArea) trimScrollArea();
			if(requiresVerticalScrolling) addVerticalScrollBar();
			if(requiresHorizontalScrolling) addHorizontalScrollBar();

			createContainers();

			if(_ScrollOnMouseWheel)
			{
				this.addEventListener(MouseEvent.ROLL_OVER, onContentOver, false, 0, true);
				this.addEventListener(MouseEvent.ROLL_OUT, onContentOut, false, 0, true);
			}

			watchScrollObject();

			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_RENDERED));
		}

		override protected function onComponentAdded():void
		{
			try
			{
				_ScrollObjectOrigParent = _ScrollObject.parent;
			}
			catch(e:*)
			{
			}

			if(! _width) _width = _ScrollObject.width;
			if(! _height) _height = _ScrollObject.height;

			_ScrollObjectWidth = _ScrollObject.width;
			_ScrollObjectHeight = _ScrollObject.height;
		}

		protected function watchScrollObject():void
		{
			if(_ScrollObject is TextField)
			{
				if(_ScrollObject.type == TextFieldType.INPUT) _ScrollObject.addEventListener(TextEvent.TEXT_INPUT, onScrollObjectChange);
			}
		}

		protected function onScrollObjectChange(event:*):void
		{
			trace("onScrollObjectChange");
		}

		protected function trimScrollArea():void
		{
			if(requiresVerticalScrolling)
			{
				 _width -= ComponentSettings.scrollBarSize;
			}
			if(requiresHorizontalScrolling)
			{
				_height -= ComponentSettings.scrollBarSize;
			}
		}

		protected function addVerticalScrollBar():void
		{
			_VerticalScrollBar = new ScrollBar();
			_VerticalScrollBar.initialize({width:ComponentSettings.scrollBarSize, height:_height, direction:ScrollBar.VERTICAL, targetSize:_ScrollObjectHeight});
			_VerticalScrollBar.x = _width;
			_VerticalScrollBar.y = 0;
			_VerticalScrollBar.render();
			this.addChild(_VerticalScrollBar);
			_VerticalScrollBar.addEventListener(ScrollBarEvent.EVENT_SCROLL, onVerticalScroll, false, 0, true);
		}

		protected function addHorizontalScrollBar():void
		{
			_HorizontalScrollBar = new ScrollBar();
			_HorizontalScrollBar.initialize({width:_width, height:ComponentSettings.scrollBarSize, direction:ScrollBar.HORIZONTAL, targetSize:_ScrollObjectWidth});
			_HorizontalScrollBar.x = 0;
			_HorizontalScrollBar.y = _height;
			_HorizontalScrollBar.render();
			this.addChild(_HorizontalScrollBar);
			_HorizontalScrollBar.addEventListener(ScrollBarEvent.EVENT_SCROLL, onHorizontalScroll, false, 0, true);
		}

		protected function createContainers():void
		{
			_ScrollObjectMask = new Sprite();
			_ScrollObjectHolder = new Sprite();
			_ScrollObjectHolder.name = "scoll pane object container";
			_ScrollObjectMask.graphics.beginFill(0xff0000);
			_ScrollObjectMask.graphics.drawRect(0, 0, _width, _height);
			_ScrollObjectMask.graphics.endFill();

			_ScrollObjectHolder.addChild(_ScrollObject);
			_ScrollObjectHolder.addChild(_ScrollObjectMask);
			_ScrollObject.mask = _ScrollObjectMask;
			_ScrollObject.x = 0;
			_ScrollObject.y = 0;

			this.addChild(_ScrollObjectHolder);
		}

		protected function onVerticalScroll(e:ScrollBarEvent):void
		{
			TweenMax.to(_ScrollObject, .5, {y:e.objectToPosition, ease:Quad.easeOut});
		}

		protected function onHorizontalScroll(e:ScrollBarEvent):void
		{
			TweenMax.to(_ScrollObject, .5, {x:e.objectToPosition, ease:Quad.easeOut});
		}

		private function onContentOver(e:MouseEvent):void
		{
			this.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onScrollWheel, false, 0, true);
		}

		private function onContentOut(e:MouseEvent):void
		{
			this.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onScrollWheel);
		}

		protected function onScrollWheel(e:MouseEvent):void
		{
			if(_VerticalScrollBar)
			{
				_VerticalScrollBar.scollOnScrollWheelDelta(e.delta);
			}
			else if(_HorizontalScrollBar)
			{
				_HorizontalScrollBar.scollOnScrollWheelDelta(e.delta);
			}
		}

		/**
		 * Get the size of the component
		 * @return Object with width and heigh props
		 */
		override public function measure():Object
		{
			var mObject:Object = new Object();
			// TODO adjust properly for v/h scrolling
			mObject.width = _width;
			mObject.height = _height;
			return mObject;
		}

		protected function unWatchScrollObject():void
		{
			if(_ScrollObject is TextField)
			{
				if(_ScrollObject.type == TextFieldType.INPUT) _ScrollObject.removeEventListener(TextEvent.TEXT_INPUT, onScrollObjectChange);
			}
		}

		/**
		 * Remove event listeners and remove DisplayObjects from containters
		 */
		override public function destroy():void
		{
			unWatchScrollObject();
			
			if(_ScrollOnMouseWheel)
			{
				this.removeEventListener(MouseEvent.ROLL_OVER, onContentOver);
				this.removeEventListener(MouseEvent.ROLL_OUT, onContentOut);
			}
			
			if(_VerticalScrollBar)
			{
				_VerticalScrollBar.removeEventListener(ScrollBarEvent.EVENT_SCROLL, onVerticalScroll);
				_VerticalScrollBar.destroy();
				this.removeChild(_VerticalScrollBar);
			}
			
			if(_HorizontalScrollBar)
			{
				_HorizontalScrollBar.removeEventListener(ScrollBarEvent.EVENT_SCROLL, onHorizontalScroll);
				_HorizontalScrollBar.destroy();
				this.removeChild(_HorizontalScrollBar);
			}

			_ScrollObjectHolder.removeChild(_ScrollObject);

			_ScrollObjectHolder.removeChild(_ScrollObjectMask);
			_ScrollObject.mask = null;

			this.removeChild(_ScrollObjectHolder);

			_ScrollObjectOrigParent.addChild(_ScrollObject);
			_ScrollObject.x = _OriginX;
			_ScrollObject.y = _OriginY;

			_ScrollObjectMask = null;
			_ScrollObjectHolder = null;
			_ScrollObjectOrigParent = null;
			
			super.destroy();
		}
	}
}