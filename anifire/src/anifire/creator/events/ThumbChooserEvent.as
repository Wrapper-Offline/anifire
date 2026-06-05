package anifire.creator.events
{
	import anifire.event.ExtraDataEvent;
	import flash.events.Event;
	
	public class ThumbChooserEvent extends ExtraDataEvent
	{
		public static const THUMB_CHOSEN:String = "tce_thumb_chosen";
		public static const NONE_THUMB_CHOSEN:String = "tce_none_thumb_chosen";
		public var componentThumb:*;
		public var noneComponentThumbType:String;

		public function ThumbChooserEvent(
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
			var cloned:ThumbChooserEvent = new ThumbChooserEvent(
				this.type,
				this.getEventCreater(),
				this.getData(),
				this.bubbles,
				this.cancelable
			);
			cloned.componentThumb = this.componentThumb;
			cloned.noneComponentThumbType = this.noneComponentThumbType;
			return cloned;
		}
	}
}
