package com.nudoru.components.visual.containers
{
	import com.nudoru.components.visual.VisualComponent;
	import flash.display.Sprite;

	/**
	 * @author Matt Perkins
	 */
	public class ComponentContainer extends VisualComponent implements IComponentContainer
	{
		protected var _components:Array = [];
		protected var _componentLayer:Sprite = new Sprite();
		
		protected var _layout:Object;
		
		protected var _maxChildren:int = 9999;
		
		public function get numChildComponents():int
		{
			return _components.length;
		}
		
		public function ComponentContainer()
		{
			super();
		}
		
		
		
		/**
		 * Adds another NudoruComponent to the window
		 * Sample:
		 * 	window.addComponent(NudoruGraphic, {url:"assets/testimage.jpg",  width:250, height:250, border:Border.OUTLINE_J, bordersize:10, bordercolors:[0xcccccc, 0x00ff00]}, 300, 50);
		 */
		public function addComponent(component:*, initObj:Object, x:int, y:int):void
		{
			if(numChildComponents == _maxChildren)
			{
				throw(new Error("Cannot add another child component to "+this));
				return;
			}
			
			var comp:* = new component();
			comp.initialize(initObj);
			comp.render();
			comp.x = x;
			comp.y = y;
			_componentLayer.addChild(comp);
			_components.push(comp);
			
			onComponentAdded();
		}
		
		protected function onComponentAdded():void
		{
			// hook
		}
		
		override public function destroy():void
		{
			if(_components)
			{
				for(var ci:int = 0, clen:int = _components.length; ci < clen; ci++)
				{
					_components[ci].destroy();
					_componentLayer.removeChild(_components[ci]);
					_components[ci] = null;
				}
				_components = [];
			}
			
			super.destroy();
		}
	
	}
}
