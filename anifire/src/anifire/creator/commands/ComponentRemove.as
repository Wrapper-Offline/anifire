package anifire.creator.commands
{
	public class ComponentRemove implements IHistoryCommand
	{
		public var type:String;
		/** id of component on the character body, NOT to be confused with the component id */
		public var id:String;
	}
}
