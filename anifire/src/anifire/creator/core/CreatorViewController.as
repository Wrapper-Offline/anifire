
package anifire.creator.core
{
	import anifire.creator.events.CcColorPickerEvent;
	import anifire.creator.events.CcScaleChosenEvent;
	import anifire.creator.events.PositionInspectorEvent;
	import anifire.creator.events.CcThumbScaleEvent;
	import anifire.creator.interfaces.ICharacterCreator;
	import anifire.creator.config.GoAnimate;
	import anifire.models.creator.CCBodyModel;
	import anifire.models.creator.CCThemeModel;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import anifire.models.creator.CCComponentModel;
	import anifire.models.creator.CCBodyComponentModel;
	import anifire.constant.CcLibConstant;
	import anifire.models.creator.CCColor;
	import anifire.creator.managers.HistoryManager;
	import anifire.creator.events.HistoryManagerEvent;
	import anifire.creator.commands.ComponentAdd;
	import anifire.creator.commands.IHistoryCommand;
	import anifire.creator.commands.ComponentRemove;
	import anifire.creator.commands.LibraryAdd;
	import anifire.creator.commands.LibraryRemove;
	import anifire.creator.commands.ColorUpdate;
	import anifire.creator.commands.LocationUpdate;
	import flash.external.ExternalInterface;
	
	/**
	 * this class manages the character body and preview. it achieves this
	 * by handling every new command event from the historymanager and
	 * updating accordingly.
	 */
	public class CreatorViewController extends EventDispatcher
	{
		private var _currentTheme:CCThemeModel;
		private var _commands:Array;
		private var _currentCommandIndex:Number = -1;
		private var _userLevel:int;
		private var _ccCharCopyForReset:CCBodyModel;
		private var _currentComponentType:String;
		private var isNewCharInsteadOfExistingChar:Boolean;
		private var _cfg:GoAnimate;

		private var _char:CCBodyModel;
		private var _parent:ICharacterCreator;
		private var _theme:CCThemeModel;

		public function CreatorViewController(parent:ICharacterCreator)
		{
			super();
			this._parent = parent;
			this.addEventListeners();
		}

		private function get char() : CCBodyModel
		{
			return this._char;
		}

		private function get parent() : ICharacterCreator
		{
			return this._parent;
		}

		private function get theme() : CCThemeModel
		{
			return this._theme;
		}

		private function addEventListeners() : void {
			HistoryManager.instance.addEventListener(HistoryManagerEvent.UPDATE, this.historyManager_update)
		}

		/**
		 * called when the position in the history manager changes
		 */
		private function historyManager_update(event:HistoryManagerEvent) : void
		{
			var command:IHistoryCommand = event.command;
			var bodyComponent:CCBodyComponentModel;
			var type:String;
			var id:String;
			switch (true) {
				case command is ColorUpdate:
					this.updateColor(command as ColorUpdate);
					break;
				case command is ComponentAdd:
					bodyComponent = (command as ComponentAdd).bodyComponent;
					var index:int = (command as ComponentAdd).index;
					this.addComponent(bodyComponent, index);
					break;
				case command is ComponentRemove:
					type = (command as ComponentRemove).type;
					id = (command as ComponentRemove).id;
					this.removeComponent(type, id);
					break;
				case command is LibraryAdd:
					type = (command as LibraryAdd).type;
					id = (command as LibraryAdd).id;
					this.addLibrary(type, id);
					break;
				case command is LibraryRemove:
					type = (command as LibraryRemove).type;
					this.removeLibrary(type);
					break;
				case command is LocationUpdate:
					this.updateLocation(command as LocationUpdate);
					break;
			}
			if (event.updateCaret) {
				this.parent.cv_componentPanel.updateCaret(command);
			}
		}

		private function updateColor(command:ColorUpdate) : void
		{
			var index:String = command.type + (command.targetComponent || "");
			if (command.value > 16777215) {
				delete this.char.colors[index];
				this.parent.cv_charPreview.removeColor(command.type);
				return;
			}
			var color:CCColor = new CCColor();
			color.type = command.type;
			var hasTarget:Boolean = Boolean(color.targetComponent = command.targetComponent);
			if (!hasTarget) {
				color.oc = (this.theme.colors[index] as CCColor).oc;
			}
			color.dest = command.value;
			this.parent.cv_charPreview.updateColor(color);
			if (!command.temp) {
				this.char.colors[index] = color;
			}
		}

		/**
		 * adds a component to the body model, updates preview
		 */
		private function addComponent(bodyComponent:CCBodyComponentModel, index:int) : void
		{
			var properties:Object = {
				x: bodyComponent.x,
				y: bodyComponent.y,
				xscale: bodyComponent.xscale,
				yscale: bodyComponent.yscale,
				offset: bodyComponent.offset,
				rotation: bodyComponent.rotation
			};
			this.char.addComponent(bodyComponent, index);
			if (index > -1) {
				var components:Vector.<CCBodyComponentModel> = this.char.components[bodyComponent.type];
				var i:int = components.length - 1;
				while (i >= index) {
					if (i == index) {
						this.parent.cv_charPreview.addComponent(bodyComponent, this.char.bodyShapeId, properties);
						break;
					}
					this.parent.cv_charPreview.removeComponent(components[i]);
					i--;
				}
				for (i++; i < components.length; i++) {
					properties = {
						x: bodyComponent.x,
						y: bodyComponent.y,
						xscale: bodyComponent.xscale,
						yscale: bodyComponent.yscale,
						offset: bodyComponent.offset,
						rotation: bodyComponent.rotation
					};
					this.parent.cv_charPreview.addComponent(components[i], this.char.bodyShapeId, properties);
				}
			} else {
				this.parent.cv_charPreview.addComponent(bodyComponent, this.char.bodyShapeId, properties);
			}
		}

		/**
		 * removes a component from the body model, updates preview
		 * @param type component type
		 * @param type component id, if multiple are allowed
		 */
		private function removeComponent(type:String, id:String = "") : void
		{
			if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(type) > -1) {
				var components:Vector.<CCBodyComponentModel> = this.char.components[type];
				var bodyComponent:CCBodyComponentModel;
				for (var i:int = 0; i < components.length; i++) {
					bodyComponent = components[i];
					if (bodyComponent.id != id) {
						continue;
					}
					components.splice(i, 1);
					this.parent.cv_charPreview.removeComponent(bodyComponent);
				}
			} else if (this.char.components[type]) {
				this.parent.cv_charPreview.removeComponent(this.char.components[type]);
				delete this.char.components[type];
			}
		}

		/**
		 * adds a library to the body model, updates preview
		 */
		private function addLibrary(type:String, id:String) : void
		{
			this.char.libraries[type] = id;
			this.parent.cv_charPreview.useLibrary(type, id, this.char.bodyShapeId);
		}

		/**
		 * removes a library from the body model, updates preview
		 */
		private function removeLibrary(type:String) : void
		{
			if (this.char.libraries[type]) {
				this.parent.cv_charPreview.removeLibrary(type, this.char.libraries[type]);
				delete this.char.libraries[type];
			}
		}

		private function updateLocation(command:LocationUpdate) : void
		{
			var component:CCBodyComponentModel = command.bodyComponent;
			this.parent.cv_charPreview.updateLocation(component);
			if (!command.temp) {
				if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(component.type) > -1) {
					var components:Vector.<CCBodyComponentModel> = this._char.components[component.type];
					for (var index:String in components) {
						var bodyComponent:CCBodyComponentModel = components[index];
						if (bodyComponent.id == component.id) {
							components[index] = component;
						}
					}
				} else {
					this._char.components[component.type] = component;
				}
			}
		}

		private function oldThumbChosen___________DELETEME() : void
		{
			var type:String;
			// IF LEGACY MODE
			for (var colorType:String in this.char.colors) {
				var themeColor:CCColor = this.theme.colors[colorType];
				if (themeColor.targetComponent == type) {
					delete this.char.colors[colorType];
					this.parent.cv_charPreview.removeColor(colorType);
				}
			}
		}

		/**
		 * prepares all components
		 */
		public function start(theme:CCThemeModel, char:CCBodyModel, copyMode:Boolean) : void
		{
			this._theme = theme;
			this._char = char;
			this.parent.cv_componentPanel.init(this.theme, this.char);
			this.parent.cv_charPreview.initByCcBody(this.char, this.theme);

			// this.isNewCharInsteadOfExistingChar = charCopyMode;
			// //this.editUi.eui_bodyShapeChooser.addEventListener(CcBodyShapeChooserEvent.BODY_SHAPE_CHOSEN, this.onUserChooseBodyShape);
			// this.ccCharCopyForReset = new CCBodyModel("");
			// this.ccCharCopyForReset.parse(this._ccChar.serialize());
			// this.addCommand(this.ccChar);
			// this.editUi.eui_componentTypeChooser.init(this.currentTheme, this.ccChar, false);
			// var order:Array = this.ccChar.version == 2 ?
			// 	CcLibConstant.COMPONENT_TYPE_CHOOSER_ORDERING_VER2 :
			// 	CcLibConstant.COMPONENT_TYPE_CHOOSER_ORDERING_VER1;
			// var startType:String = order[0];
			// this.switchComponentType(startType, true);
		}



		public function get configuration() : GoAnimate
		{
			return this._cfg;
		}
		
		public function set configuration(param1:GoAnimate) : void
		{
			this._cfg = param1;
		}
		
		private function get currentComponentType() : String
		{
			return this._currentComponentType;
		}
		
		private function set currentComponentType(param1:String) : void
		{
			this._currentComponentType = param1;
		}
		
		private function get ccCharCopyForReset() : CCBodyModel
		{
			return this._ccCharCopyForReset;
		}
		
		private function set ccCharCopyForReset(ccChar:CCBodyModel) : void
		{
			this._ccCharCopyForReset = ccChar;
		}
		
		
		
		private function get userLevel() : int
		{
			return this._userLevel;
		}

		private function addCommand(ccChar:CCBodyModel) : void
		{
			// var _loc2_:Array = this._commands.slice(0, this._currentCommandIndex);
			// _loc2_.push(ccChar.clone());
			// this._commands = _loc2_;
			// this._currentCommandIndex = this._commands.length;
			// this.editUi.eui_buttonBar.btnUndo.enabled = this._commands.length > 1 ? true : false;
			// this.editUi.eui_buttonBar.btnRedo.enabled = false;
			// TODO REPLACE THIS STUPID FUCKING SYSTEM WITH SOMETHING FASTER
		}
		
		public function copyCcChar(param1:CCBodyModel) : void
		{
			// this._ccChar = new CCBodyModel("");
			// this._ccChar.parse(param1.serialize());
		}

		/**
		 * Resets the character action. Dispatches the
		 * `LoadEmbedMovieEvent.COMPLETE_EVENT` event when completed.
		 */
		public function resetCCAction() : void
		{
			// this.editUi.eui_charPreview.addEventListener(LoadEmbedMovieEvent.COMPLETE_EVENT, this.onResetCCActionComplete);
			// this.editUi.eui_charPreview.initByCcBody(this.ccChar, this.currentTheme);
		}

		/**
		 * Called when the character action has been reset.
		 * Dispatches the `LoadEmbedMovieEvent.COMPLETE_EVENT` event.
		 * @param event `LoadEmbedMovieEvent.COMPLETE_EVENT`
		 */
		private function onResetCCActionComplete(event:Event) : void
		{
			// (event.target as IEventDispatcher).removeEventListener(event.type, this.onResetCCActionComplete);
			// this.dispatchEvent(event);
		}
		
		private function onUserClickScaleButton(param1:Event) : void
		{
			// this.initScalePanel();
			// this.editUi.eui_charScaleChooser.show();
		}
		
		private function initScalePanel() : void
		{
			// var _loc1_:Array = CcLibConstant.DEFAULT_HEADSCALES;
			// var _loc2_:Array = CcLibConstant.DEFAULT_BODYSCALES;
			// var _loc3_:Array = CcLibConstant.DEFAULT_HEADPOS;
			// this.editUi.eui_charScaleChooser.updateSliders(this.ccChar.bodyScale.x * 100,this.ccChar.headScale.x * 100);
			// this.editUi.eui_charScaleChooser.addEventListener(CcScaleChosenEvent.SCALE_CHOSEN,this.onUserSelectedScale);
		}
		
		private function onUserSelectedScale(param1:CcScaleChosenEvent) : void
		{
			// if(param1.head_scale)
			// {
			//    this.ccChar.headScale = new Point(param1.head_scale,param1.head_scale);
			//    this.editUi.eui_charPreview.setHeadScale(this.ccChar.headScale.x,this.ccChar.headScale.y);
			// }
			// if(param1.body_scale)
			// {
			//    this.ccChar.bodyScale = new Point(param1.body_scale,param1.body_scale);
			//    this.editUi.eui_charPreview.setBodyScale(this.ccChar.bodyScale.x,this.ccChar.bodyScale.y);
			// }
			// if(param1.head_pos)
			// {
			//    this.ccChar.headShift = new Point(param1.head_pos.x,param1.head_pos.y);
			//    this.editUi.eui_charPreview.resetHeadPos();
			//    this.editUi.eui_charPreview.setHeadPos(this.ccChar.headShift.x,this.ccChar.headShift.y);
			// }
			// if(param1.head_shift)
			// {
			//    this.editUi.eui_charPreview.setHeadPos(param1.head_shift.x,param1.head_shift.y);
			//    this.ccChar.headShift = this.editUi.eui_charPreview.getHeadPos();
			// }
			// this.editUi.eui_charPreview.reloadSkin();
		}
		
		public function resetCharacter() : void
		{
			// this._ccChar = new CCBodyModel("");
			// this._ccChar.parse(this.ccCharCopyForReset.serialize());
			// this.propagateNewCharToUi(this.ccChar);
			// this.refreshCurrentUi();
			//this.addCommand(this.ccChar);
		}
		
		// private function onUserOverDecoration(event:CcSelectedDecorationEvent) : void
		// {
		// 	// var ccComponent:CCBodyComponentModel = event.ccComponent;
		// 	// this.editUi.eui_charPreview.highlightComponent(ccComponent);
		// }
		
		// private function onUserOutDecoration(event:CcSelectedDecorationEvent) : void
		// {
		// 	// var ccComponent:CCBodyComponentModel = event.ccComponent;
		// 	// this.editUi.eui_charPreview.removeHighlightComponent(ccComponent);
		// }
		
		// private function onUserChooseDecoration(event:CcSelectedDecorationEvent) : void
		// {
		// 	// var ccComponent:CCBodyComponentModel = event.ccComponent;
		// 	// this.editUi.eui_colorPicker.destroy();
		// 	// this.editUi.eui_thumbPositionInspector.destroy();
		// 	// this.editUi.eui_colorPicker.addComponentType(ccComponent.type,this.currentTheme,this.ccChar);
		// 	// this.editUi.eui_colorPicker.addComponentThumb(ccComponent,ccComponent.componentThumb,this.currentTheme,this.ccChar);
		// 	// this.editUi.eui_thumbPositionInspector.init(ccComponent,this.userLevel);
		// }
		
		// private function onUserDeleteDecoration(event:CcSelectedDecorationEvent) : void
		// {
		// 	// var ccComponent:CCBodyComponentModel = event.ccComponent;
		// 	// this.editUi.eui_colorPicker.destroy();
		// 	// this.editUi.eui_thumbPositionInspector.destroy();
		// 	// this.editUi.eui_charPreview.removeComponent(ccComponent);
		// 	// this.ccChar.removeUserChosenComponentById(ccComponent.id);
		// 	// this.addCommand(this.ccChar);
		// }
		
		private function onUserUpdateComponentProperty(param1:Event) : void
		{
			// this.addCommand(this.ccChar);
		}
		
		private function onUserClickUndoButton(param1:Event) : void
		{
			// var _loc5_:CcComponent = null;
			// var _loc2_:CcCharacter = this._commands[this._currentCommandIndex - 2];
			// this.copyCcChar(_loc2_.clone());
			// this.editUi.eui_charPreview.initByCcChar(this.ccChar,this.ccChar.thumbnailActionId);
			// this.editUi.eui_thumbPositionInspector.destroy();
			// var _loc3_:Number = this.ccChar.getUserChosenComponentSize();
			// var _loc4_:int = 0;
			// while(_loc4_ < _loc3_)
			// {
			//    if((_loc5_ = this.ccChar.getUserChosenComponentByIndex(_loc4_)).componentThumb.type == this.currentComponentType)
			//    {
			//       this.editUi.eui_thumbPositionInspector.init(_loc5_,this.userLevel);
			//    }
			//    _loc4_++;
			// }
			// if(CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(this.currentComponentType) > -1)
			// {
			//    this.editUi.eui_selectedDecoration.initByCcChar(this.ccChar);
			// }
			// --this._currentCommandIndex;
			// if(this._currentCommandIndex == 1)
			// {
			//    this.editUi.eui_buttonBar.btnUndo.enabled = false;
			// }
			// else
			// {
			//    this.editUi.eui_buttonBar.btnUndo.enabled = true;
			// }
			// this.editUi.eui_buttonBar.btnRedo.enabled = true;
			// this.refreshCurrentUi();
		}
		
		private function onUserClickRedoButton(param1:Event) : void
		{
			// var _loc5_:CcComponent = null;
			// var _loc2_:CcCharacter = this._commands[this._currentCommandIndex];
			// this.copyCcChar(_loc2_.clone());
			// this.editUi.eui_charPreview.initByCcChar(this.ccChar,this.ccChar.thumbnailActionId);
			// this.editUi.eui_thumbPositionInspector.destroy();
			// var _loc3_:Number = this.ccChar.getUserChosenComponentSize();
			// var _loc4_:int = 0;
			// while(_loc4_ < _loc3_)
			// {
			//    if((_loc5_ = this.ccChar.getUserChosenComponentByIndex(_loc4_)).componentThumb.type == this.currentComponentType)
			//    {
			//       this.editUi.eui_thumbPositionInspector.init(_loc5_,this.userLevel);
			//    }
			//    _loc4_++;
			// }
			// if(CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(this.currentComponentType) > -1)
			// {
			//    this.editUi.eui_selectedDecoration.initByCcChar(this.ccChar);
			// }
			// ++this._currentCommandIndex;
			// if(this._currentCommandIndex == this._commands.length)
			// {
			//    this.editUi.eui_buttonBar.btnRedo.enabled = false;
			// }
			// else
			// {
			//    this.editUi.eui_buttonBar.btnRedo.enabled = true;
			// }
			// this.editUi.eui_buttonBar.btnUndo.enabled = true;
			// this.refreshCurrentUi();
		}
		
		private function onUserClickPreviewButton(param1:Event) : void
		{
			// this.dispatchEvent(new CcCoreEvent(CcCoreEvent.USER_WANT_TO_PREVIEW,this));
		}
		
		private function onUserClickSaveButton(param1:Event) : void
		{
			// this.dispatchEvent(new CcCoreEvent(CcCoreEvent.USER_WANT_TO_SAVE,this));
		}
		
		private function onUserClickRandomizeButton(param1:Event) : void
		{
			// var _loc4_:CcComponent = null;
			// this.ccChar.randomize(this.currentTheme,this.ccChar.bodyShape.bodyType);
			// this.editUi.eui_thumbPositionInspector.destroy();
			// var _loc2_:Number = this.ccChar.getUserChosenComponentSize();
			// var _loc3_:int = 0;
			// while(_loc3_ < _loc2_)
			// {
			//    if((_loc4_ = this.ccChar.getUserChosenComponentByIndex(_loc3_)).componentThumb.type == this.currentComponentType)
			//    {
			//       this.editUi.eui_thumbPositionInspector.init(_loc4_,this.userLevel);
			//    }
			//    _loc3_++;
			// }
			// this.propagateNewCharToUi(this.ccChar);
			// this.refreshCurrentUi();
			// this.addCommand(this.ccChar);
			// TODO: CREATE NEW SYSTEM FOR RANDOMIZING
		}
		
		// private function onUserChooseBodyShape(param1:CcBodyShapeChooserEvent) : void
		// {
		//    var _loc3_:XML = null;
		//    var _loc4_:CcCharacter = null;
		//    var _loc5_:UtilHashArray = null;
		//    var _loc2_:CcBodyShape = param1.bodyShapeChosen;
		//    if(_loc2_ != null)
		//    {
		//       if(CcLibConstant.LOAD_DEFAULT_ON_SWITCH_SHAPE)
		//       {
		//          _loc3_ = _loc2_.getDefaultCharXml();
		//          _loc4_ = new CcCharacter();
		//          (_loc5_ = new UtilHashArray()).push(this.currentTheme.id,this.currentTheme);
		//          _loc4_.deserialize(_loc3_,_loc5_);
		//          this.ccChar.cloneFromSourceToMe(_loc4_);
		//       }
		//       else
		//       {
		//          this.ccChar.transformBodyShape(_loc2_);
		//       }
		//       this.onUserChooseBodyShapeCommon();
		//    }
		// }
		
		// private function onUserChooseBodyShapeCommon() : void
		// {
		//    var _loc1_:UtilHashArray = null;
		//    if(this.isNewCharInsteadOfExistingChar)
		//    {
		//       _loc1_ = new UtilHashArray();
		//       _loc1_.push(this.currentTheme.id,this.currentTheme);
		//       this.ccCharCopyForReset = new CcCharacter();
		//       this.ccCharCopyForReset.deserialize(this.ccChar.bodyShape.getDefaultCharXml(),_loc1_);
		//    }
		//    this.propagateNewCharToUi(this.ccChar);
		//    this.addCommand(this.ccChar);
		//    this.editUi.eui_componentTypeChooser.init(this.currentTheme,this.ccChar,false);
		//    this.switchComponentType(this.ccChar.getComponentTypeOrdering()[0] as String,true);
		// }
		
		private function refreshCurrentUi() : void
		{
			// this.switchComponentType(this.currentComponentType, true);
		}
		
		private function switchComponentType(type:String, setInTypeChooser:Boolean) : void
		{
			// this.currentComponentType = type;
			// if (setInTypeChooser) {
			// 	this.editUi.eui_componentTypeChooser.switchToComponentType(type, false);
			// }
			// if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(type) > -1) {
			// 	this.editUi.eui_selectedDecoration.visible = true;
			// } else {
			// 	this.editUi.eui_selectedDecoration.visible = false;
			// }
			// var allowedTypes:Vector.<String> = new Vector.<String>();
			// if (type != CcLibConstant.COMPONENT_TYPE_BODYSHAPE) {
			// 	allowedTypes.push(type);
			// 	this.editUi.eui_componentThumbChooser.init(this.ccChar, this.currentTheme, type, CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(type) > -1 ? false : true);
			// 	this.editUi.eui_thumbPositionInspector.destroy();
			// }
			// this.editUi.eui_colorPicker.destroy();

			// for each (var allowType:String in allowedTypes) {
			// 	if (CcLibConstant.ALL_COMPONENT_TYPES.indexOf(allowType) >= 0) {
			// 		if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(allowType) >= 0) {
			// 			return;
			// 		}
			// 		this.editUi.eui_colorPicker.addComponentType(allowType, this.currentTheme, this.ccChar);
			// 		//this.editUi.eui_thumbPositionInspector.init(component, this.userLevel);
			// 	} else if (CcLibConstant.ALL_LIBRARY_TYPES.indexOf(allowType) >= 0) {
			// 		this.editUi.eui_colorPicker.addLibraryType(allowType, this.currentTheme, this.ccChar);
			// 	}
			// }
		}
		
		private function resetPanels() : void
		{
			// this.editUi.eui_charScaleChooser.close();
			// this.editUi.eui_thumbPositionInspector.close();
		}
		
		private function onUserEditScale(param1:CcThumbScaleEvent) : void
		{
			// var _loc2_:Number = param1.scale / 100;
			// if(param1.part == CcLibConstant.COMPONENT_CAT_HEAD)
			// {
			//    this.ccChar.headScale = new Point(_loc2_,_loc2_);
			//    this.editUi.eui_charPreview.setHeadScale(_loc2_,_loc2_);
			// }
			// else if(param1.part == CcLibConstant.COMPONENT_CAT_BODY)
			// {
			//    this.ccChar.bodyScale = new Point(_loc2_,_loc2_);
			//    this.editUi.eui_charPreview.setBodyScale(_loc2_,_loc2_);
			// }
		}
		
		// private function onUserChooseCloth(param1:CcComponentThumbChooserEvent) : void
		// {
			// var _loc3_:CcComponent = null;
			// this.resetPanels();
			// var _loc2_:CcComponent = new CcComponent();
			// _loc2_.componentThumb = param1.componentThumb;
			// this.onThumbClickCommon(_loc2_);
			// this.editUi.eui_colorPicker.destroy();
			// _loc3_ = this.ccChar.getUserChosenComponentByComponentType(CcLibConstant.COMPONENT_TYPE_UPPER_BODY)[0] as CcComponent;
			// this.editUi.eui_colorPicker.addComponentType(CcLibConstant.COMPONENT_TYPE_UPPER_BODY,this.currentTheme,this.ccChar);
			// this.editUi.eui_colorPicker.addComponentThumb(_loc3_,_loc3_.componentThumb,this.currentTheme,this.ccChar);
			// _loc3_ = this.ccChar.getUserChosenComponentByComponentType(CcLibConstant.COMPONENT_TYPE_LOWER_BODY)[0] as CcComponent;
			// this.editUi.eui_colorPicker.addComponentType(CcLibConstant.COMPONENT_TYPE_LOWER_BODY,this.currentTheme,this.ccChar);
			// this.editUi.eui_colorPicker.addComponentThumb(_loc3_,_loc3_.componentThumb,this.currentTheme,this.ccChar);
		// }
		
		private function convertComponentToLibrary(param1:*) : *
		{
			// var _loc2_:CcLibrary = new CcLibrary();
			// _loc2_.type = param1.componentThumb.type;
			// _loc2_.theme_id = param1.componentThumb.themeId;
			// _loc2_.component_id = param1.componentThumb.componentId;
			// _loc2_.sharingPoint = param1.componentThumb.sharingPoint;
			// return _loc2_;
		}
		
		private function convertLibraryToComponent(param1:*) : *
		{
			// var _loc2_:CcComponent = new CcComponent();
			// var _loc3_:CcComponentThumb = new CcComponentThumb();
			// _loc2_.componentThumb = this.currentTheme.getComponentThumbByType(param1.type).getValueByKey(param1.type + "_" + param1.component_id);
			// return _loc2_;
		}
		
		private function onThumbClickCommon(param1:CCComponentModel, param2:Boolean = false) : void
		{
			// var _loc3_:Array = null;
			// var _loc4_:CcComponent = null;
			// var _loc5_:Array = null;
			// var _loc6_:UtilHashArray = null;
			// var _loc7_:String = null;
			// var _loc8_:CcComponentThumb = null;
			// var _loc9_:CcComponent = null;
			// var _loc10_:CcLibrary = null;
			// param1.xscale = param1.yscale = CcCharacter.getComponentScaling(this.ccChar.bodyShape.bodyType);
			// if(CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(param1.componentThumb.type) == -1)
			// {
			//    _loc3_ = this.ccChar.getUserChosenComponentByComponentType(param1.componentThumb.type);
			//    if(_loc3_.length > 0)
			//    {
			//       _loc4_ = _loc3_[0] as CcComponent;
			//       param1.x = _loc4_.x;
			//       param1.y = _loc4_.y;
			//       param1.xscale = _loc4_.xscale;
			//       param1.yscale = _loc4_.yscale;
			//       param1.offset = _loc4_.offset;
			//       param1.rotation = _loc4_.rotation;
			//    }
			// }
			// if(CcLibConstant.IS_TAKE_ORIGINAL_COLOR(param1.componentThumb.type))
			// {
			//    _loc5_ = this.editUi.eui_charPreview.removeColorOfThumb(param1,this.ccChar);
			//    //this.editUi.eui_facePreviewer.removeColorByRefs(_loc5_);
			// }
			// if(param1.componentThumb.libType != "")
			// {
			//    if(_loc6_ = this.ccChar.bodyShape.getComponentThumbByType(param1.componentThumb.libType))
			//    {
			//       _loc7_ = param1.componentThumb.libType + "_" + param1.componentThumb.componentId;
			//       if(_loc8_ = _loc6_.getValueByKey(_loc7_))
			//       {
			//          (_loc9_ = new CcComponent()).componentThumb = _loc8_;
			//          this.onThumbClickCommon(_loc9_,true);
			//       }
			//       else
			//       {
			//          this.ccChar.removeUserChosenComponentByType(param1.componentThumb.libType);
			//          this.editUi.eui_charPreview.initByCcChar(this.ccChar,this.ccChar.bodyShape.thumbnailActionId);
			//       }
			//    }
			// }
			// if(param1.componentThumb.apply_template_id)
			// {
			//    this.applyTemplate(param1.componentThumb.apply_template_id,param1.componentThumb.type);
			// }
			// if(CcLibConstant.ALL_LIBRARY_TYPES.indexOf(param1.componentThumb.type) > -1)
			// {
			//    _loc10_ = this.convertComponentToLibrary(param1);
			//    this.ccChar.addUserChosenLibrary(_loc10_);
			//    this.editUi.eui_charPreview.switchLibrary(param1,this.ccChar);
			// }
			// else
			// {
			//    this.ccChar.addUserChosenComponent(param1);
			//    this.editUi.eui_charPreview.switchComponent(param1,this.ccChar,this.ccChar.bodyShape.thumbnailActionId);
			// }
			// this.editUi.eui_thumbPositionInspector.init(param1,this.userLevel);
			// if(CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(param1.componentThumb.type) > -1)
			// {
			//    this.editUi.eui_selectedDecoration.addComponent(param1);
			// }
			// if(!param2)
			// {
			//    this.addCommand(this.ccChar);
			// }
		}
		
		private function applyTemplate(param1:String, param2:String) : void
		{
			// var _loc7_:int = 0;
			// var _loc8_:CcColor = null;
			// var _loc9_:CcComponent = null;
			// var _loc10_:CcLibrary = null;
			// var _loc3_:CcTemplate = this.currentTheme.getTemplateById(param1);
			// var _loc4_:int = _loc3_.getUserChosenColorNum();
			// var _loc5_:int = _loc3_.getUserChosenComponentSize();
			// var _loc6_:int = _loc3_.getUserChosenLibraryNum();
			// _loc7_ = 0;
			// while(_loc7_ < _loc4_)
			// {
			//    _loc8_ = _loc3_.getUserChosenColorByIndex(_loc7_);
			//    this.editUi.eui_charPreview.updateColor(_loc8_);
			//    this.ccChar.addUserChosenColor(_loc8_);
			//    _loc7_++;
			// }
			// _loc7_ = 0;
			// while(_loc7_ < _loc5_)
			// {
			//    if((_loc9_ = _loc3_.getUserChosenComponentByIndex(_loc7_)).componentThumb.type != param2)
			//    {
			//       this.onThumbClickCommon(_loc9_);
			//    }
			//    _loc7_++;
			// }
			// _loc7_ = 0;
			// while(_loc7_ < _loc6_)
			// {
			//    if((_loc10_ = _loc3_.getUserChosenLibraryByIndex(_loc7_)).type != param2)
			//    {
			//       this.onThumbClickCommon(this.convertLibraryToComponent(_loc10_));
			//    }
			//    _loc7_++;
			// }
			// TODO RESTORE THE ENTIRE TEMPLATE FEATURE
		}
		
		public function updateTopButtonOnRole() : void
		{
			
		}

		/**
		 * Takes a snapshot of the character being edited.
		 * @param fullBody Whether or not to capture the
		 * entire character.
		 */
		public function saveSnapShot(fullBody:Boolean = false) : ByteArray
		{
			// var image:BitmapData;
			// if (fullBody)
			// {
			// 	image = this.editUi.eui_charPreview.capCharAsBitmap();
			// }
			// else
			// {
			// 	image = this.editUi.eui_charPreview.capFaceAsBitmap();
			// }
			// var encoder:PNGEncoder = new PNGEncoder();
			// return encoder.encode(image);
			return new ByteArray();
		}
	}
}
