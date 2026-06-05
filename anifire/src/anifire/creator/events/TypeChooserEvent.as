package anifire.creator.events
{
	import anifire.event.ExtraDataEvent;
	import flash.events.Event;
	
	public class TypeChooserEvent extends ExtraDataEvent
	{
		public static const SELECT:String = "tc_select";
		public var componentType:String;

		public function TypeChooserEvent(
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
			var cloned:TypeChooserEvent = new TypeChooserEvent(
				this.type,
				this.getEventCreater(),
				this.getData(),
				this.bubbles,
				this.cancelable
			);
			cloned.componentType = this.componentType;
			return cloned;
		}
	}
}
