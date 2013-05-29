package com.nudoru.components.visual
{
	import com.nudoru.components.ComponentEvent;

	import flash.events.Event;

	/**
	 * Base event that must be extended by a sub class
	 */
	public class SliderEvent extends ComponentEvent
	{
		public var position:Number;
		
		public static var EVENT_CHANGE:String = "event_change";
		public static var EVENT_HANDLE_OVER:String = "event_handle_over";
		public static var EVENT_HANDLE_OUT:String = "event_handle_out";

		/**
		 * Constructor 
		 * @param	type
		 * @param	bubbles
		 * @param	cancelable
		 */
		public function SliderEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}

		/**
		 * Cone the event
		 * @return	a clone of the event
		 */
		override public function clone():Event
		{
			return new ScrollBarEvent(type, bubbles, cancelable);
		}

		/**
		 * Format the event to a string
		 * @return	String representation of the event
		 */
		override public function toString():String
		{
			return formatToString("SliderEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
	}
}