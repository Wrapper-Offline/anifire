package anifire.creator.events
{
	import anifire.event.ExtraDataEvent;
	import anifire.models.creator.CCColor;
	
	public class CcColorPickerEvent extends ExtraDataEvent
	{
		public static const COLOR_CHOSEN:String = "color_chosen";
		public var color:CCColor;
		public var colorValue:uint;
		public var undoable:Boolean = true;
		
		public function CcColorPickerEvent(
			type:String,
			creator:Object,
			data:Object = null,
			bubbles:Boolean = false,
			cancellable:Boolean = false
		)
		{
			super(type, creator, data, bubbles, cancellable);
		}
	}
}
