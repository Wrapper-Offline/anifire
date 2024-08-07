package anifire.models.creator
{
	public class CCBodyComponentModel
	{
		public var type:String;
		public var component_id:String;
		public var theme_id:String;

		/**
		 * Where the component is located on the x axis, in pixels,
		 * relative to their default position.
		 */
		public var x:Number;

		/**
		 * Where the component is located on the y axis, in pixels,
		 * relative to their default position.
		 */
		public var y:Number;

		public var xscale:Number;
		public var yscale:Number;

		/**
		 * How far apart the sides of a split component are,
		 * in pixels, relative to their default position.
		 */
		public var offset:Number;

		/**
		 * How many degrees a component should be rotated, ranging
		 * from -180 to 180.
		 */
		public var rotation:Number;

		/**
		 * TODO: see what this does
		 */
		public var split:Boolean = true;

		/**
		 * TODO: see what this does
		 * it has the same value as the component id
		 */
		public var folder:String;

		/**
		 * The ID of the body component.
		 */
		public var id:String;

		/**
		 * Represents a component from a custom character body.
		 */
		public function CCBodyComponentModel()
		{
			super();
		}

		/**
		 * Parses a component node from a CC body XML.
		 * @param bodyCmpntXml Body component node to parse.
		 */
		public function parse(bodyCmpntXml:XML) : void
		{
			this.type = bodyCmpntXml.@type;
			this.component_id = this.folder = bodyCmpntXml.@component_id;
			this.theme_id = bodyCmpntXml.@theme_id;
			this.x = bodyCmpntXml.@x;
			this.y = bodyCmpntXml.@y;
			this.xscale = bodyCmpntXml.@xscale;
			this.yscale = bodyCmpntXml.@yscale;
			this.offset = bodyCmpntXml.@offset;
			this.rotation = bodyCmpntXml.@rotation;
			if (bodyCmpntXml.hasOwnProperty("@split") && String(bodyCmpntXml.@split) == "N")
			{
				this.split = false;
			}
			if (bodyCmpntXml.hasOwnProperty("@id"))
			{
				this.id = bodyCmpntXml.@id;
			}
		}

		/**
		 * Initializes a set of default properties for the body component.
		 */
		public function initDefaultValues() : void
		{
			this.x = 0;
			this.y = 0;
			this.xscale = 1;
			this.yscale = 1;
			this.offset = 0;
			this.rotation = 0;
			this.split = false;
		}

		/**
		 * Generates a body component XML node
		 * from the model and returns it.
		 */
		public function serialize() : XML
		{
			var bodyCmpntXml:XML = <component/>;
			bodyCmpntXml.@type = this.type;
			bodyCmpntXml.@component_id = this.component_id;
			bodyCmpntXml.@theme_id = this.theme_id;
			bodyCmpntXml.@x = this.x;
			bodyCmpntXml.@y = this.y;
			bodyCmpntXml.@xscale = this.xscale;
			bodyCmpntXml.@yscale = this.yscale;
			bodyCmpntXml.@offset = this.offset;
			bodyCmpntXml.@rotation = this.rotation;
			if (!this.split)
			{
				bodyCmpntXml.@split = "N";
			}
			if (this.id)
			{
				bodyCmpntXml.@id = this.id;
			}
			return bodyCmpntXml;
		}

		/**
		 * Deprecated. Refer to the `parse` method instead.
		 */
		public function deserialize(SWITCHNOW:XML) : void
		{
			this.parse(SWITCHNOW);
		}
	}
}
