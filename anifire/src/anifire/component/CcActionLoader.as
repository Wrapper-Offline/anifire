package anifire.component
{
	import anifire.constant.CcLibConstant;
	import anifire.constant.ServerConstants;
	import anifire.core.CCLipSyncController;
	import anifire.managers.AppConfigManager;
	import anifire.models.creator.CCCharacterActionModel;
	import anifire.util.UtilErrorLogger;
	import anifire.util.UtilHashActionLoader;
	import anifire.util.UtilHashArray;
	import anifire.util.UtilHashBytes;
	import anifire.util.UtilNetwork;
	import anifire.util.UtilURLStream;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	public class CcActionLoader extends EventDispatcher
	{
		private static var _loaders:UtilHashActionLoader = new UtilHashActionLoader();
		private static var _configManager:AppConfigManager;
		private const STATE_NULL:String = "STATE_NULL";
		private const STATE_LOADING:String = "STATE_LOADING";
		private const STATE_LOADED:String = "STATE_LOADED";
		private var _imageData:Object;
		private var _regulator:ProcessRegulator;
		private var _state:String = "STATE_NULL";
		
		public function CcActionLoader()
		{
			super();
			_configManager = AppConfigManager.instance;
		}
		
		public static function getActionLoader(filename:String) : CcActionLoader
		{
			if (Boolean(filename) && filename != "")
			{
				var loader:CcActionLoader = _loaders.getValueByKey(filename) as CcActionLoader;
				if (!loader)
				{
					loader = new CcActionLoader();
					_loaders.push(filename, loader);
				}
				return loader;
			}
			return new CcActionLoader();
		}

		/**
		 * returns a full asset url from its path after the store/cc_store folder
		 */
		public static function getStoreUrl(path:String, themeIdUnused:String = "", ver:Number = 1) : String
		{
			var ccStore:String;
			switch (ver)
			{
				case 3:
					ccStore = "";
					break;
				default:
					ccStore = "cc_store/";
			}
			var root:String = _configManager.getValue(ServerConstants.FLASHVAR_STORE_PATH);
			if (root == "" || root == null)
			{
				// default to the apiserver if no store path is specified
				root = _configManager.getValue(ServerConstants.FLASHVAR_APISERVER);
				if (root.charAt(root.length - 1) !== "/") {
					root += "/";
				}
				root += "static/store/" + ccStore + path;
			}
			else
			{
				var placeholder:RegExp = new RegExp(ServerConstants.FLASHVAR_STORE_PLACEHOLDER, "g");
				root = root.replace(placeholder, ccStore + path);
			}
			return root;
		}
		
		public function get imageData() : Object
		{
			return this._imageData;
		}
		
		public function load(aid:String, actionId:String = "", facialId:String = "", isDefault:Boolean = false) : void
		{
			try
			{
				if (aid)
				{
					var request:URLRequest;
					var stream:UtilURLStream = new UtilURLStream();
					request = UtilNetwork.getGetCcActionRequest(aid, actionId, facialId, isDefault);
					stream.addEventListener(Event.COMPLETE, this.onXmlLoaded);
					stream.addEventListener(IOErrorEvent.IO_ERROR, this.ioErrorHandler);
					stream.addEventListener(UtilURLStream.TIME_OUT, this.timeoutHandler);
					stream.load(request);
				}
			}
			catch (e:Error)
			{
				UtilErrorLogger.getInstance().appendCustomError("CcActionLoader:load", e);
			}
		}
		
		private function onXmlLoaded(e:Event) : void
		{
			try
			{
				IEventDispatcher(e.target).removeEventListener(e.type, this.onXmlLoaded);
				var stream:URLStream = URLStream(e.target);
				var bytes:ByteArray = new ByteArray();
				stream.readBytes(bytes);
				var xmlCC:XML = XML(bytes);
				this.loadCcComponents(xmlCC);
			}
			catch (e:Error)
			{
				dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
				UtilErrorLogger.getInstance().appendCustomError("CcActionLoader:onXmlLoaded:", e);
			}
		}

		/**
		 * initializes the imagedata object
		 */
		private function initImageData(imageData:UtilHashBytes, xml:XML = null, cam:CCCharacterActionModel = null) : void
		{
			if (!this._imageData)
			{
				this._imageData = new Object();
			}
			if (!this._imageData["imageData"])
			{
				this._imageData["imageData"] = !!imageData ? imageData : new UtilHashBytes();
			}
			if (xml)
			{
				this._imageData["xml"] = xml;
			}
			if (cam)
			{
				this._imageData["cam"] = cam;
			}
		}
		
		public function loadCcComponents(xml:XML, startMs:Number = 0, endMs:Number = 0, imageData:UtilHashBytes = null, ver:Number = 1, unused:Boolean = false, unused2:String = "", filename:String = "", kms:Boolean = false) : void
		{
			if (this._state == this.STATE_LOADED)
			{
				this.dispatchEvent(new Event(Event.COMPLETE));
			}
			else if (!xml || this._state == this.STATE_LOADING)
			{
				return;
			}
			this._state = this.STATE_LOADING;
			this.initImageData(imageData, xml);

			var element:XML;
			var key:String;
			var url:String;
			this._regulator = new ProcessRegulator();
			for each (element in xml..library)
			{
				var themeId:String = String(element.@theme_id);
				var type:String = element.@type;
				if (ver == 3)
				{
					if (element.@type == CcLibConstant.COMPONENT_TYPE_MOUTH)
					{
						this.doLoadExtraComponent(element, filename, ver);
						continue;
					}
					url = getStoreUrl(themeId + "/charparts" + "/" + type + "/" + element.@path + ".swf", themeId, ver);
					type = CcLibConstant.LIBRARY_TYPE_GOHANDS;
				}
				else
				{
					url = getStoreUrl(themeId + "/" + type + "/" + element.@path + ".swf", themeId);
				}
				key = themeId + "." + type + "." + element.@path + ".swf";
				this.loadCcComponent(key, url);
			}
			var bsPath:String = "default";
			for each (element in xml..component)
			{
				if (element.@type == "bodyshape")
				{
					bsPath = element.@path;
				}
			}
			for each (element in xml..component)
			{
				if (element.hasOwnProperty("@file"))
				{
					url = getStoreUrl(element.@theme_id + "/" + element.@type + "/" + element.@path + "/" + element.@file);
				}
				else
				{
					if (element.@type != "freeaction" || element.@path == "default" || kms)
					{
						continue;
					}
					if (bsPath == element.@path)
					{
						continue;
					}
					url = getStoreUrl(element.@theme_id + "/" + element.@type + "/" + bsPath + "/" + element.@path + ".swf");
				}
				key = element.@theme_id + "." + element.@type + "." + element.@path + ".swf";
				this.loadCcComponent(key, url);
				this.doLoadExtraComponent(element);
			}
			this._regulator.startProcess();
			if (this._regulator.numProcess == 0)
			{
				this._state = this.STATE_LOADED;
				this._regulator = null;
				this.dispatchEvent(new Event(Event.COMPLETE));
			}
		}

		/**
		 * loads components from a characteractionmodel
		 */
		public function loadCcComponentsByCam(cam:CCCharacterActionModel, imageData:UtilHashBytes = null, ver:Number = 1) : void
		{
			if (this._state == this.STATE_LOADED)
			{
				this.dispatchEvent(new Event(Event.COMPLETE));
				return;
			}
			if (!cam || this._state == this.STATE_LOADING)
			{
				return;
			}
			this._state = this.STATE_LOADING;
			this.initImageData(imageData, null, cam);

			var index:String;
			var path:String;
			this._regulator = new ProcessRegulator();
			for (index in cam.libraryPaths)
			{
				path = cam.libraryPaths[index] as String;
				this.loadCcComponent(path, getStoreUrl(path));
			}
			for (index in cam.components)
			{
				// multiple components of the same type are allowed
				if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(index) > -1)
				{
					var compsOfType:Object = cam.components[index];
					for (var i2:String in compsOfType)
					{
						path = String(compsOfType[i2].path);
						this.loadCcComponent(path, getStoreUrl(path));
					}
				}
				else
				{
					path = String(cam.getComponentByType(index).path);
					this.loadCcComponent(path, getStoreUrl(path));
					this.doLoadExtraComponentByCam(cam, index);
				}
			}
			this._regulator.startProcess();
			if (this._regulator.numProcess == 0)
			{
				this._state = this.STATE_LOADED;
				this._regulator = null;
				this.dispatchEvent(new Event(Event.COMPLETE));
			}
		}

		private function loadCcComponent(path:String, storeUrl:String) : void
		{
			if (!this._regulator || this._state == this.STATE_LOADED) {
				return;
			}
			if (UtilHashBytes(this._imageData["imageData"]).getValueByKey(path) == null)
			{
				var compLoader:CcComponentLoader = CcComponentLoader.getComponentLoader(path, storeUrl);
				compLoader.addEventListener(Event.COMPLETE, this.onCcComponentLoaded);
				compLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onCcComponentFailed);
				this._regulator.addProcess(compLoader, Event.COMPLETE);
			}
		}
		
		private function onCcComponentLoaded(e:Event) : void
		{
			try
			{
				var loader:CcComponentLoader = CcComponentLoader(e.target);
				if (loader)
				{
					loader.removeEventListener(e.type, this.onCcComponentLoaded);
					this.addComponent(loader.componentId, loader.swfBytes);
				}
			}
			catch (e:Error)
			{
				UtilErrorLogger.getInstance().appendCustomError("CcActionLoader:onCcComponentLoaded:", e);
			}
		}
		
		private function addComponent(param1:String, param2:ByteArray) : void
		{
			UtilHashBytes(this._imageData["imageData"]).push(param1, param2);
			this.progress();
		}
		
		private function progress() : void
		{
			var _loc1_:ProgressEvent = new ProgressEvent(ProgressEvent.PROGRESS);
			_loc1_.bytesLoaded = UtilHashBytes(this._imageData["imageData"]).length;
			_loc1_.bytesTotal = this._regulator.numProcess;
			this.dispatchEvent(_loc1_);
			if (UtilHashBytes(this._imageData["imageData"]).length == this._regulator.numProcess)
			{
				this._state = this.STATE_LOADED;
				this.dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		public function doLoadExtraComponentByCam(cam:CCCharacterActionModel, param2:String, param3:String = "", param4:Number = 1) : void
		{
			if (param2 == CcLibConstant.COMPONENT_TYPE_MOUTH)
			{
				var _loc6_:Object = CCLipSyncController.getLipSyncComponentItemsByCam(cam, param2, param3, param4);
				var _loc7_:UtilHashBytes = this._imageData["imageData"] as UtilHashBytes;
				for (var _loc8_:String in _loc6_)
				{
					var _loc9_:String = String(_loc6_[_loc8_]);
					if (_loc7_.getValueByKey(_loc9_) == null)
					{
						var _loc5_:CcComponentLoader = CcComponentLoader.getComponentLoader(_loc9_, _loc8_);
						_loc5_.addEventListener(Event.COMPLETE, this.onCcComponentLoaded);
						_loc5_.addEventListener(IOErrorEvent.IO_ERROR, this.onCcComponentFailed);
						this._regulator.addProcess(_loc5_, Event.COMPLETE);
					}
				}
			}
		}
		
		public function doLoadExtraComponent(param1:XML, param2:String = "", param3:Number = 1) : void
		{
			var _loc5_:UtilHashArray = new UtilHashArray();
			if (param1.@type == CcLibConstant.COMPONENT_TYPE_MOUTH)
			{
				var _loc7_:UtilHashArray = CCLipSyncController.getLipSyncComponentItems(param1, param2, param3);
				_loc5_.insert(0, _loc7_);
			}
			for (var _loc6_:int = 0; _loc6_ < _loc5_.length; _loc6_++)
			{
				var _loc8_:String = _loc5_.getKey(_loc6_);
				var _loc9_:String = _loc5_.getValueByIndex(_loc6_);
				if (UtilHashBytes(this._imageData["imageData"]).getValueByKey(_loc9_) == null)
				{
					var _loc4_:CcComponentLoader = CcComponentLoader.getComponentLoader(_loc9_, _loc8_);
					_loc4_.addEventListener(Event.COMPLETE, this.onCcComponentLoaded);
					_loc4_.addEventListener(IOErrorEvent.IO_ERROR, this.onCcComponentFailed);
					this._regulator.addProcess(_loc4_, Event.COMPLETE);
				}
			}
		}
		
		private function onCcComponentFailed(param1:IOErrorEvent) : void
		{
			var _loc2_:CcComponentLoader = CcComponentLoader(param1.target);
			if (_loc2_)
			{
				_loc2_.removeEventListener(param1.type, this.onCcComponentFailed);
				this.addComponent(_loc2_.componentId, _loc2_.swfBytes);
			}
		}
		
		private function ioErrorHandler(param1:IOErrorEvent) : void
		{
			this.dispatchEvent(param1);
		}
		
		private function timeoutHandler(param1:Event) : void
		{
			this.dispatchEvent(param1);
		}
		
		public function clearImageData() : void
		{
			this._imageData = null;
		}
	}
}
