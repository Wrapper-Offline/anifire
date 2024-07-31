package anifire.models.creator
{
	import anifire.constant.CcLibConstant;
	import anifire.constant.ServerConstants;
	import anifire.managers.AppConfigManager;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	public class CCBodyModel extends EventDispatcher
	{
		/**
		 * List of either `CCBodyComponentModel`s or
		 * `Vector.\<CCBodyComponentModel\>`s, depending on whether
		 * or not the component supports selection of multiple of
		 * its own type, index by their type.
		 */
		public var components:Object;

		/**
		 * List of library IDs indexed by their type.
		 */
		public var libraries:Object;

		/**
		 * List of `CCColor`s indexed by their type.
		 */
		public var colors:Object;

		/**
		 * Object containing the `scalex` and `scaley` values
		 * for the custom character's body shape.
		 */
		public var bodyScale:Object;

		/**
		 * Object containing the `scalex` and `scaley` values
		 * for the custom character's head.
		 */
		public var headScale:Object;

		/**
		 * Object containing the `dx` and `dx` values for the
		 * custom character's head.
		 */
		public var headPos:Object;

		/**
		 * Boolean indicating whether or not CC body XML parsing
		 * has completed.
		 */
		public var completed:Boolean = false;

		/**
		 * The custom character body's asset ID.
		 */
		public var assetId:String;

		/**
		 * Number specifying the custom character version, with
		 * `1` belonging to a skeletal CC theme and `2` belonging
		 * to a freeaction CC theme.
		 */
		public var version:Number;

		/**
		 * The ID of the bodyshape used for the custom character.
		 */
		public var bodyShapeId:String;

		/**
		 * The custom character's theme ID.
		 */
		public var themeId:String;

		/**
		 * The original, unmodified CC body XML that was
		 * passed to this class.
		 */
		public var source:XML;

		/**
		 * The `URLLoader` used to request a CC body XML
		 * from the server.
		 */
		protected var loader:URLLoader;

		/**
		 * Custom character body XML model.
		 * @param id ID of the custom character.
		 */
		public function CCBodyModel(id:String)
		{
			super();
			this.assetId = id;
			this.components = {};
			this.libraries = {};
			this.colors = {};
			this.bodyScale = {};
			this.headScale = {};
			this.headPos = {};
			this.version = 1;
		}

		/**
		 * Requests a CC body XML from the server.
		 */
		public function load() : void
		{
			if (!this.loader)
			{
				var req:URLRequest = new URLRequest(ServerConstants.ACTION_GET_CC_CHAR_COMPOSITION_XML);
				req.method = URLRequestMethod.POST;
				var vars:URLVariables = AppConfigManager.instance.createURLVariables();
				vars["assetId"] = this.assetId;
				req.data = vars;
				if (this.assetId && this.assetId != "")
				{
					this.loader = new URLLoader();
					this.loader.addEventListener(Event.COMPLETE, this.onLoaderComplete);
					this.loader.addEventListener(IOErrorEvent.IO_ERROR, this.onLoaderError);
					this.loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onLoaderError);
					this.loader.load(req);
				}
			}
		}

		/**
		 * CC body XML request was successful.
		 */
		protected function onLoaderComplete(e:Event) : void
		{
			this.loader.removeEventListener(Event.COMPLETE, this.onLoaderComplete);
			var responseText:String = this.loader.data;
			this.loader = null;
			if (responseText.charAt(0) == "0")
			{
				this.parse(XML(responseText.substr(1)));
			}
			else
			{
				this.dispatchError();
			}
		}

		/**
		 * CC body XML request failed.
		 */
		protected function onLoaderError(e:Event) : void
		{
			this.dispatchError();
		}
		protected function dispatchError() : void
		{
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
		}

		/**
		 * Parses a CC body XML.
		 * @param charXml CC body XML to parse.
		 */
		public function parse(charXml:XML) : void
		{
			var index:int;
			var elements:XMLList = charXml.component;
			var length:int = elements.length();
			for (index = 0; index < length; index++)
			{
				var component:CCBodyComponentModel = new CCBodyComponentModel();
				component.parse(elements[index]);
				if (component.type == "bodyshape")
				{
					this.bodyShapeId = component.component_id;
					this.themeId = component.theme_id;
				}
				
				if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(component.type) > -1)
				{
					var cmpntArray:Vector.<CCBodyComponentModel>;
					if (!this.components[component.type])
					{
						cmpntArray = this.components[component.type] = new Vector.<CCBodyComponentModel>();
					}
					else
					{
						cmpntArray = this.components[component.type];
					}
					cmpntArray.push(component);
				}
				else
				{
					this.components[component.type] = component;
				}
			}
			elements = charXml.library;
			length = elements.length();
			for (index = 0; index < length; index++)
			{
				var type:String = elements[index].@type;
				var iv:String = elements[index].@component_id;
				this.libraries[type] = iv;
			}
			elements = charXml.color;
			length = elements.length();
			for (index = 0; index < length; index++)
			{
				var color:CCColor = new CCColor();
				color.parse(elements[index]);
				if (color.targetComponent)
				{
					this.colors[color.type + color.targetComponent] = color;
				}
				else
				{
					this.colors[color.type] = color;
				}
			}
			this.bodyScale.scalex = Number(charXml.@xscale);
			this.bodyScale.scaley = Number(charXml.@yscale);
			this.headScale.scalex = Number(charXml.@hxscale);
			this.headScale.scaley = Number(charXml.@hyscale);
			this.headPos.dx = Number(charXml.@headdx);
			this.headPos.dy = Number(charXml.@headdy);
			this.version = Number(charXml.@version);
			this.source = charXml;
			this.completed = true;
			dispatchEvent(new Event(Event.COMPLETE));
		}

		/**
		 * Returns a `CCColor` for the specified type.
		 * @param type Type of color to return.
		 */
		public function getColor(type:String) : CCColor
		{
			return this.colors[type];
		}

		/**
		 * Returns a `CCBodyComponentModel` of the specified type,
		 * or a `Vector.\<CCBodyComponentModel\>` if multiple
		 * components of that type are allowed to be selected.
		 * @param type Component type to return.
		 */
		public function getComponentId(type:String) : Object
		{
			return this.components[type];
		}

		/**
		 * Returns a library ID of the specified type.
		 * @param type Type of library to return the ID for.
		 */
		public function getLibraryId(type:String) : String
		{
			return this.libraries[type];
		}
	}
}
