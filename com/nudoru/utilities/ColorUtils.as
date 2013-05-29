
package com.nudoru.utilities
{
	public class ColorUtils
	{
		
		//http://snipplr.com/view/22812/hex-to-rgb/
		public static function convertHexToRGB(hex:Number):Object
		{
			var rgbObj:Object = {
				red: ((hex & 0xFF0000) >> 16),
				green: ((hex & 0x00FF00) >> 8),
				blue: ((hex & 0x0000FF))
			};
		 
			return rgbObj;
		}
		
		//http://www.actionscript.org/forums/showthread.php3?t=86158
		public static function convertHexToGreyScale(color:Number):int
		{
			var colors:Object = convertHexToRGB(color);
			return (0.3*colors.red) + (0.59*colors.green) + (0.11*colors.blue);
		}
		
		public static function getDarkerColorBy(color:Number, offset:Number):Number
		{
			var hls:Object = ColorUtils.RGBtoHLS(color);
			var darker:Number = Math.max(hls.l - offset, 0);
			return ColorUtils.HLStoRGB(hls.h, darker, hls.s);
		}
		
		public static function getLighterColorBy(color:Number, offset:Number):Number
		{
			var hls:Object = ColorUtils.RGBtoHLS(color);
			var lighter:Number = Math.min(hls.l + offset, 1);
			return ColorUtils.HLStoRGB(hls.h, lighter, hls.s);
		}
		
		public static function getMonoChromatic(basecolor:Number):Object
		{
			var chromatic:Object = new Object();
			var hls:Object = ColorUtils.RGBtoHLS(basecolor);
			var darkL:Number = Math.max(hls.l - 0.2, 0);
			var lightL:Number = Math.min(hls.l + 0.3, 1);
			chromatic.dark = basecolor;
			chromatic.outline = ColorUtils.HLStoRGB(hls.h, darkL, hls.s);
			chromatic.light = ColorUtils.HLStoRGB(hls.h, lightL, hls.s);
			return chromatic;
		}

		public static function getMonoChromaticSoft(basecolor:Number):Object
		{
			var chromatic:Object = new Object();
			var hls:Object = ColorUtils.RGBtoHLS(basecolor);
			var darkL:Number = Math.max(hls.l - 0.1, 0);
			var vdarkL:Number = Math.max(hls.l - 0.4, 0);
			var lightL:Number = Math.min(hls.l + 0.1, 1);
			var vlightL:Number = Math.min(hls.l + 0.4, 1);
			chromatic.dark = basecolor;
			chromatic.veryDark = ColorUtils.HLStoRGB(hls.h, vdarkL, hls.s);
			chromatic.outline = ColorUtils.HLStoRGB(hls.h, darkL, hls.s);
			chromatic.light = ColorUtils.HLStoRGB(hls.h, lightL, hls.s);
			chromatic.veryLight = ColorUtils.HLStoRGB(hls.h, vlightL, hls.s);
			return chromatic;
		}

		public static function getMonoChromaticGlossy(basecolor:Number):Object
		{
			var chromatic:Object = new Object();
			var hls:Object = ColorUtils.RGBtoHLS(basecolor);

			var lightTop:Number = Math.min(hls.l + 0.2, 1);
			var lightBottom:Number = Math.min(hls.l + 0.02, 1);
			var darkMiddle:Number = Math.max(hls.l - 0.1, 0);
		 	var darkTop:Number  = Math.max(hls.l - 0.05,0);
			var darkBottom:Number = Math.max(hls.l - 0.1, 0);
			var outline:Number = Math.max(hls.l - 0.25, 0);

			chromatic.lightTop = ColorUtils.HLStoRGB(hls.h, lightTop, hls.s);
			chromatic.lightBottom = ColorUtils.HLStoRGB(hls.h, lightBottom, hls.s);
			chromatic.darkMiddle = ColorUtils.HLStoRGB(hls.h, darkMiddle, hls.s);
			chromatic.darkTop = ColorUtils.HLStoRGB(hls.h, darkTop, hls.s);
			chromatic.darkBottom = basecolor;

			chromatic.outline = ColorUtils.HLStoRGB(hls.h, outline, hls.s);

			return chromatic;
		}

		// http://www.dreaminginflash.com/2007/11/19/hls-to-rgb-rgb-to-hls/
		public static function HuetoRGB(m1:Number, m2:Number, h:Number):Number
		{
			if( h < 0 )
			{
				h += 1.0;
			}
			if( h > 1 )
			{
				h -= 1.0;
			}
			if( 6.0 * h < 1 )
			{
				return (m1 + (m2 - m1) * h * 6.0);
			}
			if( 2.0 * h < 1 )
			{
				return m2;
			}
			if( 3.0 * h < 2.0 )
			{
				return (m1 + (m2 - m1) * ((2.0 / 3.0) - h) * 6.0);
			}
			return m1;
		}

		/**
		 * Converte an HLS color to RGB color
		 * // http://www.dreaminginflash.com/2007/11/19/hls-to-rgb-rgb-to-hls/
		 * @example <listing version="3.0">
		 * 
		 * ColorUtils.HLStoRGB(34,3,23);
		 * 
		 * </listing>
		 * 
		 * @param h Hue value 
		 * @param l Luminance value
		 * @param s Saturation value
		 *
		 * @return an integer that represents an RGB color.
		 * 
		 */
		public static function HLStoRGB(H:Number, L:Number, S:Number):Number
		{
			var r:Number;
			var g:Number;
			var b:Number;
			var m1:Number;
			var m2:Number;

			if(S == 0)
			{
				r = g = b = L;
			}
			else
			{
				if(L <= 0.5)
				{
					m2 = L * (1.0 + S);
				}
				else
				{
					m2 = L + S - L * S;
				}
				m1 = 2.0 * L - m2;
				r = HuetoRGB(m1, m2, H + 1.0 / 3.0);
				g = HuetoRGB(m1, m2, H);
				b = HuetoRGB(m1, m2, H - 1.0 / 3.0);
			}
			r = int(r * 255);
			g = int(g * 255);
			b = int(b * 255);
			return r << 16 | g << 8 | b;
		}

		/**
		 * Converte an RGB color to HLS color
		 * // http://www.dreaminginflash.com/2007/11/19/hls-to-rgb-rgb-to-hls/
		 * @example <listing version="3.0">
		 * 
		 * ColorUtils.RGBtoHLS(65280);
		 * 
		 * </listing>
		 * 
		 * @param rgb24 an integer that represents an RGB color.
		 *
		 * @return an object with h,l,s properties
		 */
		public static function RGBtoHLS(rgb24:Number):Object
		{
			var h:Number;
			var l:Number;
			var s:Number;
			var r:Number = (rgb24 >> 16) / 255;
			var g:Number = (rgb24 >> 8 & 0xFF) / 255;
			var b:Number = (rgb24 & 0xFF) / 255;
			var delta:Number;
			var cmax:Number = Math.max(r, Math.max(g, b));
			var cmin:Number = Math.min(r, Math.min(g, b));
			l = (cmax + cmin) / 2.0;
			if(cmax == cmin)
			{
				s = 0;
				h = 0;
			}
			else
			{
				if(l < 0.5)
				{
					s = (cmax - cmin) / (cmax + cmin);
				}
				else
				{
					s = (cmax - cmin) / (2.0 - cmax - cmin);
				}
				delta = cmax - cmin;
				if(r == cmax)
				{
					h = (g - b) / delta;
				}
				else if(g == cmax)
				{
					h = 2.0 + (b - r) / delta;
				}
				else
				{
					h = 4.0 + (r - g) / delta;
				}
				h /= 6.0;
				if(h < 0.0)
				{
					h += 1;
				}
			}
			return {h:h, l:l, s:s};
		}
	}
}