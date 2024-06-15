package anifire.util
{
	import anifire.constant.ServerConstants;
	import anifire.managers.AppConfigManager;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	public class UtilGettext
	{
		
		// {"browser|en_US": ...}
		private static var resources:Object = {};
		
		private static var slocale:String;

		private static var ref:Object = {};
		
		
		public function UtilGettext()
		{
			super();
		}
		
		public static function initAggregate(domain:String, themeCode:String, locale:String, callback:Function) : void
		{
			var po:String = null;
			init([domain], themeCode, locale, callback);
			for each (po in ServerConstants.getPOList(domain))
			{
				ref[po] = domain;
			}
		}
		
		public static function init(domains:Array, themeCode:String, locale:String, callback:Function) : void
		{
			slocale = locale;

			var needsLoad:Boolean = false;
			var _configManager:AppConfigManager = AppConfigManager.instance;

			var configPath:String = _configManager.getValue(ServerConstants.FLASHVAR_CLIENT_THEME_PATH) as String;
			var match:RegExp = new RegExp(ServerConstants.FLASHVAR_CLIENT_THEME_PLACEHOLDER, "g");

			var domain:String = null;
			for each (domain in domains)
			{
				(function () : void
				{
					var _domain:* = undefined;
					var gt:* = undefined;
					var gt2:* = undefined;
					_domain = domain;
					if (resources[[domain, locale].join("|")] == null)
					{
						needsLoad = true;
						gt = new GetText();
						gt.addEventListener(Event.COMPLETE, function (param1:Event) : void
						{
							var e:Event = param1;
							resources[[_domain, locale].join("|")] = gt;
							if (
								domains.every(
									function (param1:*, param2:int, param3:Array) : Boolean
									{
										return resources[[String(param1), locale].join("|")] != null;
									}
								)
							)
							{
								callback();
							}
						});
						gt.addEventListener(IOErrorEvent.IO_ERROR,function(param1:Event):void
						{
							callback();
						});
						gt.translation(domain, configPath + "/static/client_theme/locale/" + themeCode + "/", locale);
						gt.install();
						if (locale != "en_US")
						{
							gt2 = new GetText();
							gt2.addEventListener(Event.COMPLETE,function(param1:Event):void
							{
								resources[[_domain, "en_US"].join("|")] = gt2;
							});
							const replace2:String = "locale/" + locale + "/" + domain + ".mo";
							gt2.translation(domain, configPath + "/static/client_theme/locale/" + themeCode + "/", locale);
							gt2.install();
						}
					}
				})();
			}
			if(!needsLoad)
			{
				callback();
			}
		}
		
		public static function translateAggregate(param1:String, param2:String) : String
		{
			return translate(ref[param1],[param1,param2].join("|"));
		}
		
		public static function translate(domain:String, param2:String) : String
		{
			var _loc6_:GetText = null;
			var _loc3_:GetText = resources[[domain,slocale].join("|")];
			var _loc4_:GetText = null;
			var _loc5_:String = null;
			if(param2 == null || param2 == "")
			{
				return "";
			}
			if(slocale != "en_US")
			{
				_loc4_ = resources[[domain,"en_US"].join("|")];
			}
			for each(_loc6_ in [_loc3_, _loc4_])
			{
				try
				{
					if(_loc6_ != null)
					{
						_loc5_ = _loc6_.translate(param2,true);
						break;
					}
				}
				catch(ex:TypeError)
				{
					continue;
				}
			}
			return _loc5_;
		}
	}
}
