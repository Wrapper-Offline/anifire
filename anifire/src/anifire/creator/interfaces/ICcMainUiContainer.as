package anifire.creator.interfaces
{
	import anifire.creator.components.EditView;
	import flash.events.IEventDispatcher;

	public interface ICcMainUiContainer extends IEventDispatcher
	{
		function get mui_editView() : EditView;
	}
}
