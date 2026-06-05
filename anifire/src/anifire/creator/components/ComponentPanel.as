package anifire.creator.components {
	import anifire.models.creator.CCThemeModel;
	import anifire.models.creator.CCBodyModel;
	import anifire.constant.CcLibConstant;
	import anifire.creator.events.TypeChooserEvent;
	import anifire.creator.events.ThumbChooserEvent
	import anifire.models.creator.CCComponentModel;
	import anifire.models.creator.CCBodyComponentModel;
	import anifire.creator.events.MultiComponentChooserEvent;
	import anifire.creator.commands.IHistoryCommand;
	import anifire.creator.commands.ComponentRemove;
	import anifire.creator.commands.ComponentAdd;
	import anifire.creator.managers.HistoryManager;
	import anifire.models.creator.CCLibraryModel;
	import anifire.creator.commands.LibraryAdd;
	import anifire.creator.commands.LibraryRemove;
	import anifire.creator.events.CcColorPickerEvent;
	import anifire.creator.commands.ColorUpdate;
	import anifire.models.creator.CCColor;
	import spark.components.supportClasses.SkinnableComponent;
	import anifire.creator.skins.ComponentPanelSkin;
	import spark.components.SkinnableContainer;
	import anifire.creator.commands.LocationUpdate;
	import anifire.creator.events.PositionInspectorEvent;

	public class ComponentPanel extends SkinnableComponent
	{
		private var _currentType:String;
		private var _theme:CCThemeModel;
		private var _char:CCBodyModel;

		[SkinPart(required="true")]
		public var multiComponentChooser:MultiComponentChooser;

		[SkinPart(required="true")]
		public var propertyBox:PropertyBox;

		[SkinPart(required="true")]
		public var slidingPanel:SkinnableContainer;

		[SkinPart(required="true")]
		public var thumbChooser:ThumbChooser;

		[SkinPart(required="true")]
		public var typeChooser:TypeChooser;

		public function ComponentPanel()
		{
			super();
			setStyle("skinClass", ComponentPanelSkin);
		}

		override public function set width(value:Number) : void
		{
			super.width = value;
			propertyBox.left = 660 + (value - 660) / 2 - (propertyBox.width / 2);
		}

		override public function set height(value:Number) : void
		{
			super.height = value;
			slidingPanel.height = value;
			var biggerHeight:Number = value - typeChooser.height;
			var smallerHeight:Number = biggerHeight - multiComponentChooser.height;
			thumbChooser.biggerHeight = biggerHeight;
			thumbChooser.smallerHeight = smallerHeight;
			thumbChooser.height = thumbChooser.thumbnailTileSpark.height =
				CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(this._currentType) == -1 ?
					biggerHeight : smallerHeight;
		}

		/**
		 * returns the currently selected library or component
		 */
		public function get selected() : * {
			if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(this._currentType) > -1) {
				return this.multiComponentChooser.selectedBodyComponent;
			} else if (CcLibConstant.ALL_COMPONENT_TYPES.indexOf(this._currentType) > -1) {
				return this._char.components[this._currentType];
			} else {
				return this._char.libraries[this._currentType];
			}
		}

		/**
		 * initialize all components
		 */
		public function init(theme:CCThemeModel, char:CCBodyModel) : void
		{
			this._theme = theme;
			this._char = char;
			this.typeChooser.init(theme, char);
		}

		/**
		 * updates selection caret to match the result of a new command
		 */
		public function updateCaret(command:IHistoryCommand) : void
		{
			var noMultiselect:Boolean;
			var type:String;
			switch (true) {
				case command is ColorUpdate:
					var targetComponent = (command as ColorUpdate).targetComponent;
					if (targetComponent) {
						// TODO: look into adding support for separate eye colors
						if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(this._currentType) == -1) {
							return;
						} 
						var selected:CCBodyComponentModel = this.multiComponentChooser.selectedBodyComponent;
						if (targetComponent != selected.id) {
							return;
						}
					}
					type = (command as ColorUpdate).type;
					var value:uint = (command as ColorUpdate).value;
					this.propertyBox.setColor(type, value);
					this.thumbChooser.refreshChar(this._char);
					break;
				case command is ComponentAdd:
					var bodyComponent:CCBodyComponentModel = (command as ComponentAdd).bodyComponent;
					type = bodyComponent.type;
					if (this._currentType != type) {
						return;
					}
					noMultiselect = updateThumbChooserCaret(type);
					if (!noMultiselect) {
						var index:int = (command as ComponentAdd).index;
						this.multiComponentChooser.addComponent(bodyComponent, index);
					}
					if (!this.propertyBox.isReady) {
						this.propertyBox.init(this._theme, this._char, this._currentType, this.selected);
					}
					break;
				case command is ComponentRemove:
					var id:String = (command as ComponentRemove).id;
					type = (command as ComponentRemove).type;
					if (this._currentType != type) {
						return;
					}
					noMultiselect = updateThumbChooserCaret(type);
					if (!noMultiselect) {
						this.multiComponentChooser.removeComponent(id);
					}
					this.propertyBox.reset();
					break;
			}
		}

		/**
		 * called when a skin part is added
		 * @param partName part name
		 * @param instance part instance
		 */
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			switch (instance) {
				case this.propertyBox:
					this.propertyBox.addEventListener(CcColorPickerEvent.COLOR_CHOSEN, propertyBox_colorChosen);
					this.propertyBox.addEventListener(PositionInspectorEvent.LOCATION_UPDATE, propertyBox_locationUpdate);
					break;
				case this.thumbChooser:
					this.thumbChooser.addEventListener(ThumbChooserEvent.NONE_THUMB_CHOSEN, thumbChooser_thumbChosen);
					this.thumbChooser.addEventListener(ThumbChooserEvent.THUMB_CHOSEN, thumbChooser_thumbChosen);
					break;
				case this.typeChooser:
					this.typeChooser.addEventListener(TypeChooserEvent.SELECT, typeChooser_select);
					break;
			}
		}

		/**
		 * returns false if multiselect is supported, true if it isn't and the caret was updated
		 */
		private function updateThumbChooserCaret(type:String) : Boolean
		{
			var noMultiselect:Boolean = CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(type) == -1;
			if (noMultiselect) {
				var isOptional:Boolean = CcLibConstant.OPTIONAL_COMPONENTS.containsKey(type);
				this.thumbChooser.callLater(
					this.thumbChooser.ensureIndexIsVisible,
					[this._char, isOptional]
				);
			}
			return noMultiselect;
		}

		/**
		 * creates a ComponentAdd command
		 */
		private function applyComponentAdd(component:CCComponentModel) : void
		{
			var newBC:CCBodyComponentModel = new CCBodyComponentModel();
			newBC.theme_id = this._char.themeId;
			newBC.component_id = component.id;
			newBC.type = component.type;
			newBC.initDefaultValues();
			newBC.split = component.split;

			var inverseCmd:IHistoryCommand;
			if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(component.type) > -1) {
				newBC.id = "ID" + Math.round(Math.random() * 10000);
				this.multiComponentChooser.addComponent(newBC);
			} else {
				var oldBC:CCBodyComponentModel = this._char.components[component.type];
				if (oldBC) {
					newBC.x = oldBC.x;
					newBC.y = oldBC.y;
					newBC.xscale = oldBC.xscale;
					newBC.yscale = oldBC.yscale;
					newBC.offset = oldBC.offset;
					newBC.rotation = oldBC.rotation;
					inverseCmd = new ComponentAdd();
					(inverseCmd as ComponentAdd).bodyComponent = oldBC;
				}
			}
			if (!inverseCmd) {
				inverseCmd = new ComponentRemove();
				(inverseCmd as ComponentRemove).type = newBC.type;
				(inverseCmd as ComponentRemove).id = newBC.id;
			}
			if (!this.propertyBox.isReady) {
				this.propertyBox.init(this._theme, this._char, this._currentType, this.selected);
			}
			var command:ComponentAdd = new ComponentAdd();
			command.bodyComponent = newBC;
			HistoryManager.instance.push(command, inverseCmd);
		}

		/**
		 * creates a LibraryAdd command
		 */
		private function applyLibraryAdd(library:CCLibraryModel) : void
		{
			var command:LibraryAdd = new LibraryAdd();
			command.type = library.type;
			var inverseCmd:IHistoryCommand;
			var oldLib:String = this._char.libraries[library.type];
			if (oldLib) {
				inverseCmd = new LibraryAdd();
				(inverseCmd as LibraryAdd).type = library.type; 
				(inverseCmd as LibraryAdd).id = oldLib;
			} else {
				inverseCmd = new LibraryRemove();
				(inverseCmd as LibraryRemove).type = library.type;
			}
			HistoryManager.instance.push(command, inverseCmd);
		}

		/**
		 * creates a CharacterRemove or LibraryRemove command when the null thumb is selected
		 */
		private function applyRemoveCmd(type:String) : void
		{
			var command:IHistoryCommand;
			var inverseCmd:IHistoryCommand;
			if (CcLibConstant.ALL_LIBRARY_TYPES.indexOf(type) > -1) {
				command = new LibraryRemove();
				(command as LibraryRemove).type = type;
				inverseCmd = new LibraryAdd();
				(inverseCmd as LibraryAdd).type = type;
				(inverseCmd as LibraryAdd).id = this._char.libraries[type];
			} else {
				command = new ComponentRemove();
				(command as ComponentRemove).type = type;
				inverseCmd = new ComponentAdd();
				(inverseCmd as ComponentAdd).bodyComponent = this._char.components[type];
			}
			this.propertyBox.reset();
			HistoryManager.instance.push(command, inverseCmd);
		}

		/**
		 * creates a ColorUpdate command.
		 */
		private function applyColorUpdateCmd(type:String, value:uint, commit:Boolean = true) {
			var command:ColorUpdate = new ColorUpdate();
			command.type = type;
			command.targetComponent = this.selected.id;
			command.value = value;
			if (commit) {
				var inverseCmd:ColorUpdate = new ColorUpdate();
				inverseCmd.type = command.type;
				inverseCmd.targetComponent = command.targetComponent;
				var currentColor:CCColor = this._char.colors[type + (command.targetComponent || "")];
				if (currentColor) {
					inverseCmd.value = currentColor.dest;
				} else {
					inverseCmd.value = 0x1000000;
				}
				HistoryManager.instance.push(command, inverseCmd);
				this.thumbChooser.refreshChar(this._char);
			} else {
				command.temp = true;
				HistoryManager.instance.sendOff(command);
			}
		}

		/**
		 * creates a ColorUpdate command.
		 */
		private function applyLocationUpdateCmd(component:CCBodyComponentModel, commit:Boolean = true) {
			var command:LocationUpdate = new LocationUpdate();
			command.bodyComponent = component;
			if (commit) {
				var oldBC:CCBodyComponentModel;
				if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(component.type) > -1) {
					var components:Vector.<CCBodyComponentModel> = this._char.components[component.type];
					for each (var bodyComponent:CCBodyComponentModel in components) {
						if (bodyComponent.id == component.id) {
							oldBC = bodyComponent;
						}
					}
				} else {
					oldBC = this._char.components[component.type];
				}
				var inverseCmd:LocationUpdate = new LocationUpdate();
				inverseCmd.bodyComponent = oldBC;
				HistoryManager.instance.push(command, inverseCmd);
			} else {
				command.temp = true;
				HistoryManager.instance.sendOff(command);
			}
		}

		/**
		 * called when a type is chosen in the TypeChooser,
		 * switches the component type being displayed
		 */
		private function typeChooser_select(event:TypeChooserEvent) : void
		{
			var newType:String = event.componentType;
			this._currentType = newType;
			var supportsMultiselect:Boolean = CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(newType) > -1;
			this.thumbChooser.init(this._theme, this._char, this._currentType, supportsMultiselect);
			this.propertyBox.reset();
			if (supportsMultiselect) {
				this.multiComponentChooser.visible = true;
				this.multiComponentChooser.init(this._theme, this._char, this._currentType);
				this.multiComponentChooser.addEventListener(MultiComponentChooserEvent.DELETE, this.multiComponentChooser_delete);
				this.multiComponentChooser.addEventListener(MultiComponentChooserEvent.SELECT, this.multiComponentChooser_select);
			} else {
				var selected:* = this.selected;
				if (selected || _currentType == CcLibConstant.COMPONENT_TYPE_FACESHAPE) {
					this.propertyBox.init(this._theme, this._char, this._currentType, selected);
				}
				this.multiComponentChooser.visible = false;
				this.multiComponentChooser.removeEventListener(MultiComponentChooserEvent.DELETE, this.multiComponentChooser_delete);
				this.multiComponentChooser.removeEventListener(MultiComponentChooserEvent.SELECT, this.multiComponentChooser_select);
			}
		}

		/**
		 * called when a component is selected from the ThumbChooser
		 */
		private function thumbChooser_thumbChosen(event:ThumbChooserEvent) : void
		{
			var thumb:* = event.componentThumb;
			if (thumb) {
				if (event.componentThumb is CCComponentModel) {
					this.applyComponentAdd(thumb)
				} else {
					this.applyLibraryAdd(thumb);
				}
			} else {
				this.applyRemoveCmd(event.noneComponentThumbType);
			}
		}

		/**
		 * called when a body component is deleted, creates new ComponentRemove command
		 */
		private function multiComponentChooser_delete(event:MultiComponentChooserEvent) : void
		{
			var bodyComponent:CCBodyComponentModel = event.bodyComponent;
			var type:String = bodyComponent.type;
			var index:int = this._char.components[type].indexOf(bodyComponent);
			var command:ComponentRemove = new ComponentRemove();
			command.type = type;
			command.id = bodyComponent.id;
			var inverseCmd:ComponentAdd = new ComponentAdd();
			inverseCmd.bodyComponent = bodyComponent;
			inverseCmd.index = index;
			HistoryManager.instance.push(command, inverseCmd);
			this.propertyBox.reset();
		}

		private function multiComponentChooser_select(event:MultiComponentChooserEvent) : void
		{
			this.propertyBox.reset();
			this.propertyBox.init(this._theme, this._char, this._currentType, event.bodyComponent);
		}

		private function propertyBox_colorChosen(event:CcColorPickerEvent) : void
		{
			this.applyColorUpdateCmd(event.color.type, event.colorValue, event.undoable);
		}

		private function propertyBox_locationUpdate(event:PositionInspectorEvent) : void
		{
			this.applyLocationUpdateCmd(event.bodyComponent, event.undoable);
		}
	}
}
