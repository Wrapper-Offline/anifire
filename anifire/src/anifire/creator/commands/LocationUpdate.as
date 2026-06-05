package anifire.creator.commands
{
	import anifire.models.creator.CCBodyComponentModel;

	public class LocationUpdate implements IHistoryCommand
	{
		public var bodyComponent:CCBodyComponentModel
		/** should the command be applied to the character */
		public var temp:Boolean;
	}
}
