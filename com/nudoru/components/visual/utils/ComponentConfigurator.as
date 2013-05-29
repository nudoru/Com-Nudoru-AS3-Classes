/**
 * Modified to support my Nudoru Component Class
 * Matt Perkins, 2/25/11
 * Changes:
 * 	Removed XML loading
 * 	My components initialize props via an initialization object. changed to allow for that rather than direct prop setting
 * 	Added destroy 
 *
 *
 *
 * ORIGIONAL COPYRIGHT BELOW:
 *
 * MinimalConfigurator.as
 * Keith Peters
 * version 0.9.9
 * 
 * A class for parsing xml layout code to create minimal components declaratively.
 * 
 * Copyright (c) 2011 Keith Peters
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package com.nudoru.components.visual.utils
{
	import com.nudoru.components.visual.Button;
	import com.nudoru.components.visual.Graphic;
	import com.nudoru.components.visual.LinearProgressBar;
	import com.nudoru.components.visual.RadialProgressBar;
	import com.nudoru.components.visual.SheetView;
	import com.nudoru.components.visual.Slider;
	import com.nudoru.components.visual.TextBox;
	import com.nudoru.components.visual.Window;
	import com.nudoru.components.visual.containers.ScrollPane;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getDefinitionByName;



	/**
	 * Creates and lays out minimal components based on a simple xml format.
	 */
	public class ComponentConfigurator extends EventDispatcher
	{
		protected var parent:DisplayObjectContainer;
		protected var idMap:Object;

		/**
		 * Constructor.
		 * @param parent The display object container on which to create components and look for ids and event handlers.
		 */
		public function ComponentConfigurator(parent:DisplayObjectContainer)
		{
			this.parent = parent;
			idMap = new Object();
		}

		/**
		 * Parses a string as xml.
		 * @param string The xml string to parse.
		 */
		public function parseXMLString(string:String):void
		{
			try
			{
				var xml:XML = new XML(string);
				parseXML(xml);
			}
			catch(e:Error)
			{
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}

		/**
		 * Parses xml and creates componetns based on it.
		 * @param xml The xml to parse.
		 */
		public function parseXML(xml:XML):void
		{
			// root tag should contain one or more component tags
			// each tag's name should be the base name of a component, i.e. "Button"
			// package is assumed "com.nudoru.components"

			for(var i:int = 0; i < xml.children().length(); i++)
			{
				var comp:XML = xml.children()[i];
				var compInst:Object = parseComp(comp);
				if(compInst != null)
				{
					compInst.render();
					parent.addChild(compInst as DisplayObject);
				}
			}
		}

		/**
		 * Parses a single component's xml.
		 * @param xml The xml definition for this component.
		 * @return A component instance.
		 */
		private function parseComp(xml:XML):Object
		{
			var compInst:Object;
			try
			{
				var classRef:Class = getDefinitionByName("com.nudoru.components.visual." + xml.name()) as Class;
				compInst = new classRef();
				// trace(classRef +' = '+compInst);
				// id is special case, maps to name as well.
				var id:String = trim(xml.@id.toString());
				if(id != "")
				{
					compInst.name = id;
					idMap[id] = compInst;

					// if id exists on parent as a public property, assign this component to it.
					if(parent.hasOwnProperty(id))
					{
						parent[id] = compInst;
					}
				}

				// event is another special case
				/*if(xml.@event.toString() != "")
				{
				// events are in the format: event="eventName:eventHandler"
				// i.e. event="click:onClick"
				var parts:Array = xml.@event.split(":");
				var eventName:String = trim(parts[0]);
				var handler:String = trim(parts[1]);
				if(parent.hasOwnProperty(handler))
				{
				// if event handler exists on parent as a public method, assign it as a handler for the event.
				compInst.addEventListener(eventName, parent[handler]);
				}
				}*/

				var initObject:Object = new Object();

				// every other attribute handled essentially the same
				for each(var attrib:XML in xml.attributes())
				{
					var prop:String = attrib.name().toString();
					// trace(attrib.name().toString() +" = "+attrib);
					initObject[prop] = attrib;
				}

				if(! initObject.content) initObject.content = xml;

				compInst.initialize(initObject);

				// my components don't have children
				// child nodes will be added as children to the instance just created.
				/*for(var j:int = 0; j < xml.children().length(); j++)
				{
				var child:Object = parseComp(xml.children()[j]);
				if(child != null)
				{
				compInst.addChild(child);
				}
				}*/
			}
			catch(e:Error)
			{
				trace("ComponentConfigurator: Error creating " + xml.name());
			}
			return compInst as Object;
		}

		/**
		 * Returns the componet with the given id, if it exists.
		 * @param id The id of the component you want.
		 * @return The component with that id, if it exists.
		 */
		public function getCompById(id:String):Object
		{
			return idMap[id];
		}

		/**
		 * Trims a string.
		 * @param s The string to trim.
		 * @return The trimmed string.
		 */
		private function trim(s:String):String
		{
			// http://jeffchannell.com/ActionScript-3/as3-trim.html
			return s.replace(/^\s+|\s+$/gs, '');
		}

		public function destroy():void
		{
			for each(var component:Object in idMap)
			{
				component.destroy();
			}
		}

		/**
		 * This method merely serves to include all component classes in the swf.
		 */
		private function comprefs():void
		{
			Button;
			Graphic;
			LinearProgressBar;
			RadialProgressBar;
			ScrollPane;
			Slider;
			SheetView;
			TextBox;
			// won't compile properly with this TextBoxTLF;
			Window;
		}
	}
}