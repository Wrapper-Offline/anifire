package anifire.models.creator
{
	import anifire.constant.CcLibConstant;
	import anifire.util.UtilNetwork;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	
	public class CCThemeModel extends EventDispatcher
	{
		/**
		 * i have no idea what this does
		 */
		public var runwayMode:Boolean;
		public var themeId:String;
		public var defaultBodyShape:CCBodyShapeModel;
		public var bodyShapes:Object;
		public var components:Object;
		public var version:int;
		// they faces
		public var faces:Object;
		public var colors:Object;
		public var completed:Boolean = false;
		protected var loader:URLLoader;
		private var _actionModels:Object;
		
		public function CCThemeModel(themeId:String)
		{
			super();
			this.themeId = themeId;
			this.bodyShapes = {};
			this.faces = {};
			this.components = {};
			this._actionModels = {};
		}

		/**
		 * Retrieves a theme XML from the store.
		 */
		public function load() : void
		{
			if (!this.loader)
			{
				this.loader = new URLLoader();
				this.loader.addEventListener(Event.COMPLETE, this.onLoaderComplete);
				this.loader.load(UtilNetwork.getGetCcThemeRequest(this.themeId));
			}
		}
		
		protected function onLoaderComplete(event:Event) : void
		{
			this.loader.removeEventListener(Event.COMPLETE, this.onLoaderComplete);
			this.parse(XML(this.loader.data));
		}

		/**
		 * loops through all the cc theme xml nodes
		 */
		public function parse(ccThemeXml:XML) : void
		{
			var nodes:XMLList = ccThemeXml.children();
			var totalNodes:int = nodes.length();
			if (this.runwayMode)
			{
				this.colors = {};
				if (ccThemeXml.@version)
				{
					this.version = int(ccThemeXml.@version);
				}
				else
				{
					this.version = 1;
				}
			}
			for (var index:int = 0; index < totalNodes; index++)
			{
				var node:XML = nodes[index];
				var tagName:String = node.localName() as String;
				switch (tagName)
				{
					case "color":
						if (this.runwayMode)
						{
							var color:CCColor = new CCColor();
							color.parse(node);
							if (node.@component_type)
								color.targetComponent = node.@component_type;
							this.colors[color.type] = color;
						}
						break;
					case "facial":
						var facialExpression:CCFaceModel = new CCFaceModel();
						facialExpression.parse(node);
						this.faces[facialExpression.id] = facialExpression;
						break;
					case "bodyshape":
						var bodyshape:CCBodyShapeModel = new CCBodyShapeModel(this);
						bodyshape.parse(node);
						if (!this.defaultBodyShape)
						{
							this.defaultBodyShape = bodyshape;
						}
						this.bodyShapes[bodyshape.bodyShapeId] = bodyshape;
						break;
					case "component":
						var component:CCComponentModel = new CCComponentModel(this.runwayMode);
						component.parse(node);
						this.storeSharedComponent(component);
				}
			}
			this.completed = true;
			dispatchEvent(new Event(Event.COMPLETE));
		}

		/**
		 * Returns an object containing a bodyshape's actions
		 * indexed by their ID.
		 */
		public function getActions(bodyShapeId:String) : Object
		{
			var bodyshape:CCBodyShapeModel = this.bodyShapes[bodyShapeId];
			if (bodyshape)
			{
				return bodyshape.actions;
			}
			return null;
		}

		/**
		 * generates a unique component id from its type and original id
		 */
		protected function componentUniqueId(componentType:String, componentId:String) : String
		{
			return componentType + ":" + componentId;
		}

		/**
		 * adds a shared component (available to all bodyshapes)
		 */
		protected function storeSharedComponent(component:CCComponentModel) : void
		{
			var uniqueId:String = this.componentUniqueId(component.type, component.id);
			this.components[uniqueId] = component;
		}

		/**
		 * returns a shared component (available to all bodyshapes) from its id
		 */
		protected function getSharedComponent(type:String, id:String) : CCComponentModel
		{
			var uniqueId:String = this.componentUniqueId(type, id);
			return this.components[uniqueId];
		}

		/**
		 * returns a specified component from a bodyshape. if it fails,
		 * it returns a shared component from the theme (if it exists)
		 */
		protected function getComponent(bodyShape:CCBodyShapeModel, type:String, id:String) : CCComponentModel
		{
			var component:CCComponentModel = bodyShape.getComponent(type, id);
			if (!component)
			{
				component = this.getSharedComponent(type, id);
			}
			return component;
		}

		public function getComponentsByType(type:String) : Vector.<CCComponentModel>
		{
			var components:Vector.<CCComponentModel> = new Vector.<CCComponentModel>();
			for (var index:String in this.components)
			{
				if (index.split(":")[0] == type)
					components.push(this.components[index]);
			}
			return components;
		}

		public function createCharacterActionModel(char:CCBodyModel, action:CCActionModel) : CCCharacterActionModel
		{
			if (!this.runwayMode)
			{
				var charActions:Object = this._actionModels[char.assetId];
				if (charActions)
				{
					var existing:CCCharacterActionModel = charActions[shortId];
					if (existing)
					{
						return existing;
					}
				}
			}
			var bodyshape:CCBodyShapeModel = this.bodyShapes[char.bodyShapeId];
			if (!bodyshape)
			{
				return null;
			}
			var cam:CCCharacterActionModel = new CCCharacterActionModel();
			cam.actionModel = action;
			cam.enabled = action.enabled;
			var shortId:String = action.shortId;
			var states:Object = action.componentStates;
			var bodyCmpnt:CCBodyComponentModel;
			var id:String;
			var component:CCComponentModel;
			for (var type:String in states)
			{
				if (type == "freeaction")
				{
					var faCmpnt:CCComponentModel = this.getComponent(bodyshape, "freeaction", shortId);
					if (faCmpnt)
					{
						bodyCmpnt = char.getComponentId("freeaction") as CCBodyComponentModel;
						cam.addComponent(bodyCmpnt, shortId + ".swf", this.themeId + "/freeaction/" + bodyCmpnt.folder + "/" + shortId + ".swf");
						cam.freeactionFolderName = bodyCmpnt.folder;
					}
				}
				else if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(type) > -1)
				{
					var components:Object = char.getComponentId(type);
					for (var index:String in components)
					{
						bodyCmpnt = components[index] as CCBodyComponentModel;
						if (bodyCmpnt)
						{
							id = bodyCmpnt.component_id;
							component = this.getComponent(bodyshape, type, id);
							if (component)
							{
								cam.addComponent(bodyCmpnt, component.getFilenameByState(states[type]), this.themeId + "/" + component.getPathByState(states[type]));
							}
						}
					}
				}
				else
				{
					bodyCmpnt = char.getComponentId(type) as CCBodyComponentModel;
					if (bodyCmpnt)
					{
						id = bodyCmpnt.component_id;
						component = this.getComponent(bodyshape, type, id);
						if (component)
						{
							cam.addComponent(bodyCmpnt, component.getFilenameByState(states[type]), this.themeId + "/" + component.getPathByState(states[type]));
						}
					}
				}
			}
			var libraries:Object = char.libraries;
			for (var lType:String in libraries)
			{
				var lId:String = char.getLibraryId(lType);
				var libreal:CCLibraryModel = bodyshape.getLibrary(lType, lId);
				if (libreal)
				{
					cam.addLibrary(lType, this.themeId + "/" + libreal.getPath());
				}
			}
			var colors:Object = char.colors;
			for (var cType:String in colors)
			{
				cam.addColor(cType, colors[cType]);
			}
			cam.bodyScale.scalex = char.bodyScale.scalex;
			cam.bodyScale.scaley = char.bodyScale.scalex;
			cam.headScale.scalex = char.headScale.scalex;
			cam.headScale.scaley = char.headScale.scaley;
			cam.headPos.dx = char.headPos.dx;
			cam.headPos.dy = char.headPos.dy;
			cam.version = char.version;
			if (!cam.propXML)
			{
				cam.propXML = action.propXML;
			}
			cam.themeId = this.themeId;
			cam.defaultActionId = bodyshape.defaultActionId;
			return cam;
		}
		
		protected function getCache(param1:String, param2:String) : CCCharacterActionModel
		{
			var _loc3_:Object = this._actionModels[param1];
			if(_loc3_)
			{
				return _loc3_[param2];
			}
			return null;
		}

		/**
		 * Stores a cam in a character's action object, which is
		 * indexed by the character ID in the `actionModels` object.
		 */
		protected function putCache(assetId:String, actionId:String, cam:CCCharacterActionModel) : void
		{
			if (!this._actionModels[assetId])
			{
				this._actionModels[assetId] = {};
			}
			this._actionModels[assetId][actionId] = cam;
		}

		/**
		 * get a cam
		 */
		public function getCharacterActionModel(ccBody:CCBodyModel, actionId:String) : CCCharacterActionModel
		{
			var cam:CCCharacterActionModel = this.getCache(ccBody.assetId, actionId);
			if (cam)
			{
				return cam;
			}
			var bs:CCBodyShapeModel = this.bodyShapes[ccBody.bodyShapeId];
			if (!bs)
			{
				return null;
			}
			var action:CCActionModel = bs.actions[actionId];
			if (action)
			{
				cam = this.createCharacterActionModel(ccBody, action);
			}
			this.putCache(ccBody.assetId, actionId, cam);
			return cam;
		}
		
		public function getCharacterFacialModel(param1:CCBodyModel, param2:String) : CCCharacterActionModel
		{
			var _loc3_:CCCharacterActionModel = this.getCache(param1.assetId,param2);
			if(_loc3_)
			{
				return _loc3_;
			}
			var _loc4_:CCBodyShapeModel = this.bodyShapes[param1.bodyShapeId];
			if(!_loc4_)
			{
				return null;
			}
			_loc3_ = new CCCharacterActionModel();
			param2 = String(param2.split(".")[0]);
			var _loc5_:CCFaceModel = this.faces[param2];
			if(_loc5_)
			{
				var _loc6_:Object = _loc5_.componentStates;
				for(var _loc7_:String in _loc6_)
				{
					var _loc10_:CCBodyComponentModel;
					var _loc11_:String;
					var _loc12_:CCComponentModel;
					if(CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(_loc7_) > -1)
					{
						var _loc13_:Object = param1.getComponentId(_loc7_);
						for(var _loc14_:String in _loc13_)
						{
							_loc10_ = _loc13_[_loc14_] as CCBodyComponentModel;
							if(_loc10_)
							{
								_loc11_ = _loc10_.component_id;
								_loc12_ = this.getComponent(_loc4_,_loc7_,_loc11_);
								if(_loc12_)
								{
									_loc3_.addComponent(_loc10_,_loc12_.getFilenameByState(_loc6_[_loc7_]),this.themeId + "/" + _loc12_.getPathByState(_loc6_[_loc7_]));
								}
							}
						}
					}
					else {
						_loc10_ = param1.getComponentId(_loc7_) as CCBodyComponentModel;
						if(_loc10_)
						{
							_loc11_ = _loc10_.component_id;
							_loc12_ = this.getComponent(_loc4_,_loc7_,_loc11_);
							if(_loc12_)
							{
								_loc3_.addComponent(_loc10_,_loc12_.getFilenameByState(_loc6_[_loc7_]),this.themeId + "/" + _loc12_.getPathByState(_loc6_[_loc7_]));
							}
						}
					}
				}
				var _loc8_:Object = param1.colors;
				for(var _loc9_:String in _loc8_)
				{
					_loc3_.addColor(_loc9_,_loc8_[_loc9_]);
				}
				_loc3_.version = param1.version;
				_loc3_.themeId = this.themeId;
			}
			this.putCache(param1.assetId,param2,_loc3_);
			return _loc3_;
		}
		
		public function getCharacterDefaultActionId(bsId:String) : String
		{
			var bodyShape:CCBodyShapeModel = this.bodyShapes[bsId];
			return bodyShape.defaultActionId;
		}
		
		public function getCharacterDefaultMotionId(bsId:String) : String
		{
			var bodyShape:CCBodyShapeModel = this.bodyShapes[bsId];
			return bodyShape.defaultMotionId;
		}
	}
}
