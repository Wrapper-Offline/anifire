package anifire.managers
{
	import anifire.models.creator.CCThemeModel;
	
	public class CCThemeManager
	{
		private static var _instance:CCThemeManager;
		private var _models:Object;

		/**
		 * Keeps track of all the CC themes.
		 */
		public function CCThemeManager()
		{
			super();
			this._models = {};
		}
		
		public static function get instance() : CCThemeManager
		{
			if (_instance == null)
			{
				_instance = new CCThemeManager();
			}
			return _instance;
		}

		/**
		 * Returns a CCThemeModel. Creates one if it doesn't exist.
		 */
		public function getThemeModel(id:String) : CCThemeModel
		{
			var ccThemeModel:CCThemeModel = this._models[id];
			if (!ccThemeModel)
			{
				ccThemeModel = new CCThemeModel(id);
				this._models[id] = ccThemeModel;
			}
			return ccThemeModel;
		}
	}
}
