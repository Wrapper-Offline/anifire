package anifire.managers
{
	import mx.binding.IBindingClient;
	import flash.net.URLVariables;
	import mx.core.FlexGlobals;
	
	public class AppConfigManager implements IBindingClient
	{
		private static var __instance:anifire.managers.AppConfigManager;

		protected var _properties:Object;

		public function AppConfigManager()
		{
			super();
			this.init();
		}

		public static function get instance() : anifire.managers.AppConfigManager
		{
			if(!__instance)
			{
				__instance = new anifire.managers.AppConfigManager();
			}
			return __instance;
		}

		protected function init() : void
		{
			this._properties = {};
			this.processAppParams();
		}

		public function processAppParams() : void
		{
			var owo:Object = FlexGlobals.topLevelApplication;
			this.setParameters(owo.parameters);
		}

		public function setParameters(param1:Object) : void
		{
			var key:String = null;
			for(key in param1)
			{
				this._properties[key] = param1[key];
			}
		}

		/**
		 * gets a parameter
		 */
		public function getValue(name:String) : String
		{
			return this._properties[name];
		}

		/**
		 * sets a parameter
		 */
		public function setValue(name:String, value:String) : void
		{
			this._properties[name] = value;
		}

		public function createURLVariables() : URLVariables
		{
			var _loc2_:String = null;
			var _loc1_:URLVariables = new URLVariables();
			for(_loc2_ in this._properties)
			{
				_loc1_[_loc2_] = this._properties[_loc2_];
			}
			return _loc1_;
		}

		public function appendURLVariables(param1:URLVariables) : void
		{
			var _loc2_:String = null;
			for(_loc2_ in this._properties)
			{
				param1[_loc2_] = this._properties[_loc2_];
			}
		}
	}
}