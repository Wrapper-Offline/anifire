package anifire.event
{
	import flash.events.Event;
	import flash.geom.Point;
	
	public class ColorPaletteEvent extends Event
	{
		public static const COLOR_PICKER_DROP:String = "colorPickerDrop";
		public static const SWATCH_PICK:String = "swatchPick";
		public static const ADD_COLOR_BUTTON_CLICK:String = "addColorButtonClick";
		public static const ALPHA_CHANGE:String = "alphaChange";
		public static const ALPHA_PREVIEW:String = "alphaPreview";
		public static const COLOR_CHANGE:String = "colorChange";
		public static const COLOR_PREVIEW:String = "colorPreview";
		public var alpha:Number;
		public var colorCode:Object;
		public var releasePoint:Point;
		public var light:Boolean;
		
		public function ColorPaletteEvent(bubbles:String, cancelable:Boolean = false, currentTarget:Boolean = false)
		{
			super(bubbles, cancelable, currentTarget);
		}
	}
}
