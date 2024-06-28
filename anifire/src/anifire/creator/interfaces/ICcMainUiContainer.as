package anifire.creator.interfaces
{
	import flash.events.IEventDispatcher;
	import spark.components.Group;

	public interface ICcMainUiContainer extends IEventDispatcher
	{
		function get mui_browseView() : BrowseView;
		function get mui_editView() : EditView;
	}
}
