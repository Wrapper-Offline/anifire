package anifire.models.creator
{
	public class CCFaceModel
	{
		public var id:String;
		public var name:String;
		public var enable:Boolean;
		public var componentStates:Object;
		
		public function CCFaceModel()
		{
			super();
			this.componentStates = {};
		}

		public function parse(xml:XML) : void
		{
			this.id = xml.@id;
			this.name = xml.@name;
			this.enable = xml.@enable == "N" ? false : true;
			var selections:XMLList = xml.selection;
			var length:int = selections.length();
			for (var index:int = 0; index < length; index++)
			{
				var type:String = selections[index].@type;
				var stateId:String = selections[index].@state_id;
				this.componentStates[type] = stateId;
			}
		}

		public function getStateByComponent(type:String) : String
		{
			return this.componentStates[type];
		}

		public function get fullId() : String
		{
			return this.id + ".xml";
		}
	}
}
