package com.nudoru.components.service
{

	import flash.events.IEventDispatcher;
	
	/**
	 * Data type for a view class
	 */
	public interface IServiceComponent extends IEventDispatcher
	{
		/**
		 * Return the content of the component
		 */
		function get content():*;
		/**
		 * Any initialization steps
		 */
		function initialize(data:*= null):void;
		/**
		 * Draw
		 */
		function load():void;
		/**
		 * Unload
		 */
		function destroy():void;
	}
}