package anifire.creator.interfaces
{
	import flash.events.IEventDispatcher;
	import anifire.creator.components.CharPreview;
	import anifire.creator.components.ComponentPanel;

	public interface ICharacterCreator extends IEventDispatcher
	{
		function get cv_charPreview() : CharPreview;
		function get cv_componentPanel() : ComponentPanel;
	}
}
