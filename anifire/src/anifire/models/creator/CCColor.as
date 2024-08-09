package anifire.models.creator
{
	public class CCColor
	{
		public var type:String;
		public var dest:uint;
		public var oc:uint = 4.294967295E9;
		public var targetComponent:String = "";
		public var choices:Vector.<String>;

		public function CCColor()
		{
			super();
		}

		public function parse(xml:XML) : void
		{
			this.type = xml.@r;
			this.dest = uint(xml);
			this.oc = xml.attribute("oc").length() == 0 ? uint.MAX_VALUE : uint(xml.@oc);
			this.choices = new Vector.<String>;
			var choices:XMLList = xml.choice;
			for each (var choice in choices)
			{
				this.choices.push(choice)
			}
			if (xml.attribute("targetComponent").length() != 0)
			{
				this.targetComponent = xml.@targetComponent;
			}
		}

		public function serialize() : XML
		{
			var xml:XML = <color>{this.dest.toString()}</color>;
			xml.@r = this.type;
			if(this.oc != uint.MAX_VALUE)
			{
				xml.@oc = this.oc.toString();
			}
			if(this.targetComponent)
			{
				xml.@targetComponent = this.targetComponent;
			}
			return xml;
		}

		public function deserialize(xml:XML) : void
		{
			this.parse(xml);
		}
	}
}
