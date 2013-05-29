package com.nudoru.components.visual.skins
{
	import com.nudoru.components.ComponentSettings;
	import com.nudoru.utilities.ColorUtils;
	import com.nudoru.visual.BMUtils;
	import com.nudoru.visual.drawing.Checkerboard;
	import com.nudoru.visual.drawing.GradBox;
	import com.nudoru.visual.drawing.RoundGradBox;
	import com.nudoru.visual.drawing.SolidArc;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;





	/**
	 * Utility Class to draw UI elements
	 * 
	 * @author Matt Perkins
	 */
	public class ASGradientSkin implements INudoruComponentSkin
	{
		public function ASGradientSkin():void
		{
			setDefaults()
		}
		
		public function setDefaults():void
		{
			//
		}
		
		/**
		 * Draw a standardized highlight
		 */
		// createHighlight({x:, y:, width:, height:, expand:, radius:, color:});
		public function createHighlight(metrics:Object):Sprite
		{
			if(!metrics.color) metrics.color = ComponentSettings.highlightColor;
			if(!metrics.radius) metrics.radius = ComponentSettings.radius;
			if(!metrics.expand) metrics.expand = 0;
			metrics.x -= metrics.expand;
			metrics.y -= metrics.expand;
			metrics.width += metrics.expand * 2;
			metrics.height += metrics.expand * 2;
			var hi:Sprite = new Sprite();
			if(ComponentSettings.shape == ComponentSettings.SHAPE_ROUND_RECT) var rshape:RoundGradBox = new RoundGradBox(hi, metrics.x, metrics.y, metrics.width, metrics.height, false, metrics.radius ? metrics.radius : ComponentSettings.radius + metrics.expand, {bc:metrics.color});
			else var shape:GradBox = new GradBox(hi, metrics.x, metrics.y, metrics.width, metrics.height, false, {bc:metrics.color});
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
			if(!metrics.radius) metrics.radius = ComponentSettings.radius;
			if(!metrics.expand) metrics.expand = 0;
			metrics.x -= metrics.expand;
			metrics.y -= metrics.expand;
			metrics.width += metrics.expand * 2;
			metrics.height += metrics.expand * 2;
			var outline:Sprite = new Sprite();
			outline.graphics.lineStyle(metrics.thickness, metrics.color, 1, true);
			if(ComponentSettings.shape == ComponentSettings.SHAPE_ROUND_RECT) outline.graphics.drawRoundRect(metrics.x, metrics.y, metrics.width, metrics.height, metrics.radius ? metrics.radius : ComponentSettings.radius + metrics.expand);
			else outline.graphics.drawRect(metrics.x, metrics.y, metrics.width, metrics.height);
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
			metrics.height *= .5;
			var tri:Sprite = new Sprite();
			tri.graphics.beginFill(ComponentSettings.arrowColor, .25);
			tri.graphics.lineStyle(1, ComponentSettings.arrowColor, 1);
			tri.graphics.moveTo(metrics.width / 2, 0);
			tri.graphics.lineTo(metrics.width, metrics.height);
			tri.graphics.lineTo(0, metrics.height);
			tri.graphics.lineTo(metrics.width / 2, 0);
			tri.graphics.endFill();

			return tri;
		}
		
		// createPanel({x:, y:, width:, height:, radius:, color:, outlinecolor:});
		public function createPanel(metrics:Object):Sprite
		{
			if(!metrics.color) metrics.color = ComponentSettings.panelColor;
			if(!metrics.radius) metrics.radius = ComponentSettings.radius;
			if(!metrics.outlinecolor) metrics.outlinecolor = ComponentSettings.outlineColor;
			var panel:Sprite = new Sprite();
			if(ComponentSettings.shape == ComponentSettings.SHAPE_ROUND_RECT) var rshape:RoundGradBox = new RoundGradBox(panel, metrics.x, metrics.y, metrics.width, metrics.height, false, metrics.radius ? metrics.radius : ComponentSettings.radius, {bc:metrics.color});
			else var shape:GradBox = new GradBox(panel, metrics.x, metrics.y, metrics.width, metrics.height, false, {bc:metrics.color});
			
			panel.addChild(createOutline({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, expand:-1, color:0xffffff}));
			panel.addChild(createOutline({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, expand:0, color:metrics.outlinecolor}));
			
			return panel;
		}
		
		// createWindow({x:, y:, width:, height:, titleheight, buttonheight:, radius:, color:, emphais:});
		public function createWindow(metrics:Object):Sprite
		{
			if(!metrics.color) metrics.color = ComponentSettings.windowColor;
			if(!metrics.radius) metrics.radius = ComponentSettings.radius;
			
			var contentAreaHeight:int = metrics.height - metrics.buttonheight;
			
			var window:Sprite = new Sprite();
			
			// for shadow
			window.addChild(createPanel({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, radius:metrics.radius, color:0xff0000}));
			// neg for button area
			window.addChild(createNegativeArea({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height}));
			// for content
			window.addChild(createPanel({x:metrics.x, y:metrics.y, width:metrics.width, height:contentAreaHeight, radius:metrics.radius, color:metrics.color, outlinecolor:ComponentSettings.windowColor}));
			// inner outline
			window.addChild(createOutline({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, expand:-1, color:0xffffff}));
			// outter outline
			window.addChild(createOutline({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, expand:0, color:ComponentSettings.outlineColor}));

			if(metrics.emphasis) window.addChild(createOutline({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, expand:-1, color:ComponentSettings.highlightColor}));

			BMUtils.applyDropShadowFilter(window.getChildAt(0), 5, 45, 0x000000, .50, 20, 1,true);
			
			return window;
		}
		
		// createButtonFaceUp({x:, y:, width:, height:, radius:, color:, emphasis:});
		public function createButtonFaceUp(metrics:Object):Sprite
		{
			if(! metrics.color) metrics.color = ComponentSettings.buttonColor;
			if(!metrics.radius) metrics.radius = ComponentSettings.radius;
			var handle:Sprite = new Sprite();
			if(ComponentSettings.shape == ComponentSettings.SHAPE_ROUND_RECT) var rshape:RoundGradBox = new RoundGradBox(handle, metrics.x, metrics.y, metrics.width, metrics.height, false, metrics.radius ? metrics.radius : ComponentSettings.radius, {bc:metrics.color});
			else var shape:GradBox = new GradBox(handle, metrics.x, metrics.y, metrics.width, metrics.height, false, {bc:metrics.color});
			
			if(metrics.emphasis) handle.addChild(createOutline({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, expand:-1, color:ComponentSettings.highlightColor}));
			
			return handle;
		}
		
		// createButtonFaceOver({x:, y:, width:, height:, radius:, color:, emphasis:});
		public function createButtonFaceOver(metrics:Object):Sprite
		{
			if(! metrics.color) metrics.color = ComponentSettings.buttonColor;
			if(!metrics.radius) metrics.radius = ComponentSettings.radius;
			var handle:Sprite = new Sprite();
			if(ComponentSettings.shape == ComponentSettings.SHAPE_ROUND_RECT) var rshape:RoundGradBox = new RoundGradBox(handle, metrics.x, metrics.y, metrics.width, metrics.height, false, metrics.radius ? metrics.radius : ComponentSettings.radius, {bc:metrics.color});
			else var shape:GradBox = new GradBox(handle, metrics.x, metrics.y, metrics.width, metrics.height, false, {bc:metrics.color});
			
			if(metrics.emphasis) handle.addChild(createOutline({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, expand:-1, color:ComponentSettings.highlightColor}));
			
			return handle;
		}
		
		// createButtonFaceDown({x:, y:, width:, height:, radius:, color:, emphasis:});
		public function createButtonFaceDown(metrics:Object):Sprite
		{
			if(! metrics.color) metrics.color = ComponentSettings.buttonColor;
			if(!metrics.radius) metrics.radius = ComponentSettings.radius;
			var handle:Sprite = new Sprite();
			if(ComponentSettings.shape == ComponentSettings.SHAPE_ROUND_RECT) var rshape:RoundGradBox = new RoundGradBox(handle, metrics.x, metrics.y, metrics.width, metrics.height, false, metrics.radius ? metrics.radius : ComponentSettings.radius, {bc:metrics.color});
			else var shape:GradBox = new GradBox(handle, metrics.x, metrics.y, metrics.width, metrics.height, false, {bc:metrics.color});
			
			if(metrics.emphasis) handle.addChild(createOutline({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, expand:-1, color:ComponentSettings.highlightColor}));
			
			return handle;
		}
		
		// createButtonFaceDisabled({x:, y:, width:, height:, radius:, color:, emphasis:});
		public function createButtonFaceDisabled(metrics:Object):Sprite
		{
			if(! metrics.color) metrics.color = ComponentSettings.buttonColor;
			if(!metrics.radius) metrics.radius = ComponentSettings.radius;
			var handle:Sprite = new Sprite();
			if(ComponentSettings.shape == ComponentSettings.SHAPE_ROUND_RECT) var rshape:RoundGradBox = new RoundGradBox(handle, metrics.x, metrics.y, metrics.width, metrics.height, false, metrics.radius ? metrics.radius : ComponentSettings.radius, {bc:metrics.color});
			else var shape:GradBox = new GradBox(handle, metrics.x, metrics.y, metrics.width, metrics.height, false, {bc:metrics.color});
			
			if(metrics.emphasis) handle.addChild(createOutline({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, expand:-1, color:ComponentSettings.highlightColor}));
			
			return handle;
		}
		
		// need over, down disabled
		
		// createDraggableHandle({x:, y:, width:, height:, radius:, color:});
		public function createProgressBar(metrics:Object):Sprite
		{
			if(!metrics.color) metrics.color = ComponentSettings.handleColor;
			if(!metrics.radius) metrics.radius = ComponentSettings.radius;
			var bar:Sprite = new Sprite();
			if(ComponentSettings.shape == ComponentSettings.SHAPE_ROUND_RECT) var rshape:RoundGradBox = new RoundGradBox(bar, metrics.x, metrics.y, metrics.width, metrics.height, false, metrics.radius ? metrics.radius : ComponentSettings.radius, {bc:metrics.color});
				else var shape:GradBox = new GradBox(bar, metrics.x, metrics.y, metrics.width, metrics.height, false, {bc:metrics.color});

			return bar;
		}
		
		/**
		 * Draw a standardized handle
		 */
		// createDraggableHandle({x:, y:, width:, height:, radius:, color:});
		public function createDraggableHandle(metrics:Object):Sprite
		{
			if(!metrics.color) metrics.color = ComponentSettings.handleColor;
			if(!metrics.radius) metrics.radius = ComponentSettings.radius;
			var handle:Sprite = new Sprite();
			if(ComponentSettings.shape == ComponentSettings.SHAPE_ROUND_RECT) var rshape:RoundGradBox = new RoundGradBox(handle, metrics.x, metrics.y, metrics.width, metrics.height, false, metrics.radius ? metrics.radius : ComponentSettings.radius, {bc:metrics.color});
				else var shape:GradBox = new GradBox(handle, metrics.x, metrics.y, metrics.width, metrics.height, false, {bc:metrics.color});

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
			var gutterTexture:Checkerboard = new Checkerboard(1, 0x000000, 0xffffff, metrics.width, metrics.height);
			var gutterFill:Sprite = new Sprite();

			if(!metrics.radius) metrics.radius = ComponentSettings.radius;

			gutterMask.graphics.beginFill(0xff0000, 1);
			if(ComponentSettings.shape == ComponentSettings.SHAPE_ROUND_RECT) gutterMask.graphics.drawRoundRect(metrics.x, metrics.y, metrics.width, metrics.height, metrics.radius);
			else gutterMask.graphics.drawRect(metrics.x, metrics.y, metrics.width, metrics.height);
			gutterMask.graphics.endFill();

			gutterFill.graphics.beginFill(ComponentSettings.gutterFillColor, 1);
			if(ComponentSettings.shape == ComponentSettings.SHAPE_ROUND_RECT) gutterFill.graphics.drawRoundRect(metrics.x, metrics.y, metrics.width, metrics.height, metrics.radius);
			else gutterFill.graphics.drawRect(metrics.x, metrics.y, metrics.width, metrics.height);
			gutterFill.graphics.endFill();

			gutterTexture.x = metrics.x;
			gutterTexture.y = metrics.y;
			gutterTexture.alpha = .25;
			gutterTexture.blendMode = BlendMode.OVERLAY;

			gutterOutline.graphics.lineStyle(1, ComponentSettings.gutterLineColor, 1, true);
			if(ComponentSettings.shape == ComponentSettings.SHAPE_ROUND_RECT) gutterOutline.graphics.drawRoundRect(metrics.x, metrics.y, metrics.width, metrics.height, metrics.radius);
			else gutterOutline.graphics.drawRect(metrics.x, metrics.y, metrics.width, metrics.height);

			gutter.addChild(gutterFill);
			if(ComponentSettings.texture) gutter.addChild(gutterTexture);
			gutter.addChild(gutterMask);
			gutter.addChild(gutterOutline);

			gutterFill.mask = gutterMask;
			gutterTexture.mask = gutterMask;

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
			var darkColor:Number = metrics.color;
			var hls:Object = ColorUtils.RGBtoHLS(darkColor);
			var darkL:Number  = Math.max(hls.l - 0.2,0);
			var lightL:Number  = Math.min(hls.l + 0.3,1);
			var outlineColor:Number = ColorUtils.HLStoRGB(hls.h, darkL, hls.s);
			var lightColor:Number = ColorUtils.HLStoRGB(hls.h, lightL, hls.s);
			
			var arc:Sprite = new Sprite();
			var colors:Array = [darkColor, lightColor];
			var alphas:Array = [1, 1];
			var ratios:Array = [0, 255];
			var matrix:Matrix = new Matrix;
			matrix.createGradientBox(metrics.radius*2, metrics.radius*2, 45);
			arc.graphics.lineStyle(1, lightColor);
			arc.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
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
			var gutterTexture:Checkerboard = new Checkerboard(1, 0x000000, 0xffffff, metrics.radius*2, metrics.radius*2);
			var gutterFill:Sprite = createRing({radius:metrics.radius, size:metrics.size, border:metrics.border, segments:metrics.segments, fill:ComponentSettings.gutterFillColor});

			gutterTexture.x = metrics.x;
			gutterTexture.y = metrics.y;
			gutterTexture.alpha = .25;
			gutterTexture.blendMode = BlendMode.OVERLAY;
				
			gutter.addChild(gutterFill);
			if(ComponentSettings.texture) gutter.addChild(gutterTexture);
			gutter.addChild(gutterMask);
			gutter.addChild(gutterOutline);
			
			gutterFill.mask = gutterMask;
			gutterTexture.mask = gutterMask;

			//gutter.blendMode = BlendMode.MULTIPLY;
			// glow blur is the smaller of width or height
			BMUtils.applyGlowFilter(gutter, ComponentSettings.gutterShadowColor, .75, metrics.size, 1, true);
			return gutter;
		}
	}
}
