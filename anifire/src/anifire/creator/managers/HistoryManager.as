package anifire.creator.managers
{
	import flash.events.EventDispatcher;
	import anifire.creator.commands.IHistoryCommand;
	import anifire.creator.events.HistoryManagerEvent;

	/**
	 * this class manages the edit history. commands (along with their
	 * inverses) are sent here by the ui, and this class stores them and
	 * dispatches them back to the character preview. this class also
	 * listens for the `undo` and `redo` callbacks via ExternalInterface,
	 * and applies the inverse or the command respectively.
	 */
	public class HistoryManager extends EventDispatcher
	{
		private static var _instance:HistoryManager;
		private var _commands:Vector.<IHistoryCommand>;
		private var _inverses:Vector.<IHistoryCommand>;
		private var _index:int;

		public function HistoryManager() : void
		{
			this._commands = new Vector.<IHistoryCommand>();
			this._inverses = new Vector.<IHistoryCommand>();
			this._index = -1;
		}

		public static function get instance() : HistoryManager
		{
			if (_instance == null) {
				_instance = new HistoryManager();
			}
			return _instance;
		}

		/**
		 * pushes a command to the timeline
		 * @param command what should be done to the character
		 * @param command inverse of what to do with char
		 */
		public function push(command:IHistoryCommand, inverseCommand:IHistoryCommand) : void
		{
			this.dispatch(command);
			if (this._index < this._commands.length - 1) {
				this._commands = this._commands.slice(0, this._index + 1);
				this._inverses = this._inverses.slice(0, this._index + 1);
			}
			this._commands.push(command);
			this._inverses.push(inverseCommand);
			this._index++;
		}

		/**
		 * "sends off" a command. this will apply a command without storing
		 * it. this is useful for temporary events, like the user dragging
		 * through the color picker.
		 * @param command command to apply
		 */
		public function sendOff(command:IHistoryCommand) : void
		{
			this.dispatch(command);
		}

		/**
		 * steps forward in the timeline and applies the inverse of the current command
		 */
		public function undo() : void
		{
			if (this._index == -1) {
				return;
			}
			var inverse:IHistoryCommand = this._inverses[this._index];
			this.dispatch(inverse, true);
			this._index--;
		}

		/**
		 * steps forward in the timeline and applies the next command
		 */
		public function redo() : void
		{
			if (this._index == this._commands.length - 1) {
				return;
			}
			this._index++;
			var command:IHistoryCommand = this._commands[this._index];
			this.dispatch(command, true);
		}

		/**
		 * dispatches a history update event
		 * @param command command to apply
		 * @param updateCaret whether the ui should be updated
		 */
		private function dispatch(command:IHistoryCommand, updateCaret = false) : void
		{
			var event:HistoryManagerEvent = new HistoryManagerEvent(HistoryManagerEvent.UPDATE, this);
			event.command = command;
			event.updateCaret = updateCaret;
			this.dispatchEvent(event);
		}
	}
}
