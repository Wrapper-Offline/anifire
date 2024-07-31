package anifire.models.creator
{
	public class CCComponentModel
	{
		public var type:String;
		public var id:String;
		public var basePath:String;
		public var states:Object;
		public var runwayMode:Boolean;
		public var tags:Object;
		protected var _enable:Boolean;
		
		public function CCComponentModel(runway:Boolean = false)
		{
			super();
			this.states = {};
			this.runwayMode = runway;
			if (runway)
			{
				this.tags = {};
			}
			else
			{
				this.enable = true;
			}
		}
		
		public function get enable() : Boolean
		{
			return this._enable;
		}
		
		public function set enable(value:Boolean) : void
		{
			if (this._enable != value)
			{
				this._enable = value;
			}
		}

		/**
		 * parses a component xml
		 */
		public function parse(xml:XML) : void
		{
			this.id = xml.@id;
			this.type = xml.@type;
			this.basePath = xml.@path;
			var states:XMLList = xml.state;
			var elemCount:int = states.length();
			for (var index:int = 0; index < elemCount; index++)
			{
				var id:String = states[index].@id;
				var filename:String = states[index].@filename;
				this.states[id] = filename;
			}
			if (this.runwayMode)
			{
				var tags:XMLList = xml.tag;
				elemCount = tags.length();
				for (index = 0; index < elemCount; index++)
				{
					this.addTag(tags[index]);
				}
				this._enable = xml.@enable != "N";
			}
		}
		
		public function getFilenameByState(stateId:String) : String
		{
			return this.states[stateId];
		}
		
		public function getPathByState(stateId:String) : String
		{
			return this.pathPrefix + this.getFilenameByState(stateId);
		}
		
		public function get uniqueId() : String
		{
			return this.type + "/" + this.basePath;
		}
		
		private function get pathPrefix() : String
		{
			return this.type + "/" + this.basePath + "/";
		}
		
		public function hasTag(name:String) : Boolean
		{
			return this.tags && this.tags[name];
		}
		
		public function addTag(name:String) : void
		{
			this.tags[name] = true;
		}
		
		public function removeTag(name:String) : void
		{
			delete this.tags[name];
		}
		
		public function restore(param1:CCComponentModel) : void
		{
			this._enable = param1.enable;
			this.tags = param1.tags;
		}
		
		public function toXML() : XML
		{
			var xml:XML = <component/>;
			xml.@type = this.type;
			xml.@id = this.id;
			xml.@path = this.basePath;
			xml.@name = this.id;
			xml.@thumb = "thumbnail.swf";
			xml.@sharing = "0";
			xml.@enable = !!this.enable ? "Y": "N";
			xml.@split = "N";
			for (var iv:String in this.states)
			{
				var stateXml:XML = <state/>;
				stateXml.@id = iv;
				stateXml.@filename = iv + ".swf";
				xml.appendChild(stateXml);
			}
			for (var name:String in this.tags)
			{
				if (this.tags[name])
				{
					var tagXml:XML = <tag>{name}</tag>;
					xml.appendChild(tagXml);
				}
			}
			return xml;
		}
	}
}
