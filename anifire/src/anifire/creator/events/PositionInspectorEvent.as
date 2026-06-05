package anifire.creator.events
{
	import anifire.models.creator.CCBodyComponentModel;
	import anifire.event.ExtraDataEvent;
	import flash.events.Event;
	
	public class PositionInspectorEvent extends ExtraDataEvent
	{
		public static const UP_BUTTON_CLICK:String = "up_button_click";
		public static const DOWN_BUTTON_CLICK:String = "down_button_click";
		public static const LEFT_BUTTON_CLICK:String = "left_button_click";
		public static const RIGHT_BUTTON_CLICK:String = "right_button_click";
		public static const DPAD_MOUSE_DOWN:String = "dpad_mouse_down";
		public static const DPAD_MOUSE_UP:String = "dpad_mouse_up";
		public static const LOCATION_UPDATE:String = "location_update";
		public var dpad_action:String;
		public var bodyComponent:CCBodyComponentModel;
		public var undoable:Boolean;

		public function PositionInspectorEvent(
			type:String,
			creator:Object,
			data:Object = null,
			bubbles:Boolean = false,
			cancelable:Boolean = false
		)
		{
			super(type, creator, data, bubbles, cancelable);
		}

		override public function clone() : Event
		{
			var event:PositionInspectorEvent = new PositionInspectorEvent(
				this.type,
				this.getEventCreater(),
				this.getData(),
				this.bubbles,
				this.cancelable
			);
			event.bodyComponent = this.bodyComponent;
			return event;
		}
	}
}
