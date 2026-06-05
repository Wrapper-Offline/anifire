package anifire.creator.components
{
	import flash.events.KeyboardEvent;
	import spark.components.List;
	import anifire.models.creator.CCBodyModel;
	import spark.utils.LabelUtil;
	import mx.core.mx_internal;
	import spark.components.IItemRenderer;
	import mx.core.IVisualElement;
	import flash.geom.Point;
	import flash.display.DisplayObject;
	import mx.events.SandboxMouseEvent;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import mx.managers.DragManager;
	import flash.display.DisplayObjectContainer;
	import mx.events.FlexMouseEvent;
	
	public class ThumbList extends List
	{
		private static var NONE_THUMB_LABEL:String = "None";
		private var exp:Number = 0;
		private var direction:int;

		public function ThumbList()
		{
			super();
			super.labelField = "id";
		}

		private var _char:CCBodyModel;

		public function get char() : CCBodyModel
		{
			return this._char;
		}

		public function set char(value:CCBodyModel) : void
		{
			this._char = value;
			if (!this.dataGroup) {
				return;
			}
			for (var i:int = 0; i < dataGroup.numElements; i++) {
				var renderer:Object = dataGroup ? dataGroup.getElementAt(i) : null;
				if (renderer is ComponentItemRenderer) {
					renderer.refreshColor();
				}
			}
		}
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			switch (instance) {
				case this.scroller:
					this.scroller.addEventListener(FlexMouseEvent.MOUSE_WHEEL_CHANGING, this.scroller_mouseWheelChanging, true);
					break;
			}
		}

		/**
		 *  @private
		 *  Handles <code>MouseEvent.MOUSE_DOWN</code> events from any of the 
		 *  item renderers. This method handles the updating and commitment 
		 *  of selection as well as remembers the mouse down point and
		 *  attaches <code>MouseEvent.MOUSE_MOVE</code> and
		 *  <code>MouseEvent.MOUSE_UP</code> listeners in order to handle
		 *  drag gestures.
		 *
		 *  @param event The MouseEvent object.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override protected function item_mouseDownHandler(event:MouseEvent):void
		{
			// someone else handled it already since this is cancellable thanks to 
			// some extra code in SystemManager that redispatches a cancellable version 
			// of the same event
			if (event.isDefaultPrevented())
				return;
			
			// Handle the fixup of selection
			var newIndex:int;
			if (event.currentTarget is IItemRenderer)
				newIndex = IItemRenderer(event.currentTarget).itemIndex;
			else
				newIndex = dataGroup.getElementIndex(event.currentTarget as IVisualElement);
			
			mx_internal::pendingSelectionOnMouseUp = true;
			mx_internal::pendingSelectionCtrlKey = event.ctrlKey;
			mx_internal::pendingSelectionShiftKey = event.shiftKey;
			
			mx_internal::mouseDownPoint = event.target.localToGlobal(new Point(event.localX, event.localY));
			mx_internal::mouseDownObject = event.currentTarget as DisplayObject;
			mx_internal::mouseDownIndex = newIndex;
			
			if (mx_internal::pendingSelectionOnMouseUp)
			{
				systemManager.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpHandler, false, 0, true);
				systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
			}
		}

		/**
		 *  @private
		 *  Handles <code>MouseEvent.MOUSE_DOWN</code> events from any mouse
		 *  targets contained in the list including the renderers. This method
		 *  finds the renderer that was pressed and prepares to receive
		 *  a <code>MouseEvent.MOUSE_UP</code> event.
		 *
		 *  @param event The MouseEvent object.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override protected function mouseUpHandler(event:Event):void
		{
			// If dragging failed, but we had a pending selection, commit it here
			if (mx_internal::pendingSelectionOnMouseUp && !DragManager.isDragging)
			{
				// this selectionChange check is basically a "click" check to make sure we moused downed on 
				// the same item that we moused up on.
				// We could just put it in click handler, but this is a little easier in mouseup
				// since we've combined some dragging logic and some touch interaction 
				// logic around pendingSelectionOnMouseUp.
				var selectionChange:Boolean = (event.target == mx_internal::mouseDownObject || 
					(mx_internal::mouseDownObject is DisplayObjectContainer && 
						DisplayObjectContainer(mx_internal::mouseDownObject).contains(event.target as DisplayObject)));
				
				// check to make sure they clicked on an item and selection should change
				if (selectionChange)
				{
					// now handle the cases where the item is being selected or de-selected
					// based on allowMultipleSelection
					if (allowMultipleSelection)
					{
						mx_internal::setSelectedIndices(calculateSelectedIndices(mx_internal::mouseDownIndex, mx_internal::pendingSelectionShiftKey, mx_internal::pendingSelectionCtrlKey), true);
					}
					else
					{
						setSelectedIndex(mx_internal::mouseDownIndex, true);
					}
				}
			}

			// Always clean up the flag, even if currently dragging.
			mx_internal::pendingSelectionOnMouseUp = false;
			
			mx_internal::mouseDownPoint = null;
			mx_internal::mouseDownObject = null;
			mx_internal::mouseDownIndex = -1;
			
			systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false);
			systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false);
			systemManager.getSandboxRoot().removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpHandler, false);
		}

		override public function itemToLabel(item:Object) : String
		{
			var label:String = LabelUtil.itemToLabel(item, labelField, labelFunction);
			return label ? label : NONE_THUMB_LABEL;
		}

		override protected function keyDownHandler(event:KeyboardEvent) : void
		{
		}

		private function scroller_mouseWheelChanging(event:FlexMouseEvent) : void
		{
			dispatchEvent(event);
		}
	}
}
