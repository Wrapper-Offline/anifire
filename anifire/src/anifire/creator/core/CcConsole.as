package anifire.creator.core
{
	import anifire.constant.CcLibConstant;
	import anifire.constant.ServerConstants;
	import anifire.creator.events.CcCoreEvent;
	import anifire.creator.interfaces.ICcMainUiContainer;
	import anifire.creator.components.browser.BrowseView;
	import anifire.creator.components.editor.EditView;
	import anifire.creator.interfaces.IConfiguration;
	import anifire.creator.models.CcCharacter;
	import anifire.creator.models.CcTheme;
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
	
	public class CcConsole extends EventDispatcher
	{

		private static var _instance:anifire.creator.core.CcConsole;

		private static var _cfg:IConfiguration;

		private static var _configManager:AppConfigManager = AppConfigManager.instance;

		private var _ccChar:CcCharacter;

		private var _theme:Theme;
		private var _ccTheme:CcTheme;
		private var _themeId:String = "";
		private var _ccThemeId:String = "";

		private var _ui_mainUiContainer:ICcMainUiContainer;
		private var _ui_browseView:BrowseView;

		private var _userLevel:int;

		private var _original_assetId:String;

		private var _isEditing:Boolean = true;

		public function CcConsole(mainUi:ICcMainUiContainer, browseView:BrowseView, editView:EditView)
		{
			super();
			this._ui_mainUiContainer = mainUi;
			this._ui_browseView = browseView;
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
			this.loadTheme(this._themeId);
		}

		public static function setConfiguration(config:IConfiguration) : void
		{
			_cfg = config;
		}

		public static function init(mainUi:ICcMainUiContainer, browseView:BrowseView, editView:EditView) : CcConsole
		{
			if (_instance == null)
			{
				_instance = new CcConsole(mainUi, browseView, editView);
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

		private function set originalAssetId(param1:String) : void
		{
			this._original_assetId = param1;
		}

		private function get userLevel() : int
		{
			return this._userLevel;
		}

		private function get ui_mainUiContainer() : ICcMainUiContainer
		{
			return this._ui_mainUiContainer;
		}

		private function get ccChar() : CcCharacter
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

		private function switchToBrowser() : void
		{
			if (_configManager.getValue(ServerConstants.FLASHVAR_CC_START_PAGE) == "editor")
			{
				//init editor
				//this.onUserWantToPreview(param1);
				//return
			}
			this._ui_browseView.init()
			this.dispatchEvent(new CcCoreEvent(CcCoreEvent.LOAD_EVERYTHING_COMPLETE, this));
		}

		// private function switchToEditor() : void
		// {
		// 	this.ccEditUiController.initTheme(this._theme);
		// 	this.ccEditUiController.initMode(this.userLevel);
		// 	this.ccEditUiController.start(this.ccChar,!this.isCopyingChar());
		// 	this.ccPreviewAndSaveController.initTheme(this._theme);
		// 	this.ccPreviewAndSaveController.initMode();
		// 	this.ccPreviewAndSaveController.initChar(this.ccChar);
		// 	this._isEditing = true;
		// 	if(_configManager.getValue(ServerConstants.FLASHVAR_CC_START_PAGE) == "save")
		// 	{
		// 		this.onUserWantToPreview(param1);
		// 	}
		// 	this.dispatchEvent(new CcCoreEvent(CcCoreEvent.LOAD_EVERYTHING_COMPLETE,this));
		// }

		// private function onUserWantToModify() : void
		// {
		// 	this._isEditing = true;
		// 	this.ui_mainUiContainer.ui_main_ccCharEditor.visible = true;
		// 	this.ui_mainUiContainer.ui_main_ccCharPreviewAndSaveScreen.visible = false;
		// 	this.ccEditUiController.proceedToShow();
		// }

		// private function onUserWantToPreview() : void
		// {
		// 	this._isEditing = false;
		// 	this.ui_mainUiContainer.ui_main_ccCharEditor.visible = false;
		// 	this.ui_mainUiContainer.ui_main_ccCharPreviewAndSaveScreen.visible = true;
		// 	this.ccPreviewAndSaveController.proceedToShow();
		// }

		// private function onUserWantToSave(param1:Event) : void
		// {
		// 	this.addEventListener(CcSaveCharEvent.SAVE_CHAR_COMPLETE,this.doTellUserSaveStatus);
		// 	this.addEventListener(CcSaveCharEvent.SAVE_CHAR_ERROR_OCCUR,this.doTellUserSaveStatus);
		// 	if(this._isEditing)
		// 	{
		// 		this.ccEditUiController.addEventListener(LoadEmbedMovieEvent.COMPLETE_EVENT,this.doSave);
		// 		this.ccEditUiController.resetCCAction();
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
				switchToBrowser();
			};
			if (this.originalAssetId != null)
			{
				this.addEventListener(CcCoreEvent.LOAD_EXISTING_CHAR_COMPLETE, proceedHandler);
			}
			else
			{
				this.switchToBrowser();
			}
		}

		private function doLoadPreMadeChar(param1:Event) : void
		{
			(param1.target as IEventDispatcher).removeEventListener(param1.type, this.doLoadPreMadeChar);
			if (this.originalAssetId != null)
			{
				this.loadCharXml(_configManager.getValue("original_asset_id") as String);
			}
			else
			{
				this.doPrepareCcChar();
			}
			this.doEnableUserToStartUseCC();
		}

		private function doPrepareCcChar() : void
		{
			this._ccChar = new CcCharacter();
			if (_themeId == "cc2" || _themeId == "chibi" || _themeId == "ninja")
			{
				this._ccChar.ver = 2;
			}
			var ccTheme:CcTheme = this._theme;
			var bodyshapes:Array = ccTheme.getBodyShapeTypes();
			var randomBodyshape:String = bodyshapes[int(Math.floor(Math.random() * bodyshapes.length))] as String;
		}

		private function loadCharXml(param1:String) : void
		{
			var request:URLRequest = new URLRequest(ServerConstants.ACTION_GET_CC_CHAR_COMPOSITION_XML);
			request.method = URLRequestMethod.POST;
			var variables:URLVariables = new URLVariables();
			_configManager.appendURLVariables(variables);
			variables["assetId"] = param1;
			request.data = variables;
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, this.onLoadCharXmlComplete);
			loader.load(request);
		}

		private function onLoadCharXmlComplete(param1:Event) : void
		{
			(param1.target as IEventDispatcher).removeEventListener(param1.type, this.onLoadCharXmlComplete);
			var loader:URLLoader = param1.target as URLLoader;
			var responseText:String = loader.data as String;
			if (responseText.charAt(0) == "0")
			{
				var charData:String = responseText.substr(1);
				var loadEvent = new CcCoreEvent(CcCoreEvent.LOAD_EXISTING_CHAR_COMPLETE, this, charData);
				this.dispatchEvent(loadEvent);
				this.prepareExistingCcChar(charData);
			}
		}

		private function prepareExistingCcChar(param1:String) : void
		{
			this._ccChar = new CcCharacter();
			var themeArray:UtilHashArray = new UtilHashArray();
			themeArray.push(this._themeId, this._theme);
			this._ccChar.deserialize(new XML(param1), themeArray);
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
		// 		_loc1_ = this._ccEditUiController.saveSnapShot();
		// 		_loc3_ = this._ccEditUiController.saveSnapShot(true);
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

		// private function showLoggedOutPopUp() : void
		// {
		// 	var _loc1_:ConfirmPopUp = new ConfirmPopUp();
		// 	_loc1_.title = UtilDict.translate("Logged out");
		// 	_loc1_.message = UtilDict.translate("Login again to continue.\nUnsaved changes may have been lost.");
		// 	_loc1_.confirmText = UtilDict.translate("Login");
		// 	_loc1_.iconType = ConfirmPopUp.CONFIRM_POPUP_NO_ICON;
		// 	_loc1_.showCancelButton = false;
		// 	_loc1_.showCloseButton = false;
		// 	_loc1_.addEventListener(PopUpEvent.CLOSE,this.loggedOutPopUp_closeHandler);
		// 	_loc1_.open(FlexGlobals.topLevelApplication as DisplayObjectContainer,true);
		// }

		// private function loggedOutPopUp_closeHandler(param1:PopUpEvent) : void
		// {
		// 	ExternalLinkManager.instance.navigate(ServerConstants.LOGIN_PAGE_PATH);
		// }

		private function serialize() : String
		{
			return "<?xml version=\"1.0\" encoding=\"utf-8\"?>" + this.ccChar.serialize();
		}

		private function loadTheme(themeId:String) : void
		{
			var theme:Theme = new Theme();
			this._theme = theme;
			theme.addEventListener(CcCoreEvent.DESERIALIZE_THEME_COMPLETE, this.onLoadThemeComplete);
			theme.initThemeByLoadThemeFile(themeId);
		}

		private function onLoadThemeComplete(event:Event) : void
		{
			var theme = event.target as Theme;
			this._ccThemeId = theme.ccThemeId;
			this.loadCcTheme(this._ccThemeId);
		}

		private function loadCcTheme(ccThemeId:String) : void
		{
			var ccTheme:CcTheme = new CcTheme();
			ccTheme.id = ccThemeId;
			this._ccTheme = ccTheme;
			ccTheme.addEventListener(CcCoreEvent.LOAD_THEME_COMPLETE, this.onLoadCcThemeComplete);
			ccTheme.initCcThemeByLoadThemeFile(ccThemeId);
		}

		private function onLoadCcThemeComplete(event:Event) : void
		{
			(event.target as IEventDispatcher).removeEventListener(event.type, this.onLoadCcThemeComplete);
			this.dispatchEvent(new CcCoreEvent(CcCoreEvent.LOAD_THEME_COMPLETE, this));
		}
	}
}
