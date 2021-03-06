﻿package com.nudoru.utilities {
	
	/**
	 * Generates random greeking text
	 * 
	 * @author Matt Perkins
	 */
	public class RandomLatin {
		
		private static var LatinText:Array = ["Lorem", "ipsum", "dolor", "sit", "amet", "consectetuer", "adipiscing", "elit", "praesent",
					  "vel", "nibh", "vel", "wisi", "molestie", "placerat", "nunc", "amet","libero", "in",
					  "turpis", "facilisis", "tempor", "Sed", "blandit", "quis", "consequat", "molestie",
					  "orci", "neque", "tincidunt", "nisl", "in", "elementum", "tortor", "vitae", "est",
					  "Donec", "sapien", "Aenean", "eleifend", "purus", "vel", "praesent", "ultricies",
					  "fringilla", "massa", "Etiam", "pede", "sed", "felis", "ac", "ante", "venenatis",
					  "porta", "nullam", "orci", "In", "quis", "diam", "mattis", "augue", "varius"];
		
		private static var StrangeText:Array = ["equation", "attractor", "Lorentz", "analytical", "okonomiyaki", 
					  "domokun", "butterfly", "dimension", "phase", "Poincare", "pendulum", "chaotic", "mandelbrot", "euclidean", "contraction", "sierpinski", "unique"];
		
		public function RandomLatin():void {
			//
		}
		
		public static function get(min:int, max:int):String 
		{
			return getLatinText(min, max);
		}
		
		public function generateLatinString(s:String):String {
			var a:Array = s.split(":");
			var min:int = int(a[1].split(",")[0]);
			var max:int = int(a[1].split(",")[1]);
			return getLatinText(min,max);
		}
		
		public static function getLatinText(minl:int, maxl:int):String {
			var len:int = rnd(minl, maxl);
			var s:String = "";
			for(var i:int=0; i<len; i++) {
				var t:String = LatinText[Math.floor(Math.random()*LatinText.length)].toLowerCase();
				if(i<=len) t+=" ";
				if(i == 0) {
					var a:String = t.charAt(0).toUpperCase();
					var b:String = t.substr(1);
					t = a+b;
				}
				s+=t;
			}
			return s;
		}
		
		public static function rnd(min:int, max:int):int {
			return min + Math.floor(Math.random() * (max + 1 - min));
		}
		
	}
}