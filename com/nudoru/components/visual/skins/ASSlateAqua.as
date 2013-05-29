package com.nudoru.components.visual.skins
{
	import flash.display.InterpolationMethod;
	import com.nudoru.visual.drawing.Diagonals;
	import com.nudoru.components.ComponentSettings;
	import com.nudoru.utilities.ColorUtils;
	import com.nudoru.visual.BMUtils;
	import com.nudoru.visual.drawing.SolidArc;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;


	/**
	 * Utility Class to draw UI elements
	 * 
	 * @author Matt Perkins
	 */
	public class ASSlateAqua implements INudoruComponentSkin
	{
		public function ASSlateAqua():void
		{
			setDefaults();
		}
		
		public function setDefaults():void
		{
			ComponentSettings.filterEffects = false;
			ComponentSettings.radius = 7;
			ComponentSettings.buttonRadius = 20;
			ComponentSettings.highlightColor = 0xe31932;
			ComponentSettings.highlightMaxAlpha = .5;
			ComponentSettings.handleColor = 0x717073;
			ComponentSettings.buttonColor = 0x7b8ba0;
			ComponentSettings.buttonLabelColor = 0xffffff;
			ComponentSettings.buttonOverColor = 0x70a1e5;
			ComponentSettings.buttonOverLabelColor = 0xffffff;
			ComponentSettings.buttonDownColor = 0x536379;
			ComponentSettings.buttonDownLabelColor = 0xffffff;
			ComponentSettings.gutterFillColor = 0xffffff;
			ComponentSettings.gutterLineColor = 0xaaaaaa;
			ComponentSettings.gutterShadowColor = 0xcbcacc;
			
			ComponentSettings.windowColor = 0xeceaee;
			ComponentSettings.windowTitleBarColor = 0xc2d5dd;
			
			ComponentSettings.shape = ComponentSettings.SHAPE_ROUND_RECT;
			ComponentSettings.texture = true;
			ComponentSettings.scrollBarArrowButton = false;
		}
		
		private function drawSoftShape(x:int, y:int, width:int, height:int, radius:int, color:Number):Sprite
		{
			var sourceColors:Object = ColorUtils.getMonoChromaticSoft(color);
			
			// 270 and 180 degrees
			var radians:Number = (width > height) || (width == height) ? 4.71238898 : 3.141592654;
			
			var pixelHinting:Boolean = true;
			if(radius < 11 && radius > 4) pixelHinting = false;
			if(width == height) pixelHinting = true;
			
			var tBox:Sprite = new Sprite();
			tBox.x = x;
			tBox.y = y;
			
			var box:Sprite= new Sprite();
			var colors:Array = [sourceColors.dark, sourceColors.light];
			var alphas:Array = [1, 1];
			var ratios:Array = [0, 255];
			var matrix:Matrix = new Matrix;
			matrix.createGradientBox(width,height,radians,0,0);
			
			box.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
			if(ComponentSettings.shape == ComponentSettings.SHAPE_ROUND_RECT) box.graphics.drawRoundRect(0, 0, width, height, radius);
				else box.graphics.drawRect(0,0,width,height);
			box.graphics.endFill();
			
			var outline:Sprite = new Sprite();
			outline.graphics.lineStyle(1,sourceColors.outline,1,pixelHinting);
			if(ComponentSettings.shape == ComponentSettings.SHAPE_ROUND_RECT) outline.graphics.drawRoundRect(0, 0, width, height, radius);
				else outline.graphics.drawRect(0,0,width,height);
			
			var whiteline:Sprite = new Sprite();
			whiteline.graphics.lineStyle(1,0xffffff,1,pixelHinting);
			whiteline.graphics.lineGradientStyle(GradientType.LINEAR, [sourceColors.dark, sourceColors.veryLight], [0,.75], [100, 255], matrix);
			if(ComponentSettings.shape == ComponentSettings.SHAPE_ROUND_RECT) whiteline.graphics.drawRoundRect(1,1,width-2,height-2,radius);
				else whiteline.graphics.drawRect(1,1,width-2,height-2);
			
			whiteline.blendMode = BlendMode.OVERLAY;
			
			tBox.addChild(box);
			tBox.addChild(whiteline);
			tBox.addChild(outline);

			return tBox;
		}
		
		private function drawGlossyShape(x:int, y:int, width:int, height:int, radius:int, color:Number):Sprite
		{
			var sourceColors:Object = ColorUtils.getMonoChromaticGlossy(color);
			
			// 270 degrees
			var radians:Number = 4.71238898;
			
			var pixelHinting:Boolean = true;
			if(radius < 11 && radius > 4) pixelHinting = false;
			if(width == height) pixelHinting = true;
			
			var tBox:Sprite = new Sprite();
			tBox.x = x;
			tBox.y = y;
			
			var box:Sprite= new Sprite();
			var colors:Array = [sourceColors.darkBottom, sourceColors.darkTop,  sourceColors.darkMiddle,  sourceColors.lightBottom, sourceColors.lightTop];
			var alphas:Array = [1, 1, 1, 1, 1];
			var ratios:Array = [0, 126, 127, 128, 255];
			var matrix:Matrix = new Matrix;
			matrix.createGradientBox(width,height,radians,0,0);
			
			box.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix, "pad", InterpolationMethod.LINEAR_RGB);
			if(ComponentSettings.shape == ComponentSettings.SHAPE_ROUND_RECT) box.graphics.drawRoundRect(0, 0, width, height, radius);
				else box.graphics.drawRect(0,0,width,height);
			box.graphics.endFill();
						
			var outline:Sprite = new Sprite();
			outline.graphics.lineStyle(1,sourceColors.outline,1,pixelHinting);
			outline.graphics.lineGradientStyle(GradientType.LINEAR, [sourceColors.outline, sourceColors.darkBottom], [1,1], [0, 255], matrix);
			if(ComponentSettings.shape == ComponentSettings.SHAPE_ROUND_RECT) outline.graphics.drawRoundRect(0, 0, width, height, radius);
				else outline.graphics.drawRect(0,0,width,height);
			
			var whiteline:Sprite = new Sprite();
			whiteline.graphics.lineStyle(1,0xffffff,.5,pixelHinting);
			whiteline.graphics.lineGradientStyle(GradientType.LINEAR, [0xffffff, 0xffffff], [.25,.5], [0, 255], matrix);
			if(ComponentSettings.shape == ComponentSettings.SHAPE_ROUND_RECT) whiteline.graphics.drawRoundRect(1,1,width-2,height-2,radius);
				else whiteline.graphics.drawRect(1,1,width-2,height-2);
			whiteline.blendMode = BlendMode.OVERLAY;
			
			var midline:Sprite = new Sprite();
			midline.graphics.lineStyle(1,sourceColors.darkMiddle,.75,true);
			midline.graphics.moveTo(0,height/2);
			midline.graphics.lineTo(width,height/2);
			
			tBox.addChild(box);
			tBox.addChild(midline);
			tBox.addChild(whiteline);
			tBox.addChild(outline);
			
			addInnerGlow(box, sourceColors.lightTop, 10);

			return tBox;
		}
		
		private function addInnerGlow(mc:DisplayObject, color:Number, blur:int, strength:Number=1):void
		{
            mc.filters = [new GlowFilter(color, 1, blur, blur, strength, BitmapFilterQuality.MEDIUM, true, false)];
		}
		
		private function addOutterGlow(mc:DisplayObject, color:Number, blur:int, strength:Number=1):void
		{
            mc.filters = [new GlowFilter(color, 1, blur, blur, strength, BitmapFilterQuality.MEDIUM, true, false)];
		}
		
		/**
		 * Draw a standardized highlight
		 */
		// createHighlight({x:, y:, width:, height:, expand:, radius:, color:});
		public function createHighlight(metrics:Object):Sprite
		{
			if(!metrics.color) metrics.color = ComponentSettings.highlightColor;
			if(!metrics.expand) metrics.expand = 0;
			if(!metrics.radius) metrics.radius = ComponentSettings.radius + metrics.expand;
			metrics.x -= metrics.expand;
			metrics.y -= metrics.expand;
			metrics.width += metrics.expand * 2;
			metrics.height += metrics.expand * 2;
			var hi:Sprite = new Sprite();

			hi.addChild(drawSoftShape(metrics.x, metrics.y, metrics.width, metrics.height, metrics.radius, metrics.color));
			
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
			tri.graphics.beginFill(ComponentSettings.arrowColor, 1);
			//tri.graphics.lineStyle(1, ComponentSettings.arrowColor, 1);
			tri.graphics.moveTo(metrics.width / 2, 0);
			tri.graphics.lineTo(metrics.width, metrics.height);
			tri.graphics.lineTo(0, metrics.height);
			tri.graphics.lineTo(metrics.width / 2, 0);
			tri.graphics.endFill();

			return tri;
		}
		
		// createPanel({x:, y:, width:, height:, radius:, color:, outlinecolor:, emphasis:});
		public function createPanel(metrics:Object):Sprite
		{
			if(!metrics.color) metrics.color = ComponentSettings.panelColor;
			if(!metrics.radius) metrics.radius = ComponentSettings.radius;
			if(!metrics.outlinecolor) metrics.outlinecolor = ComponentSettings.outlineColor;
			var panel:Sprite = new Sprite();

			if(metrics.emphasis)
			{
				panel.addChild(drawGlossyShape(metrics.x, metrics.y, metrics.width, metrics.height, metrics.radius, metrics.color));
			}
			else
			{
				panel.addChild(drawSoftShape(metrics.x, metrics.y, metrics.width, metrics.height, metrics.radius, metrics.color));
				
				panel.addChild(createOutline({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, expand:-1, color:0xffffff}));
				panel.addChild(createOutline({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, expand:0, color:metrics.outlinecolor}));
			}
			
			return panel;
		}
		
		// createPanel({x:, y:, width:, height:, radius:, color:, outlinecolor:});
		// TODO remove and use emphasized panel
		private function createGlossyPanel(metrics:Object):Sprite
		{
			if(!metrics.color) metrics.color = ComponentSettings.panelColor;
			if(!metrics.radius) metrics.radius = ComponentSettings.radius;
			if(!metrics.outlinecolor) metrics.outlinecolor = ComponentSettings.outlineColor;
			var panel:Sprite = new Sprite();

			panel.addChild(drawGlossyShape(metrics.x, metrics.y, metrics.width, metrics.height, metrics.radius, metrics.color));
			
			//panel.addChild(createOutline({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, expand:-1, color:0xffffff}));
			//panel.addChild(createOutline({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, expand:0, color:metrics.outlinecolor}));
			
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
			// for content
			window.addChild(createPanel({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, radius:metrics.radius, color:metrics.color, outlinecolor:ComponentSettings.windowColor}));
			// for title area
			var titlebar:Sprite = createPanel({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.titleheight, radius:metrics.radius, color:ComponentSettings.windowTitleBarColor, outlinecolor:ComponentSettings.windowColor});
			titlebar.alpha = .5;
			window.addChild(titlebar);
			// outter outline
			window.addChild(createOutline({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, expand:0, color:ComponentSettings.outlineColor}));

			if(metrics.emphasis) window.addChild(createOutline({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, expand:-1, color:ComponentSettings.highlightColor}));

			BMUtils.applyDropShadowFilter(window.getChildAt(0), 5, 45, 0x000000, .50, 20, 1,true);
			
			return window;
		}
		
		// createButtonFaceUp({x:, y:, width:, height:, radius:, color:, emphasis:});
		public function createButtonFaceUp(metrics:Object):Sprite
		{
			if(!metrics.color) metrics.color = ComponentSettings.buttonColor;
			if(!metrics.radius) metrics.radius = ComponentSettings.buttonRadius;
			var button:Sprite = new Sprite();
			
			if(metrics.emphasis) button.addChild(drawSoftShape(metrics.x, metrics.y, metrics.width, metrics.height, metrics.radius, metrics.color));
				else button.addChild(drawGlossyShape(metrics.x, metrics.y, metrics.width, metrics.height, metrics.radius, metrics.color));
				
			return button;
		}
		
		// createButtonFaceOver({x:, y:, width:, height:, radius:, color:, emphasis:});
		public function createButtonFaceOver(metrics:Object):Sprite
		{			
			if(!metrics.color) metrics.color = ComponentSettings.buttonOverColor;
			if(!metrics.radius) metrics.radius = ComponentSettings.buttonRadius;
			
			var colors:Object = ColorUtils.getMonoChromaticGlossy(metrics.color);
			
			var button:Sprite = new Sprite();
			if(metrics.emphasis) button.addChild(drawSoftShape(metrics.x, metrics.y, metrics.width, metrics.height, metrics.radius, metrics.color));
				else button.addChild(drawGlossyShape(metrics.x, metrics.y, metrics.width, metrics.height, metrics.radius, metrics.color));
				
			button.addChild(createOutline({x:metrics.x, y:metrics.y, width:metrics.width, height:metrics.height, radius:metrics.radius, expand:-1, color:ColorUtils.getLighterColorBy(metrics.color, .2)}));
			//addInnerGlow(handle, ColorUtils.getLighterColorBy(metrics.color, .3), 2, 3);
			
				
			return button;
		}
		
		// createButtonFaceDown({x:, y:, width:, height:, radius:, color:, emphasis:});
		public function createButtonFaceDown(metrics:Object):Sprite
		{
			if(!metrics.color) metrics.color = ComponentSettings.buttonDownColor;
			if(!metrics.radius) metrics.radius = ComponentSettings.buttonRadius;
			var button:Sprite = new Sprite();
			if(metrics.emphasis) button.addChild(drawSoftShape(metrics.x, metrics.y, metrics.width, metrics.height, metrics.radius, metrics.color));
				else button.addChild(drawGlossyShape(metrics.x, metrics.y, metrics.width, metrics.height, metrics.radius, metrics.color));
			
			addInnerGlow(button, ColorUtils.getDarkerColorBy(metrics.color, .5), 10);
			
			return button;
		}
		
		// createButtonFaceDisabled({x:, y:, width:, height:, radius:, color:, emphasis:});
		public function createButtonFaceDisabled(metrics:Object):Sprite
		{
			if(!metrics.color) metrics.color = ComponentSettings.buttonDisabledColor;
			if(!metrics.radius) metrics.radius = ComponentSettings.buttonRadius;
			var button:Sprite = new Sprite();
			if(metrics.emphasis) button.addChild(drawSoftShape(metrics.x, metrics.y, metrics.width, metrics.height, metrics.radius, metrics.color));
				else button.addChild(drawGlossyShape(metrics.x, metrics.y, metrics.width, metrics.height, metrics.radius, metrics.color));
			return button;
		}
		
		// need over, down disabled
		
		// createProgressBar({x:, y:, width:, height:, radius:, color:, texture:});
		public function createProgressBar(metrics:Object):Sprite
		{
			if(!metrics.color) metrics.color = ComponentSettings.handleColor;
			if(!metrics.radius) metrics.radius = ComponentSettings.radius;
			var bar:Sprite = new Sprite();
			//if(ComponentSettings.shape == ComponentSettings.SHAPE_ROUND_RECT) var rshape:RoundGradBox = new RoundGradBox(handle, metrics.x, metrics.y, metrics.width, metrics.height, false, metrics.radius ? metrics.radius : ComponentSettings.radius, {bc:metrics.color});
				//else var shape:GradBox = new GradBox(handle, metrics.x, metrics.y, metrics.width, metrics.height, false, {bc:metrics.color});
			bar.addChild(drawGlossyShape(metrics.x, metrics.y, metrics.width, metrics.height, metrics.radius, metrics.color));

			if(ComponentSettings.texture && metrics.texture)
			{
				var barMask:Sprite = new Sprite();
				var barTexture:Diagonals = new Diagonals(metrics.width + 20, metrics.height, 5, 0x000000, 1, 45, 13);
				barMask.graphics.beginFill(0xff0000, 1);
				if(ComponentSettings.shape == ComponentSettings.SHAPE_ROUND_RECT) barMask.graphics.drawRoundRect(metrics.x+1, metrics.y+1, metrics.width-2, metrics.height-2, metrics.radius);
					else barMask.graphics.drawRect(metrics.x+1, metrics.y+1, metrics.width-2, metrics.height-2);
				barMask.graphics.endFill();
				bar.addChild(barTexture);
				bar.addChild(barMask);

				barTexture.mask = barMask;
				barTexture.alpha = .25;
				barTexture.blendMode = BlendMode.OVERLAY;
			}

			return bar;
		}
		
		/**
		 * Draw a standardized handle
		 */
		// createDraggableHandle({x:, y:, width:, height:, radius:, color:, emphasis, });
		public function createDraggableHandle(metrics:Object):Sprite
		{
			if(!metrics.color) metrics.color = ComponentSettings.handleColor;
			if(!metrics.radius) metrics.radius = ComponentSettings.radius;
			var handle:Sprite = new Sprite();
	
			if(metrics.emphasis) handle.addChild(drawGlossyShape(metrics.x, metrics.y, metrics.width, metrics.height, metrics.radius, metrics.color));
				else handle.addChild(drawSoftShape(metrics.x, metrics.y, metrics.width, metrics.height, metrics.radius, metrics.color));

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

			arrow.y += int((highlight.height/2)-(arrow.height/2));

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
			var gutterFill:Sprite = new Sprite();

			if(!metrics.radius) metrics.radius = ComponentSettings.radius;

			gutterFill.graphics.beginFill(ComponentSettings.gutterFillColor, 1);
			if(ComponentSettings.shape == ComponentSettings.SHAPE_ROUND_RECT) gutterFill.graphics.drawRoundRect(metrics.x, metrics.y, metrics.width, metrics.height, metrics.radius);
			else gutterFill.graphics.drawRect(metrics.x, metrics.y, metrics.width, metrics.height);
			gutterFill.graphics.endFill();

			gutterOutline.graphics.lineStyle(1, ComponentSettings.gutterLineColor, 1, true);
			if(ComponentSettings.shape == ComponentSettings.SHAPE_ROUND_RECT) gutterOutline.graphics.drawRoundRect(metrics.x, metrics.y, metrics.width, metrics.height, metrics.radius);
			else gutterOutline.graphics.drawRect(metrics.x, metrics.y, metrics.width, metrics.height);

			gutter.addChild(gutterFill);
			gutter.addChild(gutterOutline);

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
			var darkL:Number  = Math.max(hls.l - 0.1,0);
			var lightL:Number  = Math.min(hls.l + 0.3,1);
			var outlineColor:Number = ColorUtils.HLStoRGB(hls.h, darkL, hls.s);
			var lightColor:Number = ColorUtils.HLStoRGB(hls.h, lightL, hls.s);
			
			var arc:Sprite = new Sprite();
			var radians:Number = (metrics.degrees-90) * (Math.PI/180);
			var colors:Array = [lightColor, outlineColor];
			var alphas:Array = [1, 1];
			var ratios:Array = [100, 255];
			var matrix:Matrix = new Matrix;
			matrix.createGradientBox(metrics.radius*2, metrics.radius*2, radians); 
			arc.graphics.lineStyle(1, darkColor);
			arc.graphics.beginGradientFill(GradientType.RADIAL, colors, alphas, ratios, matrix, "pad", InterpolationMethod.LINEAR_RGB, 1);
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
