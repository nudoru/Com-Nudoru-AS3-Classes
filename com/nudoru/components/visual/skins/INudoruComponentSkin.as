package com.nudoru.components.visual.skins
{
	import flash.display.Sprite;
	/**
	 * @author Matt Perkins
	 */
	public interface INudoruComponentSkin
	{
		function setDefaults():void;
		
		function createHighlight(metrics:Object):Sprite;
		function createOutline(metrics:Object):Sprite;
		function createArrow(metrics:Object):Sprite;
		function createPanel(metrics:Object):Sprite;
		function createWindow(metrics:Object):Sprite;
		
		function createButtonFaceUp(metrics:Object):Sprite;
		function createButtonFaceOver(metrics:Object):Sprite;
		function createButtonFaceDown(metrics:Object):Sprite;
		function createButtonFaceDisabled(metrics:Object):Sprite;
		function createProgressBar(metrics:Object):Sprite;
		function createDraggableHandle(metrics:Object):Sprite;
		function createArrowButton(metrics:Object):Sprite;
		
		function createNegativeArea(metrics:Object):Sprite;
		
		function createArc(metrics:Object):Sprite;
		function createRing(metrics:Object):Sprite;
		function createNegativeAreaRing(metrics:Object):Sprite;
		
	}
}
