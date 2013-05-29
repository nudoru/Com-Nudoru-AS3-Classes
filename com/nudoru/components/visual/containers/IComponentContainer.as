package com.nudoru.components.visual.containers
{
	import com.nudoru.components.visual.IVisualComponent;

	/**
	 * @author Matt Perkins
	 */
	public interface IComponentContainer extends IVisualComponent
	{
		
		function get numChildComponents():int;
		
		function addComponent(component:*, initObj:Object, x:int, y:int):void;
		
	}
}
