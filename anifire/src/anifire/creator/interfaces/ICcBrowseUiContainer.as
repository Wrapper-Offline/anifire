package anifire.creator.interfaces
{
	import flash.events.IEventDispatcher;
	import spark.components.Button;
	import spark.effects.Resize;
	import anifire.creator.components.browser.CharListPanel;
	import anifire.creator.components.browser.CharacterInfoColumn;
	
	public interface ICcBrowseUiContainer extends IEventDispatcher
	{
		function get bui_charInfoCol() : CharacterInfoColumn;
		function get bui_stockChars() : CharListPanel;
		function get bui_customChars() : CharListPanel;
		function get bui_panelHeightDragger() : Button;
		function get btr_infoBlockIn() : Resize;
		function get btr_infoBlockOut() : Resize;
	}
}