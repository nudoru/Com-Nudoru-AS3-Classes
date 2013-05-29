package com.nudoru.accessibility
{
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.Dictionary;
	import flash.accessibility.Accessibility;
	import flash.accessibility.AccessibilityProperties;
	import flash.system.Capabilities;
	
	/**
	 * Accessibility Utilities
	 * 
	 * Manages the tab index and accessibility properties of DisplayObjects
	 * 
	 * @author Matt Perkins
	 */
	public class AccUtilities
	{
		private static var _tabCounter:int = 10;
		private static var _watchedObjects:Dictionary = new Dictionary(true);
		private static var _updateDelayTimer:Timer;
		
		static public function get tabCounter():int
		{
			return _tabCounter;
		}
		
		static public function set tabCounter(value:int):void
		{
			_tabCounter = value;
		}

		/**
		 * Set accessibility properties of an item. 
		 * More information: http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/accessibility/AccessibilityProperties.html
		 * @param	mc	Component or sprite to set (if undefined, defaults to component)
		 * @param	name	Accessibility name
		 * @param	desc	Accessibility description
		 * @param	shortcut	Accessibility shortcut key
		 */
		public static function setProperties(mc:*, name:String, desc:String="", shortcut:String="", simple:Boolean = true):void
		{
			_watchedObjects[mc] = mc;
			
			setTextProperties(mc, name, desc, shortcut, simple);
			mc.tabIndex = tabCounter++;
			mc.tabEnabled = true;
			
			startUpdateTimer();
		}

		private static function setTextProperties(mc:*, name:String, desc:String="", shortcut:String="", simple:Boolean = true):void
		{
			var accessProps:AccessibilityProperties = new AccessibilityProperties();
			accessProps.name = name;
			accessProps.description = desc;
			accessProps.shortcut = shortcut;
			accessProps.forceSimple = simple;
			accessProps.noAutoLabeling = false;
			mc.accessibilityProperties = accessProps;
		}

		/**
		 * Excludes all accessiblity from an item
		 * @param	mc	Component or sprite to set (if undefined, defaults to component)
		 */
		public static function exclude(mc:*):void {
			var wasWatchedItem:Boolean = false;
			
			if(_watchedObjects[mc])
			{
				wasWatchedItem = true;
				delete _watchedObjects[mc];
			}
			
			var accessProps:AccessibilityProperties = new AccessibilityProperties();
			accessProps.silent = true;
			mc.accessibilityProperties = accessProps;
			mc.tabIndex = -1;
			mc.tabEnabled = false;
			
			if(wasWatchedItem) startUpdateTimer();
		}

		private static function startUpdateTimer():void
		{
			if(!_updateDelayTimer)
			{
				_updateDelayTimer = new Timer(100,1);
			}
			else
			{
				stopUpdateTimer();
			}
			
			_updateDelayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onUpdateTimerComplete);
			_updateDelayTimer.start();
		}
	
		private static function stopUpdateTimer():void
		{
			if(_updateDelayTimer)
			{
				_updateDelayTimer.stop();
				_updateDelayTimer.reset();
				_updateDelayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onUpdateTimerComplete);
			}
		}

		private static function onUpdateTimerComplete(event:TimerEvent):void
		{
			updateAccessibilityInformation();
		}

		/**
		 * Update accessibility information
		 */
		public static function updateAccessibilityInformation():void
		{
			// remove items that have no parent - they've been removed from the display list
			validateWatchedItems();
			// reset the tabIndex, set it to itself
			resetTabIndicesOfWatchedItems();
			// clear this timer cycle
			stopUpdateTimer();
			// update the assistive system
			if(Capabilities.hasAccessibility) Accessibility.updateProperties();
		}
		
		private static function validateWatchedItems():void
		{
			for each(var item:Object in _watchedObjects)
			{
				if(!item.parent)
				{
					//trace(item.name + " has no parent!");
					delete _watchedObjects[item];
				}
			}
		}
		
		private static function resetTabIndicesOfWatchedItems():void
		{
			for each(var item:Object in _watchedObjects)
			{
				item.tabIndex = item.tabIndex; //_tabCounter++;
				//trace("setting: "+item.name+" to "+item.tabIndex +" - "+item.parent);
			}
		}
	
	}
	
}