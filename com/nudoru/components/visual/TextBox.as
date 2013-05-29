package com.nudoru.components.visual
{
	import com.nudoru.components.ComponentEvent;
	import com.nudoru.components.ComponentSettings;
	import com.nudoru.components.visual.containers.ScrollPane;
	import flash.text.TextFieldType;


	/**
	 * Text box
	 * 
	 * Sample:
	 * 

	var text:TextBox = new TextBox();
	text.initialize({
	width:250,
	height:200,
	scroll:true,
	content:"It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).",
	font:"Verdana",
	align:"center",
	size:24,
	color:0x333333,
	leading:14,
	bold:false,
	italic:true,
	border:Border.GRAD_SQUARE,
	bordersize:10
	});
	text.render();
	text.x = 10;
	text.y = 10;
	this.addChild(text);
	 */
	public class TextBox extends Label implements IVisualComponent
	{

		protected var _editable:Boolean = false;
		protected var _scroll:Boolean;
		protected var _scrollArea:ScrollPane;
		protected var _border:Border;
		protected var _borderWidth:int;
		protected var _borderHeight:int;
		protected var _borderStyle:String;
		protected var _borderSize:int;
		protected var _borderColors:Array;

		public function TextBox():void
		{
			super();
		}

		/**
		 * Initialize the view
		 */
		override public function initialize(data:*=null):void
		{
			super.initialize(data);

			_content = data.content;
			_scroll = isBool(data.scroll);
 			_selectable = isBool(data.selectable);
 			_editable = isBool(data.editable);
 			
 			initialzeTextFormatData();
 			initializeBorderData();
 			
			validateData();

			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INITIALIZED));
		}

		protected function initializeBorderData():void
		{
			_borderStyle = _initializationData.border;
			_borderSize = _initializationData.bordersize;
			_borderColors = _initializationData.bordercolors;
		}

		override protected function validateData():void
		{
			_borderWidth = _width;
			_borderHeight = _height;
			
			if(!_borderSize) _borderSize = 0;

			if(_borderStyle && _borderSize)
			{
				_width -= _borderSize * 2;
				_height -= _borderSize * 2;
			}

			if(_scroll)
			{
				_width -= ComponentSettings.scrollBarSize;
			}
			
			if(_editable) _selectable = true;
			
			super.validateData();
		}

		/**
		 * Draw the view
		 */
		override public function render():void
		{
			super.render();
			
			if(_editable) _textField.type = TextFieldType.INPUT;
			adjustTextFieldHeight();
			applyBorder();
			this.addChild(_textField);
			applyScrolling();
			
			// BUG/HACK? Can't get the textfield's height unless I first access it, don't know why flash isn't updating
			if(_textField.height) {};
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_RENDERED));
		}

		override protected function adjustTextFieldHeight():void
		{
			if(_height && ! _scroll)
			{
				_textField.height = _height;
			}
			else
			{
				super.adjustTextFieldHeight();
			}
		}

		protected function applyBorder():void
		{
			if(_borderStyle && _borderSize)
			{
				_textField.x = _borderSize;
				_textField.y = _borderSize;

				_border = new Border();
				_border.initialize({border:_borderStyle, size:_borderSize, colors:_borderColors, width:_borderWidth, height:_borderHeight});
				_border.render();
				this.addChild(_border);
			}
		}

		protected function applyScrolling():void
		{
			if(_scroll && _height)
			{
				_scrollArea = new ScrollPane;
				_scrollArea.initialize({barsize:ComponentSettings.scrollBarSize, content:_textField, trim:false, width:_width, height:_height});
				_scrollArea.render();
				this.addChild(_scrollArea);
			}
		}

		/**
		 * Remove event listeners and remove DisplayObjects from containters
		 */
		override public function destroy():void
		{
			if(_border)
			{
				_border.destroy();
				this.removeChild(_border);
				_border = null;
			}

			if(_scrollArea)
			{
				_scrollArea.destroy();
				this.removeChild(_scrollArea);
				_scrollArea = null;
			}

			super.destroy();
		}

	}
}