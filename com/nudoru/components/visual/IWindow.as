package com.nudoru.components.visual
{
	import com.nudoru.components.visual.containers.IComponentContainer;
	
	/**
	 * Data type for a Window
	 */
	public interface IWindow extends IComponentContainer
	{
		
		function get windowType():String;
		
		function get modal():Boolean;
		
		function setDraggable():void;
		
		function removeDraggable():void;
		
		function alignStageCenter():void;
	}
}