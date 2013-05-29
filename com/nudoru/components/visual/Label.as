package com.nudoru.components.visual
{
	import com.nudoru.components.ComponentEvent;
	import com.nudoru.components.ComponentSettings;
	import com.nudoru.visual.BMUtils;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;


	/**
	 * Text box
	 * 
	 * Sample:
	 * 
	import com.nudoru.components.NudoruTextBox;
	import com.nudoru.components.Border;

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
	public class Label extends VisualComponent implements IVisualComponent
	{
		protected var _content:String;
		protected var _fontName:String;
		protected var _fontAlign:String;
		protected var _fontSize:int;
		protected var _fontColor:int;
		protected var _fontLeading:int;
		protected var _fontKerning:Number;
		protected var _isBold:Boolean;
		protected var _isItalic:Boolean;
		protected var _isUnderline:Boolean;
		protected var _selectable:Boolean = false;
		protected var _textField:TextField;


		public function get tfWidth():int
		{
			return _width;
		}

		public function set tfWidth(width:int):void
		{
			_width = width;
		}

		public function get tfWeight():int
		{
			return _height;
		}

		public function set tfWeight(height:int):void
		{
			_height = height;
		}

		public function get content():String
		{
			return _content;
		}

		public function set content(content:String):void
		{
			_content = content;
		}

		public function get textHeight():int
		{
			// getting the height of the text field give better results than textHeight
			return _textField.height;
		}

		public function get textWidth():int
		{
			return _textField.textWidth;
		}

		public function get textField():TextField
		{
			return _textField;
		}

		public function Label():void
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
 			_selectable = isBool(data.selectable);
 			
 			initialzeTextFormatData();

			validateData();

			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INITIALIZED));
		}

		protected function initialzeTextFormatData():void
		{
			_fontName = _initializationData.font;
			_fontAlign = _initializationData.align;
			_fontSize = int(_initializationData.size);
			_fontColor = int(_initializationData.color);
			_fontLeading = int(_initializationData.leading);
			_fontKerning = Number(_initializationData.kerning);
			_isBold = isBool(_initializationData.bold);
			_isItalic = isBool(_initializationData.italic);
			_isUnderline = isBool(_initializationData.underline);
		}


		override protected function validateData():void
		{
			if(! _fontName) _fontName = ComponentSettings.fontName;
			if(! _fontAlign) _fontAlign = TextFormatAlign.LEFT;
			if(! _fontSize) _fontSize = ComponentSettings.fontSize;
			if(! _fontColor) _fontColor = ComponentSettings.fontColor;
		}

		/**
		 * Draw the view
		 */
		override public function render():void
		{
			super.render();
			
			_textField = createTextField();
			adjustTextFieldHeight();
			_textField.defaultTextFormat = createTextFormat();
			_textField.htmlText = _content;
			
			applyTextFieldHacks();

			this.addChild(_textField);

			// BUG/HACK? Can't get the textfield's height unless I first access it, don't know why flash isn't updating
			if(_textField.height) {};

			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_RENDERED));
		}

		protected function createTextField():TextField
		{
			var txtfield:TextField = new TextField();
			txtfield.name = "__nudoru_label_txt";
			txtfield.width = _width;
			txtfield.wordWrap = true;
			txtfield.multiline = true;
			txtfield.selectable = _selectable;
			
			txtfield.type = TextFieldType.DYNAMIC;
			
			if(_fontName != "_sans") txtfield.embedFonts = true;
			
			txtfield.antiAliasType = AntiAliasType.ADVANCED;

			// PIXEL fit enhances readability for LEFT aligned text
			// SUBPIXEL is best for center/right aligned
			if(_fontAlign == TextFieldAutoSize.LEFT || ! _fontAlign) txtfield.gridFitType = GridFitType.PIXEL;
				else txtfield.gridFitType = GridFitType.SUBPIXEL;
			txtfield.mouseWheelEnabled = false;
			
			return txtfield;
		}

		protected function adjustTextFieldHeight():void
		{
			// this will adjust with autosize, just setting since the default is 100
			_textField.height = 1;
			// should probably use constants here, but that would require an if block, TextFieldAutoSize.LEFT;
			if(_fontAlign) _textField.autoSize = _fontAlign;
				else _textField.autoSize = TextFieldAutoSize.LEFT;
		}

		protected function applyTextFieldHacks():void
		{
			// Possible fixes for random issues from here:
			// http://play.blog2t.net/fixing-jumpy-htmltext-links/
			// http://destroytoday.com/blog/2008/08/workaround-001-actionscripts-autosize-bug/
			var tfheight:Number = _textField.height;
			_textField.autoSize = TextFieldAutoSize.NONE;
			_textField.height = tfheight + Number(_textField.getTextFormat().leading) + 1;
		}

		protected function createTextFormat():TextFormat
		{
			var format:TextFormat = new TextFormat();
			if(_fontName) format.font = _fontName;
			if(_fontAlign) format.align = _fontAlign;
			if(_fontColor) format.color = _fontColor;
			if(_fontSize) format.size = _fontSize;
			if(_fontLeading) format.leading = _fontLeading;
			if(_isBold) format.bold = true;
			if(_isItalic) format.italic = true;
			if(_isUnderline) format.underline = true;
			return format;
		}

		override public function addPopShadow(color:Number = 0xffffff):void
		{
			BMUtils.applyDropShadowFilter(_textField, 1, 45, color, 1, 0, 1);
		}

		/**
		 * Get the size of the component
		 * @return Object with width and heigh props
		 */
		override public function measure():Object
		{
			var mObject:Object = new Object();
			mObject.width = this.width;
			if(_height)
			{
				if(textHeight > _height) mObject.height = _height;
				else mObject.height = textHeight;
			}
			else
			{
				mObject.height = textHeight;
			}
			return mObject;
		}

		/**
		 * Remove event listeners and remove DisplayObjects from containters
		 */
		override public function destroy():void
		{

			this.removeChild(_textField);
			_textField = null;

			super.destroy();
		}

	}
}