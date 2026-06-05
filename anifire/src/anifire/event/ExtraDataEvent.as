package anifire.event
{
	import flash.events.Event;
	
	public class ExtraDataEvent extends Event
	{
		public static const UPDATE:String = "update";
		public static const PITCH_UPDATE:String = "pitch_update";	
		public static const PROCESSING:String = "processing";

		private var _data:Object;
		private var _eventCreater:Object;

		public function ExtraDataEvent(
			type:String,
			creator:Object,
			data:Object = null,
			bubbles:Boolean = false,
			cancellable:Boolean = false
		)
		{
			super(type, bubbles, cancellable);
			this.setData(data);
			this.setEventCreater(creator);
		}

		public function getEventCreater() : Object
		{
			return this._eventCreater;
		}

		private function setEventCreater(creator:Object) : void
		{
			this._eventCreater = creator;
		}

		public function getData() : Object
		{
			return this._data;
		}

		private function setData(data:Object) : void
		{
			this._data = data;
		}

		override public function clone() : Event
		{
			return new ExtraDataEvent(
				this.type,
				this.getEventCreater(),
				this.getData(),
				this.bubbles,
				this.cancelable
			);
		}
	}
}
