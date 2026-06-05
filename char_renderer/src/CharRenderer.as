package
{
	import anifire.managers.AppConfigManager;
	import anifire.utils.SecurityUtils;
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;
	import flash.display.Sprite;
	import flash.events.Event;
	import anifire.models.creator.CCThemeModel;
	import anifire.component.CustomCharacterMaker;
	import anifire.util.UtilHashArray;
	import anifire.models.creator.CCBodyModel;
	import anifire.models.creator.CCCharacterActionModel;
	import anifire.event.LoadEmbedMovieEvent;
	import flash.display.BitmapData;
	import mx.graphics.codec.PNGEncoder;
	import mx.utils.Base64Encoder;
	import flash.events.IEventDispatcher;

	public class CharRenderer extends Sprite
	{
		private const LOADER:String = "loader";
		private var ccMaker:CustomCharacterMaker;
		private var themes:UtilHashArray;
		private var pendingChars:Vector.<Vector.<String>>;
		private var isFree:Boolean = false;
		private var currentChar:CCBodyModel;

		public function CharRenderer()
		{
			super();
			SecurityUtils.init();
			AppConfigManager.instance;
			AppConfigManager.instance.setParamters(this.loaderInfo.parameters);
			this.themes = new UtilHashArray();
			this.pendingChars = new Vector.<Vector.<String>>();
			this.addEventListener(Event.ADDED_TO_STAGE, this.initInterface);
		}

		private function initInterface(e:Event) : void
		{
			this.isFree = true;
			ExternalInterface.addCallback("addToQueue", addToQueue);
			ExternalInterface.call("rendererReady");
		}

		private function resetCcMaker() : void
		{
			if (this.ccMaker) {
				this.ccMaker.destroy();
				this.ccMaker = null;
			}
			this.ccMaker = new CustomCharacterMaker();
			this.ccMaker.name = this.LOADER;
		}

		/**
		 * adds a character to the queue
		 */
		private function addToQueue(assetId:String, themeId:String) : void
		{
			var vec:Vector.<String> = new Vector.<String>();
			vec.push(assetId);
			vec.push(themeId);
			this.pendingChars.push(vec);
			if (this.isFree) {
				this.prepareCharacter(assetId, themeId);
			}
		}

		private function prepareCharacter(assetId:String, themeId:String) : void
		{
			this.resetCcMaker();
			this.isFree = false;
			this.currentChar = new CCBodyModel(assetId);
			this.currentChar.themeId = themeId;
			this.currentChar.addEventListener(Event.COMPLETE, this.loadTheme);
			this.currentChar.load();
		}

		private function loadTheme(e:Event) : void
		{
			var themeId:String = this.currentChar.themeId;
			if (this.themes.getIndex(themeId) > -1) {
				this.initCcMaker();
				return;
			}
			var theme:CCThemeModel = new CCThemeModel(themeId);
			theme.addEventListener(Event.COMPLETE, this.loadTheme_complete);
			theme.load();
		}

		private function loadTheme_complete(e:Event) : void
		{
			var theme:CCThemeModel = e.target as CCThemeModel;
			theme.removeEventListener(e.type, this.loadTheme_complete);
			this.themes.push(theme.themeId, theme);
			this.initCcMaker();
		}

		private function initCcMaker() : void
		{
			var theme:CCThemeModel = this.themes.getValueByKey(this.currentChar.themeId);
			var actionId:String = theme.getCharacterDefaultActionId(this.currentChar.bodyShapeId);
			var cam:CCCharacterActionModel = theme.getCharacterActionModel(this.currentChar, actionId);

			// merge the facial model into the action model
			var facialId:String = cam.actionModel.defaultFacialId.replace(/\.xml$/, "");
			var faceCam:CCCharacterActionModel = theme.getCharacterFacialModel(this.currentChar, facialId);
			for (var type:String in faceCam.components) {
				cam.components[type] = faceCam.components[type];
			}

			this.ccMaker.ver = this.currentChar.version;
			this.ccMaker.addEventListener(LoadEmbedMovieEvent.COMPLETE_EVENT, this.ccMaker_loaded);
			this.ccMaker.initByCam(cam);
		}

		/**
		 * Called when `CustomCharacterMaker` has finished loading the character
		 */
		private function ccMaker_loaded(event:LoadEmbedMovieEvent) : void
		{
			(event.target as IEventDispatcher).removeEventListener(event.type, this.ccMaker_loaded);
			var image:BitmapData = this.ccMaker.getBitmap();
			var encoder:PNGEncoder = new PNGEncoder();
			var imageBytes:ByteArray = encoder.encode(image);
			var bodyB64:Base64Encoder = new Base64Encoder();
			bodyB64.encodeBytes(imageBytes);
			var assetId:String = this.currentChar.assetId;
			var bytes:String = bodyB64.flush();
			var chunks:int = Math.ceil(bytes.length / 1024);
			for (var i:int = 0; i < chunks; i++) {
				var start:int = i * 1024;
				var end:int = start + 1023;
				if (i == chunks - 1) {
					ExternalInterface.call("pushFinalThumbChunk", assetId, bytes);
					break;
				}
				ExternalInterface.call("pushThumbChunk", bytes);
			}
			this.currentChar = null;
			this.isFree = true;
			this.nextInQueue();
		}

		private function nextInQueue() : void
		{
			var pending:Vector.<String> = this.pendingChars.shift();
			if (pending) {
				this.prepareCharacter(pending[0], pending[1]);
			} else {
				this.ccMaker.destroy();
			}
		}
	}
}
