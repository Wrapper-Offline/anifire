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
		
		public function CcColorPickerEvent(param1:String, param2:Object, param3:Object = null, param4:Boolean = false, param5:Boolean = false)
		{
			super(param1,param2,param3,param4,param5);
		}
	}
}
