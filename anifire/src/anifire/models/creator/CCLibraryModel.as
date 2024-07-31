package anifire.models.creator
{
	public class CCLibraryModel
	{
		public var type:String;
		public var id:String;
		public var basePath:String;
		protected var _enable:Boolean;
		public var tags:Object;
		public var bodyShapes:Object;
		public var runwayMode:Boolean;
		public var localChanged:Boolean;
		protected var _localDisplayOrder:Number;

		public function CCLibraryModel(runway:Boolean = false)
		{
			super();
			this.runwayMode = runway;
			this._enable = true;
			if (runway)
			{
				this.tags = {};
				this.bodyShapes = {};
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
				this.localChanged = true;
			}
		}

		public function get localDisplayOrder() : Number
		{
			return this._localDisplayOrder;
		}

		public function set localDisplayOrder(value:Number) : void
		{
			if (this._localDisplayOrder != value)
			{
				this._localDisplayOrder = value;
				this.localChanged = true;
			}
		}

		public function parse(xml:XML) : void
		{
			this.id = xml.@id;
			this.type = xml.@type;
			this.basePath = xml.@path;
			if (this.runwayMode)
			{
				var tags:XMLList = xml.tag;
				var length:int = tags.length();
				for (var index:int = 0; index < length; index++)
				{
					this.tags[tags[index]] = true;
				}
				this._enable = xml.@enable != "N";
			}
			if (xml.hasOwnProperty("@display_order"))
			{
				this._localDisplayOrder = xml.@display_order;
			}
			else
			{
				this._localDisplayOrder = 0;
			}
		}

		public function restore(library:CCLibraryModel) : void
		{
			this._enable = library.enable;
			this.tags = library.tags;
			this.bodyShapes = library.bodyShapes;
			this._localDisplayOrder = library.localDisplayOrder;
			this.localChanged = true;
		}

		public function get uniqueId() : String
		{
			return this.type + "/" + this.basePath;
		}

		public function getFilename() : String
		{
			return this.basePath + ".swf";
		}

		public function getPath() : String
		{
			return this.pathPrefix + this.getFilename();
		}

		private function get pathPrefix() : String
		{
			return this.type + "/";
		}

		public function hasTag(name:String) : Boolean
		{
			return this.tags && this.tags[name];
		}

		public function addTag(name:String) : void
		{
			this.tags[name] = true;
			this.localChanged = true;
		}

		public function removeTag(name:String) : void
		{
			delete this.tags[name];
			this.localChanged = true;
		}

		protected function shouldIncludeTag(bs:String, tagName:String) : Boolean
		{
			switch (tagName)
			{
				case "_sticky_filter_guy":
				case "_sticky_filter_girl":
					return bs == "default";
				case "_sticky_filter_littleboy":
				case "_sticky_filter_littlegirl":
					return bs == "kid";
				case "_sticky_filter_heavyguy":
				case "_sticky_filter_heavygirl":
					return bs == "heavy";
				case "_userrole_admin":
					return true;
				default:
					return false;
			}
		}

		public function getLocalXMLByBodyShape(bs:String) : XML
		{
			var xml:XML = <library/>;
			xml.@type = this.type;
			xml.@id = this.id;
			xml.@path = this.basePath;
			xml.@name = this.id;
			xml.@thumb = this.basePath + "_thumbnail.swf";
			if (this._localDisplayOrder > 0)
			{
				xml.@display_order = this._localDisplayOrder;
			}
			xml.@enable = !!this.enable ? "Y" : "N";
			xml.@sharing = "0";
			for (var tagName:String in this.tags)
			{
				if (this.tags[tagName] && this.shouldIncludeTag(bs, tagName))
				{
					var tagXml:XML = <tag>{tagName}</tag>;
					xml.appendChild(tagXml);
				}
			}
			return xml;
		}

		public function hasLocalBodyShape(id:String) : Boolean
		{
			return this.bodyShapes[id];
		}

		public function addLocalBodyShape(id:String) : void
		{
			this.bodyShapes[id] = true;
			this.localChanged = true;
		}

		public function removeLocalBodyShape(id:String) : void
		{
			delete this.bodyShapes[id];
			this.localChanged = true;
		}
	}
}
