package anifire.creator.config
{
   import anifire.constant.ServerConstants;
   import anifire.constant.ThemeConstants;
   import anifire.creator.interfaces.IConfiguration;
   import anifire.models.creator.CCComponentModel;
   import anifire.creator.utils.ComponentThumbFilter;
   import anifire.managers.AppConfigManager;
   import anifire.util.UtilUser;
   
   public class GoAnimate implements IConfiguration
   {
      
      private static var _configManager:AppConfigManager = AppConfigManager.instance;
       
      
      public function GoAnimate()
      {
         super();
      }
      
      private static function goTagFilter(thumb:CCComponentModel) : Boolean
      {
         if (!thumb) {
            return false;
         }
         var userRank:int = parseInt(_configManager.getValue("ut"));
         var filter:String = _configManager.getValue("ft");
         return (userRank >= 60 || !thumb.hasTag("_userrole_admin")) && (!filter || thumb.hasTag(filter));
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
      
      public function get defaultThumbFilter() : ComponentThumbFilter
      {
         var _loc1_:ComponentThumbFilter = new ComponentThumbFilter();
         _loc1_.filter = goTagFilter;
         return _loc1_;
      }
   }
}
