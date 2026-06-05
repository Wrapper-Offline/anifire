package anifire.creator.events
{
	import anifire.models.creator.CCBodyComponentModel;
	import anifire.event.ExtraDataEvent;
	
	public class MultiComponentChooserEvent extends ExtraDataEvent
	{
		public static const MOUSE_OVER:String = "bcce_mouse_over";
		public static const MOUSE_OUT:String = "bcce_mouse_out";
		public static const SELECT:String = "bcce_select";
		public static const DELETE:String = "bcce_delete";
		public var bodyComponent:CCBodyComponentModel;

		public function MultiComponentChooserEvent(
			type:String,
			creator:Object,
			data:Object = null,
			bubbles:Boolean = false,
			cancelable:Boolean = false
		)
		{
			super(type, creator, data, bubbles, cancelable);
		}
	}
}
