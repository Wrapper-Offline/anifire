
package anifire.creator.core
{
	import anifire.constant.CcLibConstant;
	import anifire.creator.events.CcBodyShapeChooserEvent;
	import anifire.creator.events.CcButtonBarEvent;
	import anifire.creator.events.CcColorPickerEvent;
	import anifire.creator.events.CcComponentThumbChooserEvent;
	import anifire.creator.events.CcComponentTypeChooserEvent;
	import anifire.creator.events.CcCoreEvent;
	import anifire.creator.events.CcPreMadeCharChooserEvent;
	import anifire.creator.events.CcScaleChosenEvent;
	import anifire.creator.events.CcSelectedDecorationEvent;
	import anifire.creator.events.CcThumbPropertyEvent;
	import anifire.creator.events.CcThumbScaleEvent;
	import anifire.creator.interfaces.ICcEditUiContainer;
	import anifire.creator.config.GoAnimate;
	import anifire.models.creator.CCBodyModel;
	import anifire.models.creator.CCBodyShapeModel;
	import anifire.models.creator.CCThemeModel;
	import anifire.event.LoadEmbedMovieEvent;
	import anifire.util.UtilHashArray;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import mx.graphics.codec.PNGEncoder;
	import anifire.models.creator.CCComponentModel;
	import anifire.models.creator.CCBodyComponentModel;
	import anifire.models.creator.CCColor;
	
	public class CcEditUiController extends EventDispatcher
	{
		 
		
		private var _ccChar:CCBodyModel;
		
		private var _currentTheme:CCThemeModel;
		
		private var _commands:Array;
		
		private var _currentCommandIndex:Number = -1;
		
		private var _editUi:ICcEditUiContainer;
		
		private var _userLevel:int;
		
		private var _ccCharCopyForReset:CCBodyModel;
		
		private var _currentComponentType:String;
		
		private var isNewCharInsteadOfExistingChar:Boolean;
		
		private var _cfg:GoAnimate;
		
		public function CcEditUiController(param1:IEventDispatcher = null)
		{
			this._commands = new Array();
			super(param1);
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
		
		private function get editUi() : ICcEditUiContainer
		{
			return this._editUi;
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
		
		public function get ccChar() : CCBodyModel
		{
			return this._ccChar;
		}
		
		public function copyCcChar(param1:CCBodyModel) : void
		{
			this._ccChar = new CCBodyModel("");
			this._ccChar.parse(param1.serialize());
		}
		
		private function get currentTheme() : CCThemeModel
		{
			return this._currentTheme;
		}
		
		public function initUi(editUI:ICcEditUiContainer) : void
		{
			this._editUi = editUI;
		  // this.editUi.eui_buttonBar.btnRedo.enabled = this.editUi.eui_buttonBar.btnUndo.enabled = false;
			// this.editUi.eui_buttonBar.addEventListener(CcButtonBarEvent.UNDO_BUTTON_CLICK,this.onUserClickUndoButton);
			// this.editUi.eui_buttonBar.addEventListener(CcButtonBarEvent.REDO_BUTTON_CLICK,this.onUserClickRedoButton);
			// this.editUi.eui_buttonBar.addEventListener(CcButtonBarEvent.PREVIEW_BUTTON_CLICK,this.onUserClickPreviewButton);
			// this.editUi.eui_buttonBar.addEventListener(CcButtonBarEvent.SAVE_BUTTON_CLICK,this.onUserClickSaveButton);
			// this.editUi.eui_buttonBar.addEventListener(CcButtonBarEvent.RANDOMIZE_BUTTON_CLICK,this.onUserClickRandomizeButton);
			// this.editUi.eui_buttonBar.addEventListener(CcButtonBarEvent.SCALE_BUTTON_CLICK,this.onUserClickScaleButton);
			this.editUi.eui_componentTypeChooser.addEventListener(CcComponentTypeChooserEvent.COMPONENT_TYPE_CHOSEN, this.onUserChooseType);
			this.editUi.eui_colorPicker.addEventListener(CcColorPickerEvent.COLOR_CHOSEN, this.onUserChooseColor);
			this.editUi.eui_componentThumbChooser.addEventListener(CcComponentThumbChooserEvent.COMPONENT_THUMB_CHOSEN, this.onThumbClick);
			this.editUi.eui_componentThumbChooser.addEventListener(CcComponentThumbChooserEvent.NONE_COMPONENT_THUMB_CHOSEN, this.onNullThumbClick);
			// this.editUi.eui_clothesChooser.addEventListener(CcComponentThumbChooserEvent.COMPONENT_THUMB_CHOSEN,this.onUserChooseCloth);
			// this.editUi.eui_clothesChooser.addEventListener(CcThumbScaleEvent.CCTHUMB_SCALE_UPDATE,this.onUserEditScale);
			// this.editUi.eui_thumbPropertyInspector.addEventListener(CcThumbPropertyEvent.CCPROP_UP_BUTTON_CLICK,this.onUserEditComponentProperty);
			// this.editUi.eui_thumbPropertyInspector.addEventListener(CcThumbPropertyEvent.CCPROP_DOWN_BUTTON_CLICK,this.onUserEditComponentProperty);
			// this.editUi.eui_thumbPropertyInspector.addEventListener(CcThumbPropertyEvent.CCPROP_LEFT_BUTTON_CLICK,this.onUserEditComponentProperty);
			// this.editUi.eui_thumbPropertyInspector.addEventListener(CcThumbPropertyEvent.CCPROP_RIGHT_BUTTON_CLICK,this.onUserEditComponentProperty);
			// this.editUi.eui_thumbPropertyInspector.addEventListener(CcThumbPropertyEvent.CCPROP_SCALEUP_BUTTON_CLICK,this.onUserEditComponentProperty);
			// this.editUi.eui_thumbPropertyInspector.addEventListener(CcThumbPropertyEvent.CCPROP_SCALEDOWN_BUTTON_CLICK,this.onUserEditComponentProperty);
			// this.editUi.eui_thumbPropertyInspector.addEventListener(CcThumbPropertyEvent.CCPROP_SCALEXUP_BUTTON_CLICK,this.onUserEditComponentProperty);
			// this.editUi.eui_thumbPropertyInspector.addEventListener(CcThumbPropertyEvent.CCPROP_SCALEXDOWN_BUTTON_CLICK,this.onUserEditComponentProperty);
			// this.editUi.eui_thumbPropertyInspector.addEventListener(CcThumbPropertyEvent.CCPROP_SCALEYUP_BUTTON_CLICK,this.onUserEditComponentProperty);
			// this.editUi.eui_thumbPropertyInspector.addEventListener(CcThumbPropertyEvent.CCPROP_SCALEYDOWN_BUTTON_CLICK,this.onUserEditComponentProperty);
			// this.editUi.eui_thumbPropertyInspector.addEventListener(CcThumbPropertyEvent.CCPROP_ROTATEUP_BUTTON_CLICK,this.onUserEditComponentProperty);
			// this.editUi.eui_thumbPropertyInspector.addEventListener(CcThumbPropertyEvent.CCPROP_ROTATEDOWN_BUTTON_CLICK,this.onUserEditComponentProperty);
			// this.editUi.eui_thumbPropertyInspector.addEventListener(CcThumbPropertyEvent.CCPROP_OFFSETUP_BUTTON_CLICK,this.onUserEditComponentProperty);
			// this.editUi.eui_thumbPropertyInspector.addEventListener(CcThumbPropertyEvent.CCPROP_OFFSETDOWN_BUTTON_CLICK,this.onUserEditComponentProperty);
			// this.editUi.eui_thumbPropertyInspector.addEventListener(CcThumbPropertyEvent.CCPROP_LOCATION_UPDATE,this.onUserUpdateComponentProperty);
			// this.editUi.eui_selectedDecoration.addEventListener(CcSelectedDecorationEvent.DECORATION_CHOOSEN,this.onUserChooseDecoration);
			// this.editUi.eui_selectedDecoration.addEventListener(CcSelectedDecorationEvent.DECORATION_MOUSE_OVER,this.onUserOverDecoration);
			// this.editUi.eui_selectedDecoration.addEventListener(CcSelectedDecorationEvent.DECORATION_MOUSE_OUT,this.onUserOutDecoration);
			// this.editUi.eui_selectedDecoration.addEventListener(CcSelectedDecorationEvent.DECORATION_DELETED,this.onUserDeleteDecoration);
			this.editUi.eui_charPreviewer.charCanvasHeight = 280;
		}
		
		public function proceedToShow() : void
		{
			
		}

		/**
		 * Resets the character action. Dispatches the
		 * `LoadEmbedMovieEvent.COMPLETE_EVENT` event when completed.
		 */
		public function resetCCAction() : void
		{
			this.editUi.eui_charPreviewer.addEventListener(LoadEmbedMovieEvent.COMPLETE_EVENT, this.onResetCCActionComplete);
			this.editUi.eui_charPreviewer.initByCcBody(this.ccChar, this.currentTheme);
		}

		/**
		 * Called when the character action has been reset.
		 * Dispatches the `LoadEmbedMovieEvent.COMPLETE_EVENT` event.
		 * @param event `LoadEmbedMovieEvent.COMPLETE_EVENT`
		 */
		private function onResetCCActionComplete(event:Event) : void
		{
			(event.target as IEventDispatcher).removeEventListener(event.type, this.onResetCCActionComplete);
			this.dispatchEvent(event);
		}
		
		private function onUserClickScaleButton(param1:Event) : void
		{
			this.initScalePanel();
			this.editUi.eui_charScaleChooser.show();
		}
		
		private function initScalePanel() : void
		{
			var _loc1_:Array = CcLibConstant.DEFAULT_HEADSCALES;
			var _loc2_:Array = CcLibConstant.DEFAULT_BODYSCALES;
			var _loc3_:Array = CcLibConstant.DEFAULT_HEADPOS;
			this.editUi.eui_charScaleChooser.updateSliders(this.ccChar.bodyScale.x * 100,this.ccChar.headScale.x * 100);
			this.editUi.eui_charScaleChooser.addEventListener(CcScaleChosenEvent.SCALE_CHOSEN,this.onUserSelectedScale);
		}
		
		private function onUserSelectedScale(param1:CcScaleChosenEvent) : void
		{
			// if(param1.head_scale)
			// {
			//    this.ccChar.headScale = new Point(param1.head_scale,param1.head_scale);
			//    this.editUi.eui_charPreviewer.setHeadScale(this.ccChar.headScale.x,this.ccChar.headScale.y);
			// }
			// if(param1.body_scale)
			// {
			//    this.ccChar.bodyScale = new Point(param1.body_scale,param1.body_scale);
			//    this.editUi.eui_charPreviewer.setBodyScale(this.ccChar.bodyScale.x,this.ccChar.bodyScale.y);
			// }
			// if(param1.head_pos)
			// {
			//    this.ccChar.headShift = new Point(param1.head_pos.x,param1.head_pos.y);
			//    this.editUi.eui_charPreviewer.resetHeadPos();
			//    this.editUi.eui_charPreviewer.setHeadPos(this.ccChar.headShift.x,this.ccChar.headShift.y);
			// }
			// if(param1.head_shift)
			// {
			//    this.editUi.eui_charPreviewer.setHeadPos(param1.head_shift.x,param1.head_shift.y);
			//    this.ccChar.headShift = this.editUi.eui_charPreviewer.getHeadPos();
			// }
			// this.editUi.eui_charPreviewer.reloadSkin();
		}
		
		public function resetCharacter() : void
		{
			this._ccChar = new CCBodyModel("");
			this._ccChar.parse(this.ccCharCopyForReset.serialize());
			this.propagateNewCharToUi(this.ccChar);
			this.refreshCurrentUi();
			//this.addCommand(this.ccChar);
		}
		
		private function onUserOverDecoration(event:CcSelectedDecorationEvent) : void
		{
			var ccComponent:CCBodyComponentModel = event.ccComponent;
			this.editUi.eui_charPreviewer.highlightComponent(ccComponent);
		}
		
		private function onUserOutDecoration(event:CcSelectedDecorationEvent) : void
		{
			var ccComponent:CCBodyComponentModel = event.ccComponent;
			this.editUi.eui_charPreviewer.removeHighlightComponent(ccComponent);
		}
		
		private function onUserChooseDecoration(event:CcSelectedDecorationEvent) : void
		{
			// var ccComponent:CCBodyComponentModel = event.ccComponent;
			// this.editUi.eui_colorPicker.destroy();
			// this.editUi.eui_thumbPropertyInspector.destroy();
			// this.editUi.eui_colorPicker.addComponentType(ccComponent.type,this.currentTheme,this.ccChar);
			// this.editUi.eui_colorPicker.addComponentThumb(ccComponent,ccComponent.componentThumb,this.currentTheme,this.ccChar);
			// this.editUi.eui_thumbPropertyInspector.init(ccComponent,this.userLevel);
		}
		
		private function onUserDeleteDecoration(event:CcSelectedDecorationEvent) : void
		{
			// var ccComponent:CCBodyComponentModel = event.ccComponent;
			// this.editUi.eui_colorPicker.destroy();
			// this.editUi.eui_thumbPropertyInspector.destroy();
			// this.editUi.eui_charPreviewer.removeComponent(ccComponent);
			// this.ccChar.removeUserChosenComponentById(ccComponent.id);
			// this.addCommand(this.ccChar);
		}
		
		private function onUserEditComponentProperty(param1:CcThumbPropertyEvent) : void
		{
			switch(param1.type)
			{
				case CcThumbPropertyEvent.CCPROP_UP_BUTTON_CLICK:
					--param1.component.y;
					break;
				case CcThumbPropertyEvent.CCPROP_DOWN_BUTTON_CLICK:
					++param1.component.y;
					break;
				case CcThumbPropertyEvent.CCPROP_LEFT_BUTTON_CLICK:
					++param1.component.x;
					break;
				case CcThumbPropertyEvent.CCPROP_RIGHT_BUTTON_CLICK:
					--param1.component.x;
					break;
				case CcThumbPropertyEvent.CCPROP_SCALEUP_BUTTON_CLICK:
					param1.component.xscale += 0.01;
					param1.component.yscale += 0.01;
					break;
				case CcThumbPropertyEvent.CCPROP_SCALEDOWN_BUTTON_CLICK:
					param1.component.xscale -= 0.01;
					param1.component.yscale -= 0.01;
					break;
				case CcThumbPropertyEvent.CCPROP_SCALEXUP_BUTTON_CLICK:
					param1.component.xscale += 0.01;
					break;
				case CcThumbPropertyEvent.CCPROP_SCALEXDOWN_BUTTON_CLICK:
					param1.component.xscale -= 0.01;
					break;
				case CcThumbPropertyEvent.CCPROP_SCALEYUP_BUTTON_CLICK:
					param1.component.yscale += 0.01;
					break;
				case CcThumbPropertyEvent.CCPROP_SCALEYDOWN_BUTTON_CLICK:
					param1.component.yscale -= 0.01;
					break;
				case CcThumbPropertyEvent.CCPROP_ROTATEUP_BUTTON_CLICK:
					param1.component.rotation += 1;
					break;
				case CcThumbPropertyEvent.CCPROP_ROTATEDOWN_BUTTON_CLICK:
					--param1.component.rotation;
					break;
				case CcThumbPropertyEvent.CCPROP_OFFSETUP_BUTTON_CLICK:
					++param1.component.offset;
					break;
				case CcThumbPropertyEvent.CCPROP_OFFSETDOWN_BUTTON_CLICK:
					--param1.component.offset;
			}
			this.editUi.eui_charPreviewer.updateLocation(param1.component);
		}
		
		private function onUserUpdateComponentProperty(param1:Event) : void
		{
			this.addCommand(this.ccChar);
		}
		
		private function onUserClickUndoButton(param1:Event) : void
		{
			// var _loc5_:CcComponent = null;
			// var _loc2_:CcCharacter = this._commands[this._currentCommandIndex - 2];
			// this.copyCcChar(_loc2_.clone());
			// this.editUi.eui_charPreviewer.initByCcChar(this.ccChar,this.ccChar.thumbnailActionId);
			// this.editUi.eui_thumbPropertyInspector.destroy();
			// var _loc3_:Number = this.ccChar.getUserChosenComponentSize();
			// var _loc4_:int = 0;
			// while(_loc4_ < _loc3_)
			// {
			//    if((_loc5_ = this.ccChar.getUserChosenComponentByIndex(_loc4_)).componentThumb.type == this.currentComponentType)
			//    {
			//       this.editUi.eui_thumbPropertyInspector.init(_loc5_,this.userLevel);
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
			// this.editUi.eui_charPreviewer.initByCcChar(this.ccChar,this.ccChar.thumbnailActionId);
			// this.editUi.eui_thumbPropertyInspector.destroy();
			// var _loc3_:Number = this.ccChar.getUserChosenComponentSize();
			// var _loc4_:int = 0;
			// while(_loc4_ < _loc3_)
			// {
			//    if((_loc5_ = this.ccChar.getUserChosenComponentByIndex(_loc4_)).componentThumb.type == this.currentComponentType)
			//    {
			//       this.editUi.eui_thumbPropertyInspector.init(_loc5_,this.userLevel);
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
			this.dispatchEvent(new CcCoreEvent(CcCoreEvent.USER_WANT_TO_PREVIEW,this));
		}
		
		private function onUserClickSaveButton(param1:Event) : void
		{
			this.dispatchEvent(new CcCoreEvent(CcCoreEvent.USER_WANT_TO_SAVE,this));
		}
		
		private function onUserClickRandomizeButton(param1:Event) : void
		{
			// var _loc4_:CcComponent = null;
			// this.ccChar.randomize(this.currentTheme,this.ccChar.bodyShape.bodyType);
			// this.editUi.eui_thumbPropertyInspector.destroy();
			// var _loc2_:Number = this.ccChar.getUserChosenComponentSize();
			// var _loc3_:int = 0;
			// while(_loc3_ < _loc2_)
			// {
			//    if((_loc4_ = this.ccChar.getUserChosenComponentByIndex(_loc3_)).componentThumb.type == this.currentComponentType)
			//    {
			//       this.editUi.eui_thumbPropertyInspector.init(_loc4_,this.userLevel);
			//    }
			//    _loc3_++;
			// }
			// this.propagateNewCharToUi(this.ccChar);
			// this.refreshCurrentUi();
			// this.addCommand(this.ccChar);
			// TODO: CREATE NEW SYSTEM FOR RANDOMIZING
		}
		
		private function propagateNewCharToUi(ccChar:CCBodyModel) : void
		{
			this.editUi.eui_charPreviewer.initByCcBody(ccChar, this.currentTheme);
			this.editUi.eui_selectedDecoration.initByCcChar(this.ccChar);
		}
		
		public function initTheme(themeModel:CCThemeModel) : void
		{
			this._currentTheme = themeModel;
		}
		
		public function start(bodyModel:CCBodyModel, charCopyMode:Boolean) : void
		{
			this.initChar(bodyModel);
			this.isNewCharInsteadOfExistingChar = charCopyMode;
			//this.editUi.eui_bodyShapeChooser.addEventListener(CcBodyShapeChooserEvent.BODY_SHAPE_CHOSEN, this.onUserChooseBodyShape);
			this.ccCharCopyForReset = new CCBodyModel("");
			this.ccCharCopyForReset.parse(this._ccChar.serialize());
			this.addCommand(this.ccChar);
			this.propagateNewCharToUi(this.ccChar);
			this.editUi.eui_componentTypeChooser.init(this.currentTheme, this.ccChar, false);
			var order:Array = this.ccChar.version == 2 ?
				CcLibConstant.COMPONENT_TYPE_CHOOSER_ORDERING_VER2 :
				CcLibConstant.COMPONENT_TYPE_CHOOSER_ORDERING_VER1;
			this.switchComponentType(order[0] as String, true);
		}
		
		private function initChar(bodyModel:CCBodyModel) : void
		{
			this._ccChar = bodyModel;
		}
		
		public function initMode(userLevel:int) : void
		{
			this._userLevel = userLevel;
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
			this.switchComponentType(this.currentComponentType,true);
		}
		
		private function switchComponentType(type:String, setInTypeChooser:Boolean) : void
		{
			this.currentComponentType = type;
			if (setInTypeChooser)
			{
				this.editUi.eui_componentTypeChooser.switchToComponentType(type, false);
			}
			if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(type) > -1)
			{
				this.editUi.eui_selectedDecoration.visible = true;
			}
			else
			{
				this.editUi.eui_selectedDecoration.visible = false;
			}
			var allowedTypes:Vector.<String> = new Vector.<String>();
			if (type != CcLibConstant.COMPONENT_TYPE_BODYSHAPE)
			{
				if (type == CcLibConstant.COMPONENT_GROUP_UPPER_LOWER)
				{
					allowedTypes.push(CcLibConstant.COMPONENT_TYPE_UPPER_BODY);
					allowedTypes.push(CcLibConstant.COMPONENT_TYPE_LOWER_BODY);
					//this.editUi.eui_clothesChooser.init(this.ccChar, this.currentTheme, type, false);
				}
				else
				{
					allowedTypes.push(type);
					this.editUi.eui_componentThumbChooser.init(this.ccChar, this.currentTheme, type, CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(type) > -1 ? false : true);
				}
				this.editUi.eui_thumbPropertyInspector.destroy();
			}
			this.editUi.eui_colorPicker.destroy();

			for each (var allowType:String in allowedTypes)
			{
				if (CcLibConstant.ALL_COMPONENT_TYPES.indexOf(allowType) >= 0)
				{
					if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(allowType) >= 0)
					{
						return;
					}
					this.editUi.eui_colorPicker.addComponentType(allowType, this.currentTheme, this.ccChar);
					//this.editUi.eui_thumbPropertyInspector.init(component, this.userLevel);
				}
				else if (CcLibConstant.ALL_LIBRARY_TYPES.indexOf(allowType) >= 0)
				{
					this.editUi.eui_colorPicker.addLibraryType(allowType, this.currentTheme, this.ccChar);
				}
			}
		}
		
		private function resetPanels() : void
		{
			this.editUi.eui_charScaleChooser.close();
			this.editUi.eui_thumbPropertyInspector.close();
		}
		
		private function onUserChooseType(event:CcComponentTypeChooserEvent) : void
		{
			this.resetPanels();
			this.switchComponentType(event.componentType, false);
		}
		
		private function onUserChooseColor(event:CcColorPickerEvent) : void
		{
			var color:CCColor = event.color;
			var newValue:uint = event.colorValue;
			this.editUi.eui_charPreviewer.updateColor(color, newValue);
			this.ccChar.colors[color.type].dest = newValue;
			// TODO ADD CHECK IF COLOR DOESN'T EXIST
			// if(param1.undoable)
			// {
			//    this.addCommand(this.ccChar);
			// }
		}
		
		private function onThumbClick(param1:CcComponentThumbChooserEvent) : void
		{
			// var _loc3_:CcComponent = null;
			// this.resetPanels();
			// var _loc2_:CcComponent = new CcComponent();
			// _loc2_.componentThumb = param1.componentThumb;
			// this.onThumbClickCommon(_loc2_);
			// this.editUi.eui_colorPicker.destroy();
			// if(_loc2_.componentThumb.type == CcLibConstant.COMPONENT_TYPE_FACESHAPE)
			// {
			//    _loc3_ = this.ccChar.getUserChosenComponentByComponentType(CcLibConstant.COMPONENT_TYPE_BODYSHAPE)[0] as CcComponent;
			//    this.editUi.eui_colorPicker.addComponentType(_loc3_.componentThumb.type,this.currentTheme,this.ccChar);
			//    this.editUi.eui_colorPicker.addComponentThumb(_loc3_,_loc3_.componentThumb,this.currentTheme,this.ccChar);
			// }
			// this.editUi.eui_colorPicker.addComponentType(_loc2_.componentThumb.type,this.currentTheme,this.ccChar);
			// this.editUi.eui_colorPicker.addComponentThumb(_loc2_,_loc2_.componentThumb,this.currentTheme,this.ccChar);
		}
		
		private function onUserEditScale(param1:CcThumbScaleEvent) : void
		{
			// var _loc2_:Number = param1.scale / 100;
			// if(param1.part == CcLibConstant.COMPONENT_CAT_HEAD)
			// {
			//    this.ccChar.headScale = new Point(_loc2_,_loc2_);
			//    this.editUi.eui_charPreviewer.setHeadScale(_loc2_,_loc2_);
			// }
			// else if(param1.part == CcLibConstant.COMPONENT_CAT_BODY)
			// {
			//    this.ccChar.bodyScale = new Point(_loc2_,_loc2_);
			//    this.editUi.eui_charPreviewer.setBodyScale(_loc2_,_loc2_);
			// }
		}
		
		private function onUserChooseCloth(param1:CcComponentThumbChooserEvent) : void
		{
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
		}
		
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
			//    _loc5_ = this.editUi.eui_charPreviewer.removeColorOfThumb(param1,this.ccChar);
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
			//          this.editUi.eui_charPreviewer.initByCcChar(this.ccChar,this.ccChar.bodyShape.thumbnailActionId);
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
			//    this.editUi.eui_charPreviewer.switchLibrary(param1,this.ccChar);
			// }
			// else
			// {
			//    this.ccChar.addUserChosenComponent(param1);
			//    this.editUi.eui_charPreviewer.switchComponent(param1,this.ccChar,this.ccChar.bodyShape.thumbnailActionId);
			// }
			// this.editUi.eui_thumbPropertyInspector.init(param1,this.userLevel);
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
			//    this.editUi.eui_charPreviewer.updateColor(_loc8_);
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
		
		private function onNullThumbClick(event:CcComponentThumbChooserEvent) : void
		{
			this.resetPanels();
			var type:String = event.noneComponentThumbType;
			//var usedCmpntId:String;
			if (CcLibConstant.ALL_LIBRARY_TYPES.indexOf(type) >= 0)
			{
				if (this.ccChar.libraries[type])
				{
					this.editUi.eui_charPreviewer.removeLibrary(type, this.ccChar.libraries[type]);
					this.ccChar.libraries[type] = null;
				}
			}
			else if (CcLibConstant.ALL_COMPONENT_TYPES.indexOf(type) >= 0)
			{
				if (this.ccChar.components[type])
				{
					this.editUi.eui_charPreviewer.removeComponent(type, this.ccChar.components[type].id);
					this.ccChar.components[type] = null;
				}
			}
			
			this.editUi.eui_colorPicker.destroy();
			this.editUi.eui_colorPicker.addComponentType(event.noneComponentThumbType, this.currentTheme, this.ccChar);
			//this.editUi.eui_thumbPropertyInspector.destroy();
			//this.addCommand(this.ccChar);
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
			var image:BitmapData;
			if (fullBody)
			{
				image = this.editUi.eui_charPreviewer.capCharAsBitmap();
			}
			else
			{
				image = this.editUi.eui_charPreviewer.capFaceAsBitmap();
			}
			var encoder:PNGEncoder = new PNGEncoder();
			return encoder.encode(image);
		}
	}
}
