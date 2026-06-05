package anifire.creator.events
{
	import anifire.event.ExtraDataEvent;
	import flash.events.Event;
	
	public class CommandBarEvent extends ExtraDataEvent
	{
		public static const PREVIEW_FLIP:String = "prev_flip";

		public function CommandBarEvent(
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
			var cloned:CommandBarEvent = new CommandBarEvent(
				this.type,
				this.getEventCreater(),
				this.getData(),
				this.bubbles,
				this.cancelable
			);
			return cloned;
		}
	}
}
