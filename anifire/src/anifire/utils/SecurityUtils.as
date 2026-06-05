package anifire.utils
{
	import flash.system.Security;
	
	public class SecurityUtils
	{
		 
		
		public function SecurityUtils()
		{
			super();
		}
		
		public static function init() : void
		{
			Security.allowDomain("127.0.0.1", "localhost");
		}
	}
}
