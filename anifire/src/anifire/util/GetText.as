package anifire.util
{
	import anifire.constant.ServerConstants;
	import anifire.managers.AppConfigManager;
	import com.adobe.webapis.gettext.GetText;
	import flash.net.URLRequest;
	
	public class GetText extends com.adobe.webapis.gettext.GetText
	{
		
		
		public function GetText()
		{
			super();
		}
		
		override protected function composeURLRequest() : URLRequest
		{
			var configManager:AppConfigManager = AppConfigManager.instance;
			var configPath:String = configManager.getValue(ServerConstants.FLASHVAR_CLIENT_THEME_PATH) as String;
			var _loc3_:String = null;
			if(_loc3_ == null)
			{
				_loc3_ = "go";
			}
			var match:RegExp = new RegExp(ServerConstants.FLASHVAR_CLIENT_THEME_PLACEHOLDER, "g");
			var replace:String = "client_theme/locale/" + _loc3_ + "/" + this.getLocale() + "/" + this.getName() + ".mo";
			configPath = configPath.replace(match, replace);
			return new URLRequest(configPath);
		}
	}
}
