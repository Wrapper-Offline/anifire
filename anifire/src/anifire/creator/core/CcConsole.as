package anifire.creator.core
{
	import anifire.constant.CcLibConstant;
	import anifire.constant.ServerConstants;
	import anifire.creator.events.CcCoreEvent;
	import anifire.creator.interfaces.ICcMainUiContainer;
	import anifire.creator.interfaces.IConfiguration;
	import anifire.models.creator.CCBodyModel;
	import anifire.models.creator.CCThemeModel;
	import anifire.creator.theme.Theme;
	import anifire.managers.AppConfigManager;
	import anifire.managers.ServerConnector;
	import anifire.util.UtilHashArray;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import anifire.models.creator.CCBodyShapeModel;
	
	public class CcConsole extends EventDispatcher
	{

		private static var _instance:anifire.creator.core.CcConsole;

		private static var _cfg:IConfiguration;

		private static var _configManager:AppConfigManager = AppConfigManager.instance;

		private var _ccChar:CCBodyModel;
		private var _theme:CCThemeModel;
		private var _themeId:String = "";

		private var _mainUi:ICcMainUiContainer;
		private var _editUiController:CcEditUiController;

		private var _userLevel:int;

		private var _original_assetId:String;

		private var _isEditing:Boolean = true;

		public function CcConsole(iMainUi:ICcMainUiContainer)
		{
			super();
			this._mainUi = iMainUi;
			this._editUiController = new CcEditUiController();
			this.editUiController.initUi(iMainUi.mui_editView);
			var themeId:String = _configManager.getValue(ServerConstants.PARAM_THEME_ID);
			if (themeId == null || themeId.length <= 0)
			{
				themeId = "family";
			}
			this._themeId = themeId;
			// are we copying an existing character?
			this.originalAssetId = _configManager.getValue("original_asset_id") as String;
			if (this.originalAssetId == null || this.originalAssetId.length <= 0)
			{
				this.originalAssetId = null;
			}
			// check if the user is an admin
			var isAdmin:String = _configManager.getValue(ServerConstants.FLASHVAR_IS_ADMIN) as String;
			this._userLevel = isAdmin == "1" ?
				CcLibConstant.USER_LEVEL_SUPER :
				CcLibConstant.USER_LEVEL_NORMAL;

			this.addEventListener(CcCoreEvent.LOAD_THEME_COMPLETE, this.doLoadPreMadeChar);
			this.loadCcTheme(this._themeId);
		}

		public static function setConfiguration(config:IConfiguration) : void
		{
			_cfg = config;
		}

		public static function init(mainUi:ICcMainUiContainer) : CcConsole
		{
			if (_instance == null)
			{
				_instance = new CcConsole(mainUi);
			}
			return _instance;
		}

		public static function get instance() : CcConsole
		{
			if (_instance != null)
			{
				return _instance;
			}
			throw new Error("CcConsole must be intialized first");
		}

		public function get configuration() : IConfiguration
		{
			return _cfg;
		}

		private function get originalAssetId() : String
		{
			return this._original_assetId;
		}

		private function set originalAssetId(assetId:String) : void
		{
			this._original_assetId = assetId;
		}

		private function get userLevel() : int
		{
			return this._userLevel;
		}

		private function get mainUi() : ICcMainUiContainer
		{
			return this._mainUi;
		}

		private function get editUiController() : CcEditUiController
		{
			return this._editUiController;
		}

		private function get ccChar() : CCBodyModel
		{
			return this._ccChar;
		}

		private function onConfirmAlert(param1:Event) : void
		{
			ServerConnector.instance.refreshUserType();
		}

		public function isCopyingChar() : Boolean
		{
			return this.originalAssetId == null ? false : true;
		}

		private function switchToEditor() : void
		{
			this.editUiController.initTheme(this._theme);
			this.editUiController.initMode(this.userLevel);
			this.editUiController.start(this.ccChar, !this.isCopyingChar());
			this._isEditing = true;
			if (_configManager.getValue(ServerConstants.FLASHVAR_CC_START_PAGE) == "save")
			{
				//this.onUserWantToPreview(param1);
			}
			this.dispatchEvent(new CcCoreEvent(CcCoreEvent.LOAD_EVERYTHING_COMPLETE, this));
		}

		// private function onUserWantToModify() : void
		// {
		// 	this._isEditing = true;
		// 	this.mainUi.ui_main_ccCharEditor.visible = true;
		// 	this.mainUi.ui_main_ccCharPreviewAndSaveScreen.visible = false;
		// 	this.cceditUiControllerController.proceedToShow();
		// }

		// private function onUserWantToPreview() : void
		// {
		// 	this._isEditing = false;
		// 	this.mainUi.ui_main_ccCharEditor.visible = false;
		// 	this.mainUi.ui_main_ccCharPreviewAndSaveScreen.visible = true;
		// 	this.ccPreviewAndSaveController.proceedToShow();
		// }

		// private function onUserWantToSave(param1:Event) : void
		// {
		// 	this.addEventListener(CcSaveCharEvent.SAVE_CHAR_COMPLETE,this.doTellUserSaveStatus);
		// 	this.addEventListener(CcSaveCharEvent.SAVE_CHAR_ERROR_OCCUR,this.doTellUserSaveStatus);
		// 	if(this._isEditing)
		// 	{
		// 		this.cceditUiControllerController.addEventListener(LoadEmbedMovieEvent.COMPLETE_EVENT,this.doSave);
		// 		this.cceditUiControllerController.resetCCAction();
		// 	}
		// 	else
		// 	{
		// 		this.ccPreviewAndSaveController.addEventListener(LoadEmbedMovieEvent.COMPLETE_EVENT,this.doSave);
		// 		this.ccPreviewAndSaveController.resetCCAction();
		// 	}
		// }

		// private function doSave(param1:Event) : void
		// {
		// 	NativeCursorManager.instance.setBusyCursor();
		// 	FlexGlobals.topLevelApplication.enabled = false;
		// 	setTimeout(this.save, 5000);
		// }

		// private function doTellUserSaveStatus(param1:CcSaveCharEvent) : void
		// {
		// 	var isTemplate:Boolean = false;
		// 	var js:String = null;
		// 	var event:CcSaveCharEvent = param1;
		// 	this.removeEventListener(CcSaveCharEvent.SAVE_CHAR_COMPLETE,this.doTellUserSaveStatus);
		// 	this.removeEventListener(CcSaveCharEvent.SAVE_CHAR_ERROR_OCCUR,this.doTellUserSaveStatus);
		// 	if(event.type == CcSaveCharEvent.SAVE_CHAR_COMPLETE)
		// 	{
		// 		this.ccPreviewAndSaveController.proceedToSaveComplete(event.assetId);
		// 		try
		// 		{
		// 			isTemplate = false;
		// 			if(this.ccChar.copiedFromTemplate)
		// 			{
		// 				try
		// 				{
		// 					isTemplate = !this.ccChar.isTemplateModified();
		// 				}
		// 				catch(e2:Error)
		// 				{
		// 				}
		// 			}
		// 		// a lot of yapping
		// 			js = StringUtil.substitute("CCStandaloneBannerAdUI.gaLogTx.logCCPartsNormal({0}, {1}, {2})",event.assetId,com.adobe.serialization.json.JSON.encode(event.gaTrackModel.parts.filter(function(param1:*, param2:int, param3:Array):Boolean
		// 			{
		// 				return (["GoUpper","GoLower","upper_body","lower_body","hair"] as Array).indexOf(param1.ctype) >= 0;
		// 			})),isTemplate ? this.ccChar.templateId : "0");
		// 			ExternalInterface.call(js);
		// 		}
		// 		catch(e:Error)
		// 		{
		// 		}
		// 	} else if(event.type == CcSaveCharEvent.SAVE_CHAR_ERROR_OCCUR)
		// 	{
		// 		this.ccPreviewAndSaveController.proceedToSaveError();
		// 	}
		// }

		private function doEnableUserToStartUseCC() : void
		{
			var self:CcConsole = this;
			var proceedHandler:Function = function proceedHandler(e:CcCoreEvent):void
			{
				self.removeEventListener(CcCoreEvent.LOAD_EXISTING_CHAR_COMPLETE, proceedHandler);
				self.switchToEditor();
			};
			this.addEventListener(CcCoreEvent.LOAD_EXISTING_CHAR_COMPLETE, proceedHandler);
		}

		private function doLoadPreMadeChar(param1:Event) : void
		{
			(param1.target as IEventDispatcher).removeEventListener(param1.type, this.doLoadPreMadeChar);
			this.doEnableUserToStartUseCC();
			if (this.originalAssetId != null)
			{
				this.loadCharXml(_configManager.getValue("original_asset_id") as String);
			}
			else
			{
				this.doPrepareCcChar();
			}
		}

		private function doPrepareCcChar() : void
		{
			// TODO: dehardcode this
			if (_themeId == "cc2" || _themeId == "chibi" || _themeId == "ninja")
			{
				this._ccChar.version = 2;
			}
			var ccTheme:CCThemeModel = this._theme;
			var bodyShape:CCBodyShapeModel;
			var bsId:String = _configManager.getValue(ServerConstants.PARAM_BODYSHAPE);
			if (bsId != null && bsId.length > 0) {
				if (bsId == "__random") {
					var bodyShapes:Object = ccTheme.bodyShapes;
					bsId = bodyShapes[int(Math.floor(Math.random() * bodyShapes.length))] as String;
				}
				bodyShape = ccTheme.bodyShapes[bsId];
			}
			if (bodyShape == null) {
				bodyShape = ccTheme.bodyShapes[ccTheme.defaultBodyShape];
			}

			this._ccChar = new CCBodyModel("");
			this._ccChar.addEventListener(Event.COMPLETE, this.onLoadCharXmlComplete);
			this._ccChar.parse(new XML(bodyShape.defaultCharacterXML));
		}

		/**
		 * Requests a character body XML from the server.
		 * @param ID of the character to load.
		 */
		private function loadCharXml(assetId:String) : void
		{
			this._ccChar = new CCBodyModel(assetId);
			this._ccChar.addEventListener(Event.COMPLETE, this.onLoadCharXmlComplete);
			this._ccChar.load();
		}

		/**
		 * Requests a character body XML from the server.
		 * @param ID of the character to load.
		 */
		private function onLoadCharXmlComplete(e:Event) : void
		{
			(e.target as IEventDispatcher).removeEventListener(e.type, this.onLoadCharXmlComplete);
			var loadEvent = new CcCoreEvent(CcCoreEvent.LOAD_EXISTING_CHAR_COMPLETE, this);
			this.dispatchEvent(loadEvent);
		}

		// private function save() : void
		// {
		// 	var _loc1_:ByteArray = null;
		// 	var _loc2_:Base64Encoder = null;
		// 	var _loc3_:ByteArray = null;
		// 	var _loc4_:Base64Encoder = null;
		// 	NativeCursorManager.instance.setBusyCursor();
		// 	AmplitudeAnalyticsManager.instance.log(AmplitudeAnalyticsManager.EVENT_NAME_CREATED_CHARACTER);
		// 	if(this._isEditing)
		// 	{
		// 		_loc1_ = this._cceditUiControllerController.saveSnapShot();
		// 		_loc3_ = this._cceditUiControllerController.saveSnapShot(true);
		// 	}
		// 	else
		// 	{
		// 		_loc1_ = this._ccPreviewAndSaveController.saveSnapShot();
		// 		_loc3_ = this._ccPreviewAndSaveController.saveSnapShot(true);
		// 	}
		// 	_loc2_ = new Base64Encoder();
		// 	_loc2_.encodeBytes(_loc1_);
		// 	(_loc4_ = new Base64Encoder()).encodeBytes(_loc3_);
		// 	var _loc5_:URLLoader = new URLLoader();
		// 	var _loc6_:URLRequest = new URLRequest(CcServerConstant.ACTION_SAVE_CC_CHAR);
		// 	var _loc7_:URLVariables = new URLVariables();
		// 	_configManager.appendURLVariables(_loc7_);
		// 	_loc7_["body"] = this.serialize();
		// 	_loc7_["title"] = "Untitled";
		// 	_loc7_["imagedata"] = _loc2_.flush();
		// 	_loc7_["thumbdata"] = _loc4_.flush();
		// 	if(this.ccChar.assetId != "")
		// 	{
		// 		_loc7_["assetId"] = this.ccChar.assetId;
		// 	}
		// 	_loc6_.data = _loc7_;
		// 	_loc6_.method = URLRequestMethod.POST;
		// 	_loc5_.dataFormat = URLLoaderDataFormat.TEXT;
		// 	_loc5_.addEventListener(Event.COMPLETE,this.saveCharacter_completeHandler);
		// 	_loc5_.addEventListener(IOErrorEvent.IO_ERROR,this.saveCharacter_errorHandler);
		// 	_loc5_.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.saveCharacter_errorHandler);
		// 	_loc5_.load(_loc6_);
		// }

		// private function saveCharacter_completeHandler(param1:Event) : void
		// {
		// 	NativeCursorManager.instance.removeBusyCursor();
		// 	var _loc2_:URLLoader = param1.target as URLLoader;
		// 	var _loc3_:String = _loc2_.data as String;
		// 	_loc2_.removeEventListener(Event.COMPLETE,this.saveCharacter_completeHandler);
		// 	_loc2_.removeEventListener(IOErrorEvent.IO_ERROR,this.saveCharacter_errorHandler);
		// 	_loc2_.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.saveCharacter_errorHandler);
		// 	var _loc4_:String = _loc3_.slice(0,1);
		// 	var _loc5_:String = _loc3_.slice(1);
		// 	if(_loc4_ == "1" && _loc5_ == ServerConstants.ERROR_CODE_LOGGED_OUT)
		// 	{
		// 		this.showLoggedOutPopUp();
		// 	}
		// 	else if(ExternalInterface.available)
		// 	{
		// 		ExternalInterface.call("characterSaved",_loc5_);
		// 	}
		// }

		// private function saveCharacter_errorHandler(param1:Event) : void
		// {
		// 	var _loc2_:URLLoader = param1.target as URLLoader;
		// 	_loc2_.removeEventListener(Event.COMPLETE,this.saveCharacter_completeHandler);
		// 	_loc2_.removeEventListener(IOErrorEvent.IO_ERROR,this.saveCharacter_errorHandler);
		// 	_loc2_.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.saveCharacter_errorHandler);
		// 	this.dispatchEvent(new CcSaveCharEvent(CcSaveCharEvent.SAVE_CHAR_ERROR_OCCUR,this));
		// }

		private function serialize() : String
		{
			return "<?xml version=\"1.0\" encoding=\"utf-8\"?>" + this.ccChar.source;
		}

		private function loadCcTheme(themeId:String) : void
		{
			var ccTheme:CCThemeModel = new CCThemeModel(themeId);
			this._theme = ccTheme;
			ccTheme.runwayMode = true;
			ccTheme.addEventListener(Event.COMPLETE, this.onLoadCcThemeComplete);
			ccTheme.load();
		}

		private function onLoadCcThemeComplete(event:Event) : void
		{
			(event.target as IEventDispatcher).removeEventListener(event.type, this.onLoadCcThemeComplete);
			this.dispatchEvent(new CcCoreEvent(CcCoreEvent.LOAD_THEME_COMPLETE, this));
		}
	}
}
