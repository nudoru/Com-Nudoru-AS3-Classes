package com.nudoru.components.visual.skins
{
	import flash.display.JointStyle;
	import flash.display.CapsStyle;
	import com.greensock.layout.ScaleMode;
	import com.nudoru.components.ComponentSettings;
	import com.nudoru.visual.BMUtils;
	import com.nudoru.visual.drawing.SolidArc;

	import flash.display.Sprite;

	/**
	 * Utility Class to draw UI elements
	 * 
	 * @author Matt Perkins
	 */
	public class ASDefault implements INudoruComponentSkin
	{
		public function ASDefault():void
		{
			setDefaults()
		}
		
		public function setDefaults():void
		{
			ComponentSettings.filterEffects = false;
			ComponentSettings.radius = 0;
			ComponentSettings.buttonRadius = 0;
			ComponentSettings.scrollBarBorder = -2;
			ComponentSettings.sliderBorder = -2;
			ComponentSettings.highlightColor = 0xe31932;
			ComponentSettings.highlightMaxAlpha = .5;
			ComponentSettings.handleColor = 0x717073;
			ComponentSettings.buttonColor = 0x7b8ba0;
			ComponentSettings.buttonLabelColor = 0xffffff;
			ComponentSettings.buttonOverColor = 0x70a1e5;
			ComponentSettings.buttonOverLabelColor = 0xffffff;
			ComponentSettings.buttonDownColor = 0x536379;
			ComponentSettings.buttonDownLabelColor = 0xffffff;
			ComponentSettings.gutterFillColor = 0xeeeeee;
			ComponentSettings.gutterLineColor = 0xaaaaaa;
			ComponentSettings.gutterShadowColor = 0xcccccc;
			
			ComponentSettings.windowColor = 0xffffff;
			ComponentSettings.windowTitleBarColor = 0xc2d5dd;
			
			ComponentSettings.shape = ComponentSettings.SHAPE_RECT;
			ComponentSettings.texture = false;
			ComponentSettings.scrollBarArrowButton = true;
		}
		
		/**
		 * Draw a standardized highlight
		 */
		// createHighlight({x:, y:, width:, height:, expand:, radius:, color:});
		public function createHighlight(metrics:Object):Sprite
		{
			if(!metrics.color) metrics.color = ComponentSettings.highlightColor;
			if(!metrics.expand) metrics.expand = 0;
			metrics.x -= metrics.expand;
			metrics.y -= metrics.expand;
			metrics.width += metrics.expand * 2;
			metrics.height += metrics.expand * 2;
			var hi:Sprite = new Sprite();
			hi.graphics.beginFill(metrics.color);
			hi.graphics.drawRect(metrics.x, metrics.y, metrics.width, metrics.height);
			hi.graphics.endFill();
			return hi;
		}

		/**
		 * Draw a standardized outline
		 */
		// createOutline({x:, y:, width:, height:, expand:, color:, thickness:, radius:}):Sprite
		public function createOutline(metrics:Object):Sprite
		{
			if(!metrics.color) metrics.color = ComponentSettings.outlineColor;
			if(!metrics.thinkness) metrics.thickness = 0;
			if(!metrics.expand) metrics.expand = 0;
			metrics.x -= metrics.expand;
			metrics.y -= metrics.expand;
			metrics.width += metrics.expand * 2;
			metrics.height += metrics.expand * 2;
			var outline:Sprite = new Sprite();
			outline.graphics.lineStyle(metrics.thickness, metrics.color, 1, true);
			outline.graphics.drawRect(metrics.x, metrics.y, metrics.width, metrics.height);
			return outline;
		}
		
		/**
		 * Draw a common arrow shape
		 * @param	width
		 * @param	height
		 * @return
		 */
		// createArrow({width:, height:});
		public function createArrow(metrics:Object):Sprite
		{
			var tri:Sprite = new Sprite();
			metrics.height *= .5;
			tri.graphics.lineStyle(2, ComponentSettings.arrowColor, 1, false, ScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
			tri.graphics.moveTo(metrics.width / 2, 0);
			tri.graphics.lineTo(metrics.width, metrics.height);
			tri.graphics.moveTo(0, metrics.height);
			tri.graphics.lineTo(metrics.width / 2, 0);

			return tri;
		}
		
		// createPanel({x:, y:, width:, height:, radius:, color:, outlinecolor});
		public function createPanel(metrics:Object):Sprite
		{
			if(!metrics.color) metrics.color = ComponentSettings.panelColor;
			if(!metrics.outlinecolor) metrics.outlinecolor = ComponentSettings.outlineColor;
			
			var panel:Sprite = new Sprite();
			
			panel.graphics.beginFill(metrics.color);
			panel.graphics.drawRect(metrics.x, metrics.y, metrics.width, metrics.height);
			panel.graphics.endFill();
			
			panel.addChild(createOutline({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, expand:-1, color:0xffffff}));
			panel.addChild(createOutline({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, expand:0, color:metrics.outlinecolor}));
			
			return panel;
		}
		
		// createWindow({x:, y:, width:, height:, titleheight, buttonheight:, radius:, color:, emphais:});
		public function createWindow(metrics:Object):Sprite
		{
			if(! metrics.color) metrics.color = ComponentSettings.windowColor;

			var window:Sprite = new Sprite();
			
			window.graphics.beginFill(metrics.color);
			window.graphics.drawRect(metrics.x, metrics.y, metrics.width, metrics.height);
			window.graphics.endFill();
			
			window.addChild(createNegativeArea({x:metrics.x, y:metrics.y+metrics.height-metrics.buttonheight, width:metrics.width, height:metrics.buttonheight}))
			
			window.addChild(createOutline({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, expand:-1, color:0xffffff}));
			window.addChild(createOutline({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, expand:0, color:ComponentSettings.outlineColor}));
			
			if(metrics.emphasis) window.addChild(createOutline({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, expand:-1, color:ComponentSettings.highlightColor}));
			
			return window;
		}
		
		// createButtonFaceUp({x:, y:, width:, height:, radius:, color:, emphasis:});
		public function createButtonFaceUp(metrics:Object):Sprite
		{
			if(! metrics.color) metrics.color = ComponentSettings.buttonColor;
			var button:Sprite = new Sprite();
			
			button.graphics.beginFill(metrics.color);
			button.graphics.drawRect(metrics.x, metrics.y, metrics.width, metrics.height);
			button.graphics.endFill();
			
			if(metrics.emphasis) button.addChild(createOutline({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, color:ComponentSettings.highlightColor}));
			
			return button;
		}
		
		// createButtonFaceOver({x:, y:, width:, height:, radius:, color:, emphasis:});
		public function createButtonFaceOver(metrics:Object):Sprite
		{
			if(! metrics.color) metrics.color = ComponentSettings.buttonColor;
			var button:Sprite = new Sprite();
			
			button.graphics.beginFill(metrics.color);
			button.graphics.drawRect(metrics.x, metrics.y, metrics.width, metrics.height);
			button.graphics.endFill();
			
			if(metrics.emphasis) button.addChild(createOutline({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, color:ComponentSettings.highlightColor}));
			
			return button;
		}
		
		// createButtonFaceDown({x:, y:, width:, height:, radius:, color:, emphasis:});
		public function createButtonFaceDown(metrics:Object):Sprite
		{
			if(! metrics.color) metrics.color = ComponentSettings.buttonColor;
			var button:Sprite = new Sprite();
			
			button.graphics.beginFill(metrics.color);
			button.graphics.drawRect(metrics.x, metrics.y, metrics.width, metrics.height);
			button.graphics.endFill();
			
			if(metrics.emphasis) button.addChild(createOutline({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, color:ComponentSettings.highlightColor}));
			
			return button;
		}
		
		// createButtonFaceDisabled({x:, y:, width:, height:, radius:, color:, emphasis:});
		public function createButtonFaceDisabled(metrics:Object):Sprite
		{
			if(! metrics.color) metrics.color = ComponentSettings.buttonColor;
			var button:Sprite = new Sprite();
			
			button.graphics.beginFill(metrics.color);
			button.graphics.drawRect(metrics.x, metrics.y, metrics.width, metrics.height);
			button.graphics.endFill();
			
			if(metrics.emphasis) button.addChild(createOutline({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, color:ComponentSettings.highlightColor}));
			
			return button;
		}
		
		// createDraggableHandle({x:, y:, width:, height:, radius:, color:});
		public function createProgressBar(metrics:Object):Sprite
		{
			if(!metrics.color) metrics.color = ComponentSettings.arrowColor;
			if(!metrics.radius) metrics.radius = ComponentSettings.radius;
			var bar:Sprite = new Sprite();
			
			//handle.graphics.lineStyle(0, ComponentSettings.outlineColor, .25, true);
			bar.graphics.beginFill(metrics.color);
			bar.graphics.drawRect(metrics.x, metrics.y, metrics.width, metrics.height);
			bar.graphics.endFill();
			
			return bar;
		}
		
		/**
		 * Draw a standardized handle
		 */
		// createDraggableHandle({x:, y:, width:, height:, radius:, color:});
		public function createDraggableHandle(metrics:Object):Sprite
		{
			if(!metrics.color) metrics.color = ComponentSettings.arrowColor;
			if(!metrics.radius) metrics.radius = ComponentSettings.radius;
			var handle:Sprite = new Sprite();
			
			//handle.graphics.lineStyle(0, ComponentSettings.outlineColor, .25, true);
			handle.graphics.beginFill(metrics.color);
			handle.graphics.drawRect(metrics.x, metrics.y, metrics.width, metrics.height);
			handle.graphics.endFill();
			
			return handle;
		}

		/**
		 * Draws a standardized arrow button
		 */
		// createArrowButton({width:, height:, contract:});
		public function createArrowButton(metrics:Object):Sprite
		{
			var button:Sprite = new Sprite();
			var arrow:Sprite = createArrow({width:metrics.width - metrics.contract, height:metrics.height - metrics.contract});
			arrow.x += int(metrics.contract / 2);
			arrow.y += int(metrics.contract / 2);
			var highlight:Sprite = createHighlight({x:0, y:0, width:metrics.width, height:metrics.height});
			highlight.name = "hi_mc";
			highlight.alpha = 0;

			button.addChild(arrow);
			button.addChild(highlight);
			return button;
		}

		/**
		 * Creates a "gutter" area - scroll bar track, progress bar background, etd.
		 * Here to standardize the look across components
		 */
		// createNegativeArea({x:, y:, width:, height:, radius:});
		public function createNegativeArea(metrics:Object):Sprite
		{
			var gutter:Sprite = new Sprite();
			var gutterOutline:Sprite = new Sprite();
			var gutterMask:Sprite = new Sprite();
			var gutterFill:Sprite = new Sprite();

			gutterMask.graphics.beginFill(0xff0000, 1);
			gutterMask.graphics.drawRect(metrics.x, metrics.y, metrics.width, metrics.height);
			gutterMask.graphics.endFill();

			gutterFill.graphics.beginFill(ComponentSettings.gutterFillColor, 1);
			gutterFill.graphics.drawRect(metrics.x, metrics.y, metrics.width, metrics.height);
			gutterFill.graphics.endFill();

			//gutterOutline.graphics.lineStyle(1, ComponentSettings.gutterLineColor, .5, true);
			gutterOutline.graphics.drawRect(metrics.x, metrics.y, metrics.width, metrics.height);

			gutter.addChild(gutterFill);
			gutter.addChild(gutterMask);
			gutter.addChild(gutterOutline);

			gutterFill.mask = gutterMask;

			// gutter.blendMode = BlendMode.MULTIPLY;
			// glow blur is the smaller of width or height
			BMUtils.applyGlowFilter(gutter, ComponentSettings.gutterShadowColor, .75, ((metrics.height > metrics.width ? metrics.width : metrics.height) / 2), 1, true);
			return gutter;
		}

		
		
		/**
		 * Draws the arc with a gradient fill. Same code as the Grad box drawing functions
		 * @return
		 */
		// createArc({degrees:, radius:, size:, segments:, color:});
		public function createArc(metrics:Object):Sprite
		{
			var arc:Sprite = new Sprite();

			//arc.graphics.lineStyle(1, metrics.color);
			
			arc.graphics.beginFill(metrics.color);
			SolidArc.draw(arc, metrics.radius, metrics.radius, metrics.radius-metrics.size, metrics.radius, -90/360, metrics.degrees/360, metrics.segments);
			arc.graphics.endFill();
			
			return arc;
		}
		
		/**
		 * Utility to draw a full circle - used for the gutter
		 * @param	fill	color
		 * @return
		 */
		// createRing({radius:, size:, border:, segments:, fill:});
		public function createRing(metrics:Object):Sprite
		{
			var circ:Sprite = new Sprite();
			circ.graphics.beginFill(metrics.fill, 1);
			SolidArc.draw(circ, metrics.radius, metrics.radius, metrics.radius-(metrics.size+metrics.border), metrics.radius+metrics.border, -90/360, 360/360, metrics.segments);
			circ.graphics.endFill();
			return circ;
		}
		
		/**
		 * Creates a "gutter" area
		 * This code/style is duplicated from the NudoruVisualComponent base class
		 */
		// createNegativeAreaRing({x:, y:, radius:, size:, border:, segments:});
		public function createNegativeAreaRing(metrics:Object):Sprite
		{

			var gutter:Sprite = new Sprite();
			var gutterOutline:Sprite = new Sprite();
			var gutterMask:Sprite = createRing({radius:metrics.radius, size:metrics.size, border:metrics.border, segments:metrics.segments});
			var gutterFill:Sprite = createRing({radius:metrics.radius, size:metrics.size, border:metrics.border, segments:metrics.segments, fill:ComponentSettings.gutterFillColor});

				
			gutter.addChild(gutterFill);
			gutter.addChild(gutterMask);
			gutter.addChild(gutterOutline);
			
			gutterFill.mask = gutterMask;

			//gutter.blendMode = BlendMode.MULTIPLY;
			// glow blur is the smaller of width or height
			BMUtils.applyGlowFilter(gutter, ComponentSettings.gutterShadowColor, .75, metrics.size, 1, true);
			return gutter;
		}
	}
}
