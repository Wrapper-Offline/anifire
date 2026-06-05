package anifire.creator.commands
{
	public class ColorUpdate implements IHistoryCommand
	{
		/** color type */
		public var type:String;
		public var targetComponent:String;
		public var value:uint;
		/** should the command be applied to the character */
		public var temp:Boolean;
	}
}
