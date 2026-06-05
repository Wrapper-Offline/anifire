package anifire.creator.managers
{
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import anifire.creator.events.CommandBarEvent;

	/**
	 * this class keeps the HTML command bar in sync with the Flash component
	 * panel and character preview.
	 */
	public class CommandBarManager extends EventDispatcher
	{
		private static var UNDO_FUNC:String = "undo";
		private static var REDO_FUNC:String = "redo";
		private static var PREVIEW_FLIP_FUNC:String = "previewFlip";
		private static var PREVIEW_ZOOM_FUNC:String = "previewZoom";
		private static var _instance:CommandBarManager;

		public function CommandBarManager() : void
		{
			this.listen();
		}

		public static function get instance() : CommandBarManager
		{
			if (_instance == null) {
				_instance = new CommandBarManager();
			}
			return _instance;
		}

		/**
		 * listens for the callbacks that are triggered by the user
		 * pressing the command bar options
		 */
		private function listen() : void
		{
			if (ExternalInterface.available) {
				ExternalInterface.addCallback(UNDO_FUNC, HistoryManager.instance.undo);
				ExternalInterface.addCallback(REDO_FUNC, HistoryManager.instance.redo);
				ExternalInterface.addCallback(PREVIEW_FLIP_FUNC, this.flip);
			}
		}

		private function flip() : void
		{
			this.dispatchEvent(new CommandBarEvent(CommandBarEvent.PREVIEW_FLIP, this));
		}
	}
}
