package anifire.creator.components
{
	import anifire.component.ColorInputPanel;
	import anifire.creator.events.ColorPickerDropDownListEvent;
	import anifire.creator.skins.ColorPickerDropDownListSkin;
	import anifire.event.ColorPaletteEvent;
	import mx.events.FlexEvent;
	import spark.components.DropDownList;
	import spark.events.DropDownEvent;

	[Event(name="colorChange", type="anifire.creator.events.ColorPickerDropDownListEvent")]
	[Event(name="colorCommit", type="anifire.creator.events.ColorPickerDropDownListEvent")]
	public class ColorPickerDropDownList extends DropDownList
	{
		[SkinPart(required="false")]
		public var colorInputPanel:ColorInputPanel;
		
		[SkinPart(required="false")]
		public var colorDisplay:ColorDisplayGroup;
		
		public function ColorPickerDropDownList()
		{
			super();
			setStyle("skinClass", ColorPickerDropDownListSkin);
		}

		/**
		 * Called when a skin part is added. 
		 * You do not call this method directly. 
		 * For static parts, Flex calls it automatically when it calls the <code>attachSkin()</code> method. 
		 * For dynamic parts, Flex calls it automatically when it calls 
		 * the <code>createDynamicPartInstance()</code> method. 
		 *
		 * @param partName The name of the part.
		 * @param instance The instance of the part.
		 */
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			if (instance == this.colorInputPanel) {
				this.colorInputPanel.addEventListener(ColorPaletteEvent.COLOR_PREVIEW, this.colorInputPanel_colorPreviewHandler);
				this.colorInputPanel.addEventListener(ColorPaletteEvent.COLOR_CHANGE, this.colorInputPanel_colorChangeHandler);
				this.colorInputPanel.addEventListener(FlexEvent.CREATION_COMPLETE, this.colorInputPanel_creationCompleteHandler);
			}
		}

		/**
		 * Called when an instance of a skin part is being removed. 
		 * You do not call this method directly. 
		 * For static parts, Flex calls it automatically when it calls the <code>detachSkin()</code> method. 
		 * For dynamic parts, Flex calls it automatically when it calls 
		 * the <code>removeDynamicPartInstance()</code> method. 
		 *
		 * @param partname The name of the part.
		 * @param instance The instance of the part.
		 */
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
			if (instance == this.colorInputPanel) {
				this.colorInputPanel.removeEventListener(ColorPaletteEvent.COLOR_PREVIEW, this.colorInputPanel_colorPreviewHandler);
				this.colorInputPanel.removeEventListener(ColorPaletteEvent.COLOR_CHANGE, this.colorInputPanel_colorChangeHandler);
				this.colorInputPanel.removeEventListener(FlexEvent.CREATION_COMPLETE, this.colorInputPanel_creationCompleteHandler);
			}
		}
		
		private function colorInputPanel_creationCompleteHandler(event:FlexEvent) : void
		{
			this.colorInputPanel.currentColor = this.colorDisplay.color;
		}
		
		private function colorInputPanel_colorChangeHandler(event:ColorPaletteEvent) : void
		{
			this.updateColorFromColorInputPanel();
		}
		
		private function colorInputPanel_colorPreviewHandler(event:ColorPaletteEvent) : void
		{
			this.updateColorFromColorInputPanel();
		}
		
		private function updateColorFromColorInputPanel() : void
		{
			if (this.colorInputPanel) {
				if (this.colorDisplay) {
					this.colorDisplay.color = this.colorInputPanel.currentColor;
				}
				this.dispatchEvent(new ColorPickerDropDownListEvent(ColorPickerDropDownListEvent.COLOR_CHANGE, this.colorInputPanel.currentColor));
			}
		}

		/**
		 * @private
		 * Event handler for the <code>dropDownController</code> 
		 * <code>DropDownEvent.OPEN</code> event. Updates the skin's state and 
		 * ensures that the selectedItem is visible. 
		 */
		override protected function dropDownController_closeHandler(event:DropDownEvent) : void
		{
			if (this.colorInputPanel) {
				this.dispatchEvent(new ColorPickerDropDownListEvent(ColorPickerDropDownListEvent.COLOR_COMMIT, this.colorInputPanel.currentColor));
			}
			super.dropDownController_closeHandler(event);
		}
	}
}
