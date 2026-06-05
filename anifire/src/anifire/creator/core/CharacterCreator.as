package anifire.creator.core
{
	import anifire.constant.CcLibConstant;
	import anifire.constant.ServerConstants;
	import anifire.creator.events.CcCoreEvent;
	import anifire.creator.interfaces.ICharacterCreator;
	import anifire.creator.config.GoAnimate;
	import anifire.models.creator.CCBodyModel;
	import anifire.models.creator.CCThemeModel;
	import anifire.managers.AppConfigManager;
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
	import anifire.event.LoadEmbedMovieEvent;
	
	public class CharacterCreator extends EventDispatcher
	{
		private static var _instance:CharacterCreator;
		private static var _cfg:GoAnimate;
		private static var _configManager:AppConfigManager = AppConfigManager.instance;
		private var _app:ICharacterCreator;
		private var _creatorView:CreatorViewController;
		private var _char:CCBodyModel;
		private var _theme:CCThemeModel;
		private var _userLevel:int;
		private var _assetId:String;
		private var title:String;

		public function CharacterCreator(app:ICharacterCreator)
		{
			super();
			this._app = app;
			this._creatorView = new CreatorViewController(this._app);

			var themeId:String = _configManager.getValue(ServerConstants.PARAM_THEME_ID);
			if (themeId == null || themeId.length <= 0) {
				themeId = "family";
			}
			this._assetId = _configManager.getValue("original_asset_id") as String;
			if (this.assetId == null || this.assetId.length <= 0) {
				this._assetId = null;
			}

			var isAdmin:String = _configManager.getValue(ServerConstants.FLASHVAR_IS_ADMIN) as String;
			this._userLevel = isAdmin == "1" ?
				CcLibConstant.USER_LEVEL_SUPER :
				CcLibConstant.USER_LEVEL_NORMAL;

			this.addEventListener(CcCoreEvent.LOAD_THEME_COMPLETE, this.prepareCharacter);
			this.loadCcTheme(themeId);
		}

		public static function init(mainUi:ICharacterCreator) : CharacterCreator
		{
			if (_instance == null) {
				_cfg = new GoAnimate();
				_instance = new CharacterCreator(mainUi);
			}
			return _instance;
		}

		public static function get instance() : CharacterCreator
		{
			if (_instance != null) {
				return _instance;
			}
			throw new Error("CharacterCreator must be intialized first");
		}

		public function get configuration() : GoAnimate
		{
			return _cfg;
		}

		private function get assetId() : String
		{
			return this._assetId;
		}

		private function get userLevel() : int
		{
			return this._userLevel;
		}

		private function get mainUi() : ICharacterCreator
		{
			return this._app;
		}

		private function get creatorView() : CreatorViewController
		{
			return this._creatorView;
		}

		private function get char() : CCBodyModel
		{
			return this._char;
		}

		public function get isCopyingChar() : Boolean
		{
			return this.assetId == null ? false : true;
		}

		private function serialize() : String
		{
			return "<?xml version=\"1.0\" encoding=\"utf-8\"?>" + this.char.serialize().toXMLString();
		}

		public function getXml() : String
		{
			return this.char != null ? this.serialize() : null;
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
			ccTheme.addEventListener(Event.COMPLETE, this.loadCcTheme_complete);
			ccTheme.load();
		}

		/**
		 * Called when the CC theme has successfully been
		 * loaded and parsed.
		 * @param event `Event.COMPLETE`
		 */
		private function loadCcTheme_complete(event:Event) : void
		{
			(event.target as IEventDispatcher).removeEventListener(event.type, this.loadCcTheme_complete);
			this.dispatchEvent(new CcCoreEvent(CcCoreEvent.LOAD_THEME_COMPLETE, this));
		}

		/**
		 * Prepares a character for editing.
		 */
		private function prepareCharacter(event:Event) : void
		{
			(event.target as IEventDispatcher).removeEventListener(event.type, this.prepareCharacter);
			this.listenForCharacterLoad();
			if (this.assetId != null) {
				this.loadCharXml(_configManager.getValue("original_asset_id") as String);
			} else {
				this.loadDefaultChar();
			}
		}

		/**
		 * Listens for the `CcCoreEvent.LOAD_EXISTING_CHAR_COMPLETE`
		 * event and calls `proceedHandler` when it is dispatched.
		 */
		private function listenForCharacterLoad() : void
		{
			var self:CharacterCreator = this;
			var proceedHandler:Function = function proceedHandler(e:CcCoreEvent) : void
			{
				self.removeEventListener(e.type, proceedHandler);
				self.addJsCallbacks();
				self.switchToEditor();
			};
			this.addEventListener(CcCoreEvent.LOAD_EXISTING_CHAR_COMPLETE, proceedHandler);
		}

		/**
		 * Requests a character body XML from the API server.
		 * @param assetId ID of the character to load.
		 */
		private function loadCharXml(assetId:String) : void
		{
			this._char = new CCBodyModel(assetId);
			this._char.addEventListener(Event.COMPLETE, this.char_complete);
			this._char.load();
		}

		/**
		 * pulls a default character from a bodyshape to use as the character
		 */
		private function loadDefaultChar() : void
		{
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

			var xml:XML = new XML(bodyShape.defaultCharacterXML);
			xml.@xscale = 1;
			xml.@yscale = 1;
			xml.@hxscale = 1;
			xml.@hyscale = 1;
			xml.@headdx = 0;
			xml.@headdy = 0;
			xml.@version = this._theme.version;

			this._char = new CCBodyModel("");
			this._char.addEventListener(Event.COMPLETE, this.char_complete);
			this._char.parse(xml);
		}

		/**
		 * called when a char has finished parsing
		 */
		private function char_complete(e:Event) : void
		{
			(e.target as IEventDispatcher).removeEventListener(e.type, this.char_complete);
			var loadEvent = new CcCoreEvent(CcCoreEvent.LOAD_EXISTING_CHAR_COMPLETE, this);
			this.dispatchEvent(loadEvent);
		}

		/**
		 * Adds functions to be called in JS. These will be used
		 * to create a button bar outside the Flash object.
		 */
		private function addJsCallbacks() : void
		{
			if (ExternalInterface.available) {
				ExternalInterface.addCallback("switchBodyShape", this.switchBodyShape);
				ExternalInterface.addCallback("randomize", this.randomizeCharacter);
				ExternalInterface.addCallback("reset", this.creatorView.resetCharacter);
				ExternalInterface.addCallback("preview", this.preview);
				ExternalInterface.addCallback("save", this.timeToSave);
				ExternalInterface.addCallback("getXml", this.getXml);
			}
		}

		/**
		 * Dispatches the `CcCoreEvent.LOAD_EVERYTHING_COMPLETE`
		 * event.
		 */
		private function switchToEditor() : void
		{
			this.creatorView.start(this._theme, this.char, !this.isCopyingChar);
			if (_configManager.getValue(ServerConstants.FLASHVAR_CC_START_PAGE) == "preview") {
				this.preview();
			}
			this.dispatchEvent(new CcCoreEvent(CcCoreEvent.LOAD_EVERYTHING_COMPLETE, this));
		}

		/* stubs for planned features in the button bar */
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
			this.creatorView.addEventListener(LoadEmbedMovieEvent.COMPLETE_EVENT, this.save);
			this.creatorView.resetCCAction();
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
			var headshot:ByteArray = this.creatorView.saveSnapShot();
			headB64.encodeBytes(headshot);
			var bodyB64:Base64Encoder = new Base64Encoder();
			var body:ByteArray = this.creatorView.saveSnapShot(true);
			bodyB64.encodeBytes(body);

			var vars:URLVariables = new URLVariables();
			_configManager.appendURLVariables(vars);
			vars["body"] = this.serialize();
			vars["title"] = this.title;
			vars["imagedata"] = headB64.flush();
			vars["thumbdata"] = bodyB64.flush();
			if (this.char.assetId != "") {
				vars["assetId"] = this.char.assetId;
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
			if (ExternalInterface.available) {
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
	}
}
