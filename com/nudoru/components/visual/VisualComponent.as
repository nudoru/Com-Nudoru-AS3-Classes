package com.nudoru.components.visual
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.nudoru.accessibility.AccUtilities;
	import com.nudoru.components.ComponentEvent;
	import com.nudoru.components.ComponentSettings;
	import com.nudoru.components.visual.containers.layout.Align;
	import com.nudoru.utilities.DisplayObjectUtilities;
	import com.nudoru.visual.BMUtils;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;

	public class VisualComponent extends Sprite implements IVisualComponent
	{
		protected var _initializationData:Object;
		protected var _id:String;
		protected var _width:int;
		protected var _height:int;
		protected var _enabled:Boolean = true;
		protected var _ShowBorder:Boolean;
		protected var _PerspProj:PerspectiveProjection;

		protected var _align:String;
		protected var _margin:int;

		protected var _paddingTop:int;
		protected var _paddingRight:int;
		protected var _paddingBottom:int;
		protected var _paddingLeft:int;

		public function get id():String
		{
			return _id;
		}

		public function set id(id:String):void
		{
			_id = id;
		}

		public function get enabled():Boolean
		{
			return _enabled;
		}

		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			//mouseEnabled = mouseChildren = !value;
			if(_enabled) showEnabled();
			else showDisabled();
		}

		override public function set width(w:Number):void
		{
			_width = w;
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_RESIZE));
			invalidate();
		}

		override public function get width():Number
		{
			return _width;
		}

		override public function set height(h:Number):void
		{
			_height = h;
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_RESIZE));
			invalidate();
		}

		override public function get height():Number
		{
			return _height;
		}

		// keep the component on a whole pixel
		override public function set x(value:Number):void
		{
			super.x = Math.round(value);
		}

		// keep the component on a whole pixel
		override public function set y(value:Number):void
		{
			super.y = Math.round(value);
		}

		public function get align():String
		{
			return _align;
		}

		public function set align(align:String):void
		{
			_align = align;
		}

		public function get margin():int
		{
			return _margin;
		}

		public function set margin(margin:int):void
		{
			_margin = margin;
		}

		
		public function get paddingTop():int
		{
			return _paddingTop;
		}

		public function set paddingTop(paddingTop:int):void
		{
			_paddingTop = paddingTop;
		}

		public function get paddingRight():int
		{
			return _paddingRight;
		}

		public function set paddingRight(paddingRight:int):void
		{
			_paddingRight = paddingRight;
		}

		public function get paddingBottom():int
		{
			return _paddingBottom;
		}

		public function set paddingBottom(paddingBottom:int):void
		{
			_paddingBottom = paddingBottom;
		}

		public function get paddingLeft():int
		{
			return _paddingLeft;
		}

		public function set paddingLeft(paddingLeft:int):void
		{
			_paddingLeft = paddingLeft;
		}

		public function VisualComponent():void
		{
			super();
		}

		public function initialize(data:*=null):void
		{
			if(! data) return;

			_initializationData = data;

			if(_initializationData.x) this.x = int(_initializationData.x);
			if(_initializationData.y) this.y = int(_initializationData.y);

			_width = _initializationData.width;
			_height = _initializationData.height;
			
			_align =_initializationData.align;
			_margin = int(_initializationData.margin);
			
			_ShowBorder = _initializationData.debugShowBorder;
			
			if(!_align) _align = Align.LEFT;
			if(!_margin) _margin = 10;
		}

		protected function validateData():void
		{
		}

		public function render():void
		{
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
			
			if(_ShowBorder) showBoder();
		}

		public function applyPerspectiveProjectionAtCenter(mc:Object):void
		{
			if(!mc) mc = this;
			
			_PerspProj = new PerspectiveProjection();
			_PerspProj.fieldOfView = 100;
			_PerspProj.projectionCenter = new Point(_width/2, _height/2);

			mc.transform.perspectiveProjection = _PerspProj;
		}

		public function resetPerspectiveProjection(mc:Object):void
		{
			if(!mc) mc = this;
		
			DisplayObjectUtilities.resetMatrixTransformation(mc);	
		}

		// redraws the component on the next frame
		public function invalidate():void
		{
			addEventListener(Event.ENTER_FRAME, onInvalidate);
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INVALIDATE));
		}

		protected function onInvalidate():void
		{
			removeEventListener(Event.ENTER_FRAME, onInvalidate);
			draw();
		}

		public function draw():void
		{
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_DRAW));
		}

		protected function showEnabled():void
		{
			TweenMax.to(this, .25, {alpha:1, colorTransform:{tint:ComponentSettings.disabledTintColor, tintAmount:0}, ease:Quad.easeOut});
		}

		protected function showDisabled():void
		{
			TweenMax.to(this, .25, {alpha:.5, colorTransform:{tint:ComponentSettings.disabledTintColor, tintAmount:.75}, ease:Quad.easeOut});
		}

		public function measure():Object
		{
			var mObject:Object = new Object();
			mObject.width = this.width;
			mObject.height = this.height;
			return mObject;
		}

		public function setAccessibilityProperties(mc:*, name:String, desc:String = "", shortcut:String = "", simple:Boolean = false):void
		{
			if(! mc) mc = this;
			AccUtilities.setProperties(mc, name, desc, shortcut, simple);
		}

		public function excludeFromAccessibility(mc:*):void
		{
			if(! mc) mc = this;
			AccUtilities.exclude(mc);
		}

		public function move(xpos:Number, ypos:Number):void
		{
			x = Math.round(xpos);
			y = Math.round(ypos);
		}

		public function setSize(w:int, h:int):void
		{
			width = w;
			height = w;
		}

		public function update(data:*= null):void
		{
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_UPDATED));
		}

		/**
		 * Adds a single pixel shadow on the lower right. 2.0 trendy 1px shadow line
		 * @param	color
		 */
		public function addPopShadow(color:Number = 0xffffff):void
		{
			BMUtils.applyDropShadowFilter(this, 1, 45, color, 1, 0, 1);
		}

		public function showBoder():void
		{
			var size:Object = measure();
			this.graphics.lineStyle(1, 0, 1);
			this.graphics.drawRect(0, 0, size.width, size.height);
		}

		/**
		 * Dispatch events
		 */
		protected function dispatchComponentEvent(eventType:String, data:String = undefined):void
		{
			var pevent:ComponentEvent = new ComponentEvent(eventType);
			pevent.data = data;
			dispatchEvent(pevent);
		}

		/**
		 * Dispatched at various times for each component
		 */
		public function dispatchActivateEvent(data:String = undefined):void
		{
			dispatchComponentEvent(ComponentEvent.EVENT_ACTIVATE, data);
		}

		/**
		 * Dispatched at various times for each component
		 */
		public function dispatchDeactivateEvent(data:String = undefined):void
		{
			dispatchComponentEvent(ComponentEvent.EVENT_DEACTIVATE, data);
		}

		/**
		 * Dispatched at various times for each component
		 */
		public function dispatchClickEvent(data:String = undefined):void
		{
			dispatchComponentEvent(ComponentEvent.EVENT_CLICK, data);
		}

		protected function isBool(s:String):Boolean
		{
			if(!s) return false;
			if(s.toLowerCase().indexOf("t") == 0) return true;
			return false;
		}

		/**
		 * When the component is removed from the stage, run the destroy() function
		 */
		protected function onRemovedFromStage(event:Event):void
		{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			try
			{
				destroy();
			}
			catch(e:*)
			{
				trace("AbsVisComp, error during destroy");
			}
		}

		public function destroy():void
		{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_DESTROYED));
		}

	}
}