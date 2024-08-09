package anifire.creator.core
{
	import anifire.constant.CcLibConstant;
	import anifire.constant.ServerConstants;
	import anifire.creator.events.CcCoreEvent;
	import anifire.creator.interfaces.ICcMainUiContainer;
	import anifire.creator.config.GoAnimate;
	import anifire.models.creator.CCBodyModel;
	import anifire.models.creator.CCThemeModel;
	import anifire.managers.AppConfigManager;
	import anifire.managers.ServerConnector;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import anifire.models.creator.CCBodyShapeModel;
	import anifire.managers.NativeCursorManager;
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;
	import mx.utils.Base64Encoder;
	import anifire.constant.CcServerConstant;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import anifire.creator.events.CcSaveCharEvent;
	import mx.core.FlexGlobals;
	import flash.utils.setTimeout;
	import anifire.event.LoadEmbedMovieEvent;
	
	public class CcConsole extends EventDispatcher
	{

		private static var _instance:anifire.creator.core.CcConsole;

		private static var _cfg:GoAnimate;

		private static var _configManager:AppConfigManager = AppConfigManager.instance;

		private var _ccChar:CCBodyModel;
		private var _theme:CCThemeModel;
		private var _themeId:String = "";

		private var _mainUi:ICcMainUiContainer;
		private var _editUiController:CcEditUiController;

		private var _userLevel:int;

		private var _original_assetId:String;

		private var _isEditing:Boolean = true;

		private var title:String;

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
			this.originalAssetId = _configManager.getValue("original_asset_id") as String;
			if (this.originalAssetId == null || this.originalAssetId.length <= 0)
			{
				this.originalAssetId = null;
			}
			var isAdmin:String = _configManager.getValue(ServerConstants.FLASHVAR_IS_ADMIN) as String;
			this._userLevel = isAdmin == "1" ?
				CcLibConstant.USER_LEVEL_SUPER :
				CcLibConstant.USER_LEVEL_NORMAL;

			this.addJsCallbacks();
			this.addEventListener(CcCoreEvent.LOAD_THEME_COMPLETE, this.prepareCharacter);
			this.loadCcTheme(this._themeId);
		}

		public static function init(mainUi:ICcMainUiContainer) : CcConsole
		{
			if (_instance == null)
			{
				_cfg = new GoAnimate();
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

		public function get configuration() : GoAnimate
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

		public function get isCopyingChar() : Boolean
		{
			return this.originalAssetId == null ? false : true;
		}

		private function serialize() : String
		{
			return "<?xml version=\"1.0\" encoding=\"utf-8\"?>" + this.ccChar.serialize().toXMLString();
		}

		/**
		 * Adds functions to be called in JS. These will be used
		 * to create a button bar outside the Flash object.
		 */
		private function addJsCallbacks() : void
		{
			if (ExternalInterface.available)
			{
				ExternalInterface.addCallback("undo", this.undo);
				ExternalInterface.addCallback("redo", this.redo);
				ExternalInterface.addCallback("switchBodyShape", this.switchBodyShape);
				ExternalInterface.addCallback("randomize", this.randomizeCharacter);
				ExternalInterface.addCallback("reset", this.editUiController.resetCharacter);
				ExternalInterface.addCallback("preview", this.preview);
				ExternalInterface.addCallback("save", this.timeToSave);
			}
		}

		/* stubs for planned features in the button bar */
		private function undo() : void
		{
			
		}
		private function redo() : void
		{
			
		}
		private function switchBodyShape() : void
		{
			
		}
		private function randomizeCharacter() : void
		{
			
		}
		private function preview() : void
		{
			
		}

		/**
		 * Resets the character action in preparation for the
		 * snapshots and calls `this.save`.
		 */
		private function timeToSave(title:String) : void
		{
			this.title = title;
			this.editUiController.addEventListener(LoadEmbedMovieEvent.COMPLETE_EVENT, this.save);
			this.editUiController.resetCCAction();
		}

		/**
		 * Captures images of the character and sends them to
		 * server, along with the character body XML.
		 */
		private function save(e:Event) : void
		{
			(e.target as IEventDispatcher).removeEventListener(e.type, this.save);
			NativeCursorManager.instance.setBusyCursor();
			FlexGlobals.topLevelApplication.enabled = false;

			var headB64:Base64Encoder = new Base64Encoder();
			var headshot:ByteArray = this.editUiController.saveSnapShot();
			headB64.encodeBytes(headshot);
			var bodyB64:Base64Encoder = new Base64Encoder();
			var body:ByteArray = this.editUiController.saveSnapShot(true);
			bodyB64.encodeBytes(body);

			var vars:URLVariables = new URLVariables();
			_configManager.appendURLVariables(vars);
			vars["body"] = this.serialize();
			vars["title"] = this.title;
			vars["imagedata"] = headB64.flush();
			vars["thumbdata"] = bodyB64.flush();
			if (this.ccChar.assetId != "")
			{
				vars["assetId"] = this.ccChar.assetId;
			}
			var request:URLRequest = new URLRequest(CcServerConstant.ACTION_SAVE_CC_CHAR);
			request.data = vars;
			request.method = URLRequestMethod.POST;
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, this.saveCharacter_completeHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, this.saveCharacter_errorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.saveCharacter_errorHandler);
			loader.load(request);
		}

		/**
		 * Called when the character has been saved successfully.
		 * @param event `Event.COMPLETE`
		 */
		private function saveCharacter_completeHandler(event:Event) : void
		{
			NativeCursorManager.instance.removeBusyCursor();
			var loader:URLLoader = event.target as URLLoader;
			loader.removeEventListener(Event.COMPLETE, this.saveCharacter_completeHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, this.saveCharacter_errorHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.saveCharacter_errorHandler);
			var responseText:String = loader.data as String;
			var status:String = responseText.slice(0,1);
			var id:String = responseText.slice(1);
			if (ExternalInterface.available)
			{
				ExternalInterface.call("onCharacterSave", id);
			}
		}

		/**
		 * Called when the not character did not successfully.
		 * @param event `IOErrorEvent.IO_ERROR` or
		 * `SecurityErrorEvent.SECURITY_ERROR`
		 */
		private function saveCharacter_errorHandler(event:Event) : void
		{
			var loader:URLLoader = event.target as URLLoader;
			loader.removeEventListener(Event.COMPLETE, this.saveCharacter_completeHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, this.saveCharacter_errorHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.saveCharacter_errorHandler);
			this.dispatchEvent(new CcSaveCharEvent(CcSaveCharEvent.SAVE_CHAR_ERROR_OCCUR, this));
		}

		/**
		 * Loads a CC theme from the store.
		 * @param themeId ID of the CC theme to load.
		 */
		private function loadCcTheme(themeId:String) : void
		{
			var ccTheme:CCThemeModel = new CCThemeModel(themeId);
			this._theme = ccTheme;
			ccTheme.runwayMode = true;
			ccTheme.addEventListener(Event.COMPLETE, this.onLoadCcThemeComplete);
			ccTheme.load();
		}

		/**
		 * Called when the CC theme has successfully been
		 * loaded and parsed.
		 * @param event `Event.COMPLETE`
		 */
		private function onLoadCcThemeComplete(event:Event) : void
		{
			(event.target as IEventDispatcher).removeEventListener(event.type, this.onLoadCcThemeComplete);
			this.dispatchEvent(new CcCoreEvent(CcCoreEvent.LOAD_THEME_COMPLETE, this));
		}

		/**
		 * Prepares a character for editing.
		 */
		private function prepareCharacter(event:Event) : void
		{
			(event.target as IEventDispatcher).removeEventListener(event.type, this.prepareCharacter);
			this.listenForCharacterLoad();
			if (this.originalAssetId != null)
			{
				this.loadCharXml(_configManager.getValue("original_asset_id") as String);
			}
			else
			{
				this.loadDefaultChar();
			}
		}

		/**
		 * Pulls a default character from a bodyshape to use as
		 * our character.
		 */
		private function loadDefaultChar() : void
		{
			var ccTheme:CCThemeModel = this._theme;
			var bodyShape:CCBodyShapeModel;
			var bsId:String = _configManager.getValue(ServerConstants.PARAM_BODYSHAPE);
			if (bsId != null && bsId.length > 0)
			{
				if (bsId == "__random")
				{
					var bodyShapes:Object = ccTheme.bodyShapes;
					bsId = bodyShapes[int(Math.floor(Math.random() * bodyShapes.length))] as String;
				}
				bodyShape = ccTheme.bodyShapes[bsId];
			}
			if (bodyShape == null)
			{
				bodyShape = ccTheme.bodyShapes[ccTheme.defaultBodyShape];
			}

			this._ccChar = new CCBodyModel("");
			this._ccChar.addEventListener(Event.COMPLETE, this.onLoadCharXmlComplete);
			this._ccChar.parse(new XML(bodyShape.defaultCharacterXML));
			this._ccChar.bodyScale.scalex = 1;
			this._ccChar.bodyScale.scaley = 1;
			this._ccChar.headScale.scalex = 1;
			this._ccChar.headScale.scaley = 1;
			this._ccChar.headPos.dx = 0;
			this._ccChar.headPos.dy = 0;
			this._ccChar.version = this._theme.version;
		}

		/**
		 * Requests a character body XML from the API server.
		 * @param assetId ID of the character to load.
		 */
		private function loadCharXml(assetId:String) : void
		{
			this._ccChar = new CCBodyModel(assetId);
			this._ccChar.addEventListener(Event.COMPLETE, this.onLoadCharXmlComplete);
			this._ccChar.load();
		}

		/**
		 * Requests a character body XML from the server.
		 * @param e ID of the character to load.
		 */
		private function onLoadCharXmlComplete(e:Event) : void
		{
			(e.target as IEventDispatcher).removeEventListener(e.type, this.onLoadCharXmlComplete);
			var loadEvent = new CcCoreEvent(CcCoreEvent.LOAD_EXISTING_CHAR_COMPLETE, this);
			this.dispatchEvent(loadEvent);
		}

		/**
		 * Listens for the `CcCoreEvent.LOAD_EXISTING_CHAR_COMPLETE`
		 * event and calls `proceedHandler` when it is dispatched.
		 */
		private function listenForCharacterLoad() : void
		{
			var self:CcConsole = this;
			var proceedHandler:Function = function proceedHandler(e:CcCoreEvent):void
			{
				self.removeEventListener(e.type, proceedHandler);
				self.switchToEditor();
			};
			this.addEventListener(CcCoreEvent.LOAD_EXISTING_CHAR_COMPLETE, proceedHandler);
		}

		/**
		 * Dispatches the `CcCoreEvent.LOAD_EVERYTHING_COMPLETE`
		 * event.
		 */
		private function switchToEditor() : void
		{
			this.editUiController.initTheme(this._theme);
			this.editUiController.initMode(this.userLevel);
			this.editUiController.start(this.ccChar, !this.isCopyingChar);
			this._isEditing = true;
			if (_configManager.getValue(ServerConstants.FLASHVAR_CC_START_PAGE) == "preview")
			{
				this.preview();
			}
			this.dispatchEvent(new CcCoreEvent(CcCoreEvent.LOAD_EVERYTHING_COMPLETE, this));
		}
	}
}
