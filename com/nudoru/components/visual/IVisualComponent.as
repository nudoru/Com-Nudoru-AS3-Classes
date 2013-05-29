package com.nudoru.components.visual
{

	import com.nudoru.visual.IDisplayObject;

	public interface IVisualComponent extends IDisplayObject
	{
		function get id():String;
		function set id(id:String):void;
		function get enabled():Boolean;
		function set enabled(value:Boolean):void;
		function get align():String;
		function set align(align:String):void;
		function get margin():int;
		function set margin(margin:int):void;
		function initialize(data:*= null):void;
		function render():void;
		function invalidate():void;
		function draw():void;
		function measure():Object;
		function update(data:*= null):void;
		function move(xpos:Number, ypos:Number):void;
		function setSize(w:int, h:int):void;
		function destroy():void;
	}
}