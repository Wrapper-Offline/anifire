package anifire.creator.events
{
	import anifire.event.ExtraDataEvent;
	import flash.events.Event;
	import anifire.creator.commands.IHistoryCommand;
	
	public class HistoryManagerEvent extends ExtraDataEvent
	{
		public static const UPDATE:String = "hme_update";
		public var command:IHistoryCommand;
		public var updateCaret:Boolean;

		public function HistoryManagerEvent(
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
			var cloned:HistoryManagerEvent = new HistoryManagerEvent(
				this.type,
				this.getEventCreater(),
				this.getData(),
				this.bubbles,
				this.cancelable
			);
			cloned.command = this.command;
			return cloned;
		}
	}
}
