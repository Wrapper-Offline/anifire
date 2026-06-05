package anifire.creator.commands
{
	import anifire.models.creator.CCBodyComponentModel;

	public class ComponentAdd implements IHistoryCommand
	{
		public var bodyComponent:CCBodyComponentModel;
		public var index:int = -1;
	}
}
