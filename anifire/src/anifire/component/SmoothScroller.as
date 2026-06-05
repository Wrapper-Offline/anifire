package anifire.component
{
	import spark.components.Scroller;
	import flash.events.MouseEvent;
	import spark.utils.MouseEventUtil;
	import mx.events.FlexMouseEvent;
	import spark.core.IViewport;
	import flash.events.Event;

	/**
	 * does exactly what the name suggests
	 */
	public class SmoothScroller extends Scroller
	{
		private var direction:int;
		private var exp:Number;

		public function SmoothScroller()
		{
			super();
		}

		/**
		 *  @private
		 */
		override protected function attachSkin():void
		{
			super.attachSkin();
			skin.addEventListener(MouseEvent.MOUSE_WHEEL, skin_mouseWheelHandler, true, 10);
		}
		
		/**
		 *  @private
		 */
		override protected function detachSkin():void
		{
			skin.removeEventListener(MouseEvent.MOUSE_WHEEL, skin_mouseWheelHandler, true);
			super.detachSkin();
		}

		private function skin_mouseWheelHandler(event:MouseEvent) : void
		{
			event.stopImmediatePropagation();
			event.stopPropagation();

			const vp:IViewport = viewport;
			if (event.isDefaultPrevented() || !vp || !vp.visible)
				return;

			direction = event.delta < 0 ? 1 : -1;
			exp = 0;

			// Dispatch the "mouseWheelChanging" event. If preventDefault() is called
			// on this event, the event will be cancelled.  Otherwise if  the delta
			// is modified the new value will be used.
			var changingEvent:FlexMouseEvent = MouseEventUtil.createMouseWheelChangingEvent(event);
			changingEvent.delta = direction * 94;
			if (!dispatchEvent(changingEvent)) {
				event.preventDefault();
				return;
			}

			addEventListener(Event.ENTER_FRAME, this.scrollDecay);
			event.preventDefault();
		}

		/**
		 * scrolls a certain amont, with the amount decreasing
		 * exponentially every frame until 0 is reached
		 */
		private function scrollDecay(event:Event = null) : void
		{
			const vp:IViewport = viewport;
			if (event.isDefaultPrevented() || !vp || !vp.visible)
				return;

			var amt:Number = (60 * Math.exp(-this.exp)) * this.direction;
			if (Math.abs(amt) < 1) {
				removeEventListener(Event.ENTER_FRAME, this.scrollDecay);
				this.exp = 0;
				this.direction = null;
				return;
			}
			if (verticalScrollBar && verticalScrollBar.visible) {
				vp.verticalScrollPosition += amt;
			} else if (horizontalScrollBar && horizontalScrollBar.visible) {
				vp.horizontalScrollPosition += amt;
			}
			exp++;
		}
	}
}
