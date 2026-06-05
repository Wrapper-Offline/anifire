package anifire.models.creator
{
	import anifire.constant.CcLibConstant;
	
	public class CCBodyShapeModel
	{
		protected var themeModel:CCThemeModel;
		public var bodyShapeId:String;
		public var components:Object;
		public var libraries:Object;
		public var actions:Object;
		public var defaultActionId:String;
		public var defaultMotionId:String;
		public var defaultFaceId:String;
		public var runwayMode:Boolean;
		public var defaultCharacterXML:Vector.<XML>;
		public var actionCategories:Object;
		public var componentOrder:Vector.<String>;
		
		public function CCBodyShapeModel(ccTheme:CCThemeModel)
		{
			super();
			this.themeModel = ccTheme;
			this.components = {};
			this.libraries = {};
			this.actions = {};
			if (ccTheme.runwayMode) {
				this.runwayMode = true;
				this.componentOrder = new Vector.<String>();
				this.defaultCharacterXML = new Vector.<XML>();
				this.actionCategories = {};
			}
		}
		
		public function parse(xml:XML) : void
		{
			this.bodyShapeId = xml.@id;
			this.defaultActionId = xml.@default_action + ".xml";
			this.defaultMotionId = xml.@default_motion + ".xml";
			this.defaultFaceId = xml.@facial_thumb;
			var children:XMLList = xml.children();
			var length:int = children.length();
			for (var index:int = 0; index < length; index++)
			{
				this.processNode(children[index]);
			}
		}
		
		protected function processNode(node:XML) : void
		{
			var tagName:String = node.localName() as String;
			switch (tagName)
			{
				case "actionpack":
					this.processActionPackNode(node);
					break;
				case "component":
					this.processComponentNode(node);
					break;
				case "library":
					this.processLibraryNode(node);
					break;
				case "action":
					this.createAction(node);
					break;
				case "default_char":
					if (this.runwayMode)
					{
						this.defaultCharacterXML.push(node);
					}
			}
		}
		
		protected function processComponentNode(node:XML) : void
		{
			var component:CCComponentModel = new CCComponentModel(this.runwayMode);
			component.parse(node);
			this.storeComponent(component);
		}
		
		protected function processLibraryNode(node:XML) : void
		{
			var liberalry:CCLibraryModel = new CCLibraryModel(this.runwayMode);
			liberalry.parse(node);
			this.storeLibrary(liberalry);
		}
		
		protected function processActionPackNode(node:XML) : void
		{
			var children:XMLList = node.children();
			var length:int = children.length();
			for (var index:int = 0; index < length; index++)
			{
				this.createAction(children[index], node.@enable != "N");
			}
		}
		
		private function createAction(xml:XML, param2:Boolean = true) : void
		{
			var action:CCActionModel = new CCActionModel();
			action.id = xml.@id + ".xml";
			action.name = xml.@name;
			action.isMotion = xml.@is_motion == "Y";
			action.isLoop = xml.@loop == "Y";
			action.totalframe = xml.@totalframe;
			action.category = xml.@category;
			action.enabled = param2 && xml.@enable != "N";
			if (this.runwayMode && action.category)
			{
				var _loc9_:int = this.actionCategories[action.category];
				_loc9_++;
				this.actionCategories[action.category] = _loc9_;
			}
			if ("@next" in xml)
			{
				action.nextActionId = xml.@next + ".xml";
			}
			var selections:XMLList = xml.selection;
			var length:int = selections.length();
			for (var index:int = 0; index < length; index++)
			{
				var type:String = selections[index].@type;
				if (type == "facial")
				{
					var exprId:String = selections[index].@facial_id;
					action.defaultFacialId = exprId + ".xml";
					var expression:CCFaceModel = this.themeModel.faces[exprId];
					if (expression)
					{
						var states:Object = expression.componentStates;
						for (var faceType:String in states)
						{
							action.addComponent(faceType, states[faceType]);
						}
					}
				}
				else
				{
					action.addComponent(type, selections[index].@state_id);
				}
			}
			if (xml.prop.length() > 0)
			{
				action.propXML = xml.prop;
			}
			if (CcLibConstant.CHAR_WITH_FREEACTION(this.themeModel.themeId))
			{
				action.addComponent("freeaction", xml.@id);
				var component:CCComponentModel = new CCComponentModel(this.runwayMode);
				component.id = xml.@id;
				component.type = "freeaction";
				this.storeComponent(component);
			}
			this.actions[action.id] = action;
		}

		public function getComponentsByType(type:String) : Vector.<CCComponentModel>
		{
			var components:Vector.<CCComponentModel> = new Vector.<CCComponentModel>();
			for (var index:String in this.components) {
				if (index.split(":")[0] == type)
					components.push(this.components[index]);
			}
			if (this.runwayMode) {
				var self:CCBodyShapeModel = this;
				components.sort(function (component1, component2) {
					var uid1:String = self.componentUniqueId(component1.type, component1.id);
					var uid2:String = self.componentUniqueId(component2.type, component2.id);
					return self.componentOrder.indexOf(uid1) - self.componentOrder.indexOf(uid2);
				});
			}
			return components;
		}

		public function getLibrariesByType(type:String) : Vector.<CCLibraryModel>
		{
			var libraries:Vector.<CCLibraryModel> = new Vector.<CCLibraryModel>();
			for (var index:String in this.libraries) {
				if (index.split(":")[0] == type)
					libraries.push(this.libraries[index]);
			}
			if (this.runwayMode) {
				var self:CCBodyShapeModel = this;
				libraries.sort(function (lib1, lib2) {
					var uid1:String = self.componentUniqueId(lib1.type, lib1.id);
					var uid2:String = self.componentUniqueId(lib2.type, lib2.id);
					return self.componentOrder.indexOf(uid1) - self.componentOrder.indexOf(uid2);
				});
			}
			return libraries;
		}
		
		protected function createDefaultCharacter(param1:XML) : void
		{
		}
		
		private function componentUniqueId(type:String, id:String) : String
		{
			return type + ":" + id;
		}
		
		public function storeComponent(component:CCComponentModel) : void
		{
			var uniqueId:String = this.componentUniqueId(component.type, component.id);
			this.components[uniqueId] = component;
			if (this.runwayMode) {
				this.componentOrder.push(uniqueId);
			}
		}
		
		public function getComponent(type:String, id:String) : CCComponentModel
		{
			var uniqueId:String = this.componentUniqueId(type, id);
			return this.components[uniqueId];
		}
		
		public function storeLibrary(library:CCLibraryModel) : void
		{
			var uniqueId:String = this.componentUniqueId(library.type, library.id);
			this.libraries[uniqueId] = library;
			if (this.runwayMode) {
				this.componentOrder.push(uniqueId);
			}
		}
		
		public function getLibrary(type:String, id:String) : CCLibraryModel
		{
			var _loc3_:String = this.componentUniqueId(type, id);
			return this.libraries[_loc3_];
		}
		
		public function toString() : String
		{
			return this.bodyShapeId;
		}
	}
}
