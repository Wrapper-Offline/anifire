package anifire.creator.config
{
	import anifire.constant.ServerConstants;
	import anifire.constant.ThemeConstants;
	import anifire.models.creator.CCComponentModel;
	import anifire.models.creator.CCLibraryModel;
	import anifire.managers.AppConfigManager;
	import anifire.util.UtilUser;
	
	public class GoAnimate
	{
		private static var _configManager:AppConfigManager = AppConfigManager.instance;
	
		public function GoAnimate()
		{
			super();
		}

		/**
		 * @param thumb CCComponentModel|CCLibraryModel
		 */
		public function goTagFilter(thumb:*) : Boolean
		{
			if (!thumb) {
				return false;
			}
			if (!(thumb is CCComponentModel) && !(thumb is CCLibraryModel)) {
				return false;
			}
			var userRank:int = parseInt(_configManager.getValue("ut"));
			var filter:String = _configManager.getValue("ft");
			return (!thumb.hasTag("_userrole_admin") || userRank >= 60) && (!filter || thumb.hasTag(filter));
		}
		
		public function scalingCharacterEnabled() : Boolean
		{
			if(_configManager.getValue(ServerConstants.PARAM_THEME_ID) == ThemeConstants.ANIME_THEME_ID)
			{
				if(UtilUser.hasAdminFeatures)
				{
					return true;
				}
				return false;
			}
			return true;
		}
		
		public function templateSelectorEnabled() : Boolean
		{
			return false;
		}
		
		public function loadPreMadeCharsEnabled() : Boolean
		{
			return true;
		}
	}
}
