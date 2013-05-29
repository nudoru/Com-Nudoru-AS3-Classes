package com.nudoru.components.visual 
{
	import com.nudoru.components.ComponentEvent;
	import com.nudoru.components.service.XMLLoader;
	import com.nudoru.sheet.IPageObject;
	import com.nudoru.sheet.ImageLoader;
	import com.nudoru.sheet.POButton;
	import com.nudoru.sheet.POEM;
	import com.nudoru.sheet.POEvent;
	import com.nudoru.sheet.POEventManager;
	import com.nudoru.sheet.POFactory;
	import com.nudoru.sheet.POGradRect;
	import com.nudoru.sheet.POGradRoundRect;
	import com.nudoru.sheet.POGraphic;
	import com.nudoru.sheet.POGroup;
	import com.nudoru.sheet.POHotspot;
	import com.nudoru.sheet.POInteractiveSWF;
	import com.nudoru.sheet.POShape;
	import com.nudoru.sheet.POText;
	import com.nudoru.sheet.POTextBox;
	import com.nudoru.sheet.PageObject;
	import com.nudoru.sheet.Sheet;
	import com.nudoru.sheet.SheetSettings;
	import com.nudoru.sheet.Transition;
	import flash.events.Event;

	
	/**
	 * Loads a sheet XML file and displays it
	 */
	public class SheetView extends VisualComponent implements IVisualComponent
	{
		
		protected var _url				:String;
		protected var _xmlLoader		:XMLLoader;
		
		protected var _sheet			:Sheet;
		
		/**
		 * Constructor
		 */
		public function SheetView():void
		{
			super();
		}
		
		/**
		 * Initialize the view
		 */
		override public function initialize(data:*=null):void 
		{
			super.initialize(data);
			
			if(data) _url = data.url;
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INITIALIZED));
		}
		
		/**
		 * Draw the view
		 */
		override public function render():void
		{
			super.render();
			
			_xmlLoader = new XMLLoader();
			_xmlLoader.initialize({url:_url});
			_xmlLoader.addEventListener(ComponentEvent.EVENT_PROGRESS, onXMLProgress, false, 0, true);
			_xmlLoader.addEventListener(ComponentEvent.EVENT_LOADED, onXMLLoaded, false, 0, true);
			_xmlLoader.addEventListener(ComponentEvent.EVENT_PARSE_ERROR, onXMLError, false, 0, true);
			_xmlLoader.addEventListener(ComponentEvent.EVENT_IOERROR, onXMLError, false, 0, true);
			_xmlLoader.load();
		}

		protected function onXMLProgress(event:ComponentEvent):void
		{
			var pevent:ComponentEvent = new ComponentEvent(ComponentEvent.EVENT_PROGRESS);
			pevent.data = event.data;
			dispatchEvent(pevent);
		}

		protected function onXMLLoaded(event:Event):void
		{
			renderSheetFromXML(_xmlLoader.content);
		}

		protected function onXMLError(event:Event):void
		{
			trace("NudoruSheet - XML error - "+event.type);
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_IOERROR));
		}
		
		/**
		 * Called when the XML file is has been loaded or call to load specific XML
		 * @param	data
		 */
		public function renderSheetFromXML(data:XML):void
		{
			//trace("renderSheetFromXML: "+data);
			_sheet = new Sheet();
			this.addChild(_sheet);

			_sheet.initialize(data);
			_sheet.addEventListener(Sheet.RENDERED, onSheetRendered, false, 0, true);
			_sheet.render();
		}
		
		/**
		 * The sheet has been rendered, start it
		 * @param	e
		 */
		protected function onSheetRendered(e:Event):void {
			_sheet.removeEventListener(Sheet.RENDERED, onSheetRendered);
			_sheet.start();
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_RENDERED));
		}
		
		/**
		 * Remove event listeners and remove DisplayObjects from containters
		 */
		override public function destroy():void
		{
			if (_xmlLoader) 
			{
				try {
				_xmlLoader.destroy();
				_xmlLoader = null;
				} catch (e:*) { }
			}
			
			if (_sheet) {
				_sheet.stop();
				_sheet.destroy();
				this.removeChild(_sheet);
				_sheet = null;
			}
			
			super.destroy();
		}
	}

}