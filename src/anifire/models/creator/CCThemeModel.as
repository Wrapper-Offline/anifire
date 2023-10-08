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
		public var faces:Object;
		public var completed:Boolean = false;
		protected var loader:URLLoader;
		private var _actionModels:Object;
		
		public function CCThemeModel(param1:String)
		{
			super();
			this.themeId = param1;
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
			var node:XML;
			var nodeIndex:int = 0;
			while (nodeIndex < totalNodes)
			{
				node = nodes[nodeIndex];
				var tagName:String = node.localName() as String;
				switch (tagName)
				{
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
						// any component in the root would be a shared component
						// a shared component would be available to any bodyshape
						// an example of a shared component would be an ear or a mouth
						this.storeSharedComponent(component);
				}
				nodeIndex++;
			}
			this.completed = true;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function getActions(param1:String) : Object
		{
			var _loc2_:CCBodyShapeModel = this.bodyShapes[param1];
			if(_loc2_)
			{
				return _loc2_.actions;
			}
			return null;
		}

		/**
		 * takes in the component type and component and outputs something like "ear:006"
		 */
		protected function componentUniqueId(componentType:String, componentId:String) : String
		{
			return componentType + ":" + componentId;
		}

		protected function storeSharedComponent(component:CCComponentModel) : void
		{
			var uniqueId:String = this.componentUniqueId(component.type, component.id);
			this.components[uniqueId] = component;
		}

		/**
		 * get a shared component
		 */
		protected function getSharedComponent(type:String, id:String) : CCComponentModel
		{
			var uniqueId:String = this.componentUniqueId(type, id);
			return this.components[uniqueId];
		}

		/**
		 * get any type of component
		 */
		protected function getComponent(bodyshape:CCBodyShapeModel, type:String, id:String) : CCComponentModel
		{
			// try getting a bodyshape component, like an upper_body
			var component:CCComponentModel = bodyshape.getComponent(type, id);
			// doesn't exist. must be a shared component
			if (!component)
			{
				component = this.getSharedComponent(type, id);
			}
			return component;
		}

		public function createCharacterActionModel(param1:CCBodyModel, param2:CCActionModel) : CCCharacterActionModel
		{
			var _loc3_:CCBodyShapeModel = this.bodyShapes[param1.bodyShapeId];
			if(!this.runwayMode)
			{
				var _loc13_:Object = this._actionModels[param1.assetId];
				if(_loc13_)
				{
					var _loc14_:CCCharacterActionModel = _loc13_[_loc6_];
					if(_loc14_)
					{
						return _loc14_;
					}
				}
			}
			var _loc4_:CCBodyShapeModel = this.bodyShapes[param1.bodyShapeId];
			if(!_loc4_)
			{
				return null;
			}
			var _loc5_:CCCharacterActionModel = new CCCharacterActionModel();
			_loc5_.actionModel = param2;
			_loc5_.enabled = param2.enabled;
			var _loc6_:String;
			_loc6_ = param2.shortId;
			var _loc7_:Object = param2.componentStates;
			for(var _loc8_:String in _loc7_)
			{
				var _loc15_:CCBodyComponentModel;
				var _loc16_:CCComponentModel;
				var _loc17_:String;
				var _loc18_:CCComponentModel;
				if(_loc8_ == "freeaction")
				{
					_loc16_ = this.getComponent(_loc3_,"freeaction",_loc6_);
					if(_loc16_)
					{
						_loc15_ = param1.getComponentId("freeaction") as CCBodyComponentModel;
						_loc5_.addComponent(_loc15_,_loc6_ + ".swf",this.themeId + "/freeaction/" + _loc15_.folder + "/" + _loc6_ + ".swf");
						_loc5_.freeactionFolderName = _loc15_.folder;
					}
				}
				else if(CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(_loc8_) > -1)
				{
					var _loc19_:Object = param1.getComponentId(_loc8_);
					for(var _loc20_:String in _loc19_)
					{
						_loc15_ = _loc19_[_loc20_] as CCBodyComponentModel;
						if(_loc15_)
						{
							_loc17_ = _loc15_.component_id;
							_loc18_ = this.getComponent(_loc3_,_loc8_,_loc17_);
							if(_loc18_)
							{
								_loc5_.addComponent(_loc15_,_loc18_.getFilenameByState(_loc7_[_loc8_]),this.themeId + "/" + _loc18_.getPathByState(_loc7_[_loc8_]));
							}
						}
					}
				}
				else
				{
					_loc15_ = param1.getComponentId(_loc8_) as CCBodyComponentModel;
					if (_loc15_)
					{
						_loc17_ = _loc15_.component_id;
						_loc18_ = this.getComponent(_loc3_,_loc8_,_loc17_);
						if(_loc18_)
						{
							_loc5_.addComponent(_loc15_,_loc18_.getFilenameByState(_loc7_[_loc8_]),this.themeId + "/" + _loc18_.getPathByState(_loc7_[_loc8_]));
						}
					}
				}
			}
			var _loc9_:Object = param1.libraries;
			for(var _loc10_:String in _loc9_)
			{
				var _loc21_:String = param1.getLibraryId(_loc10_);
				var _loc22_:CCLibraryModel = _loc3_.getLibrary(_loc10_,_loc21_);
				if(_loc22_)
				{
					_loc5_.addLibrary(_loc10_,this.themeId + "/" + _loc22_.getPath());
				}
			}
			var _loc11_:Object = param1.colors;
			for(var _loc12_:String in _loc11_)
			{
				_loc5_.addColor(_loc12_,_loc11_[_loc12_]);
			}
			_loc5_.bodyScale.scalex = param1.bodyScale.scalex;
			_loc5_.bodyScale.scaley = param1.bodyScale.scalex;
			_loc5_.headScale.scalex = param1.headScale.scalex;
			_loc5_.headScale.scaley = param1.headScale.scaley;
			_loc5_.headPos.dx = param1.headPos.dx;
			_loc5_.headPos.dy = param1.headPos.dy;
			_loc5_.version = param1.version;
			if(!_loc5_.propXML)
			{
				_loc5_.propXML = param2.propXML;
			}
			_loc5_.themeId = this.themeId;
			_loc5_.defaultActionId = _loc3_.defaultActionId;
			return _loc5_;
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
		
		protected function putCache(param1:String, param2:String, param3:CCCharacterActionModel) : void
		{
			if(!this._actionModels[param1])
			{
				this._actionModels[param1] = {};
			}
			this._actionModels[param1][param2] = param3;
		}

		/**
		 * get a character action
		 */
		public function getCharacterActionModel(param1:CCBodyModel, param2:String) : CCCharacterActionModel
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
			var _loc5_:CCActionModel = _loc4_.actions[param2];
			if(_loc5_)
			{
				_loc3_ = this.createCharacterActionModel(param1, _loc5_);
			}
			this.putCache(param1.assetId, param2, _loc3_);
			return _loc3_;
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
		
		public function getCharacterDefaultActionId(param1:String) : String
		{
			var _loc2_:CCBodyShapeModel = this.bodyShapes[param1];
			return _loc2_.defaultActionId;
		}
		
		public function getCharacterDefaultMotionId(param1:String) : String
		{
			var _loc2_:CCBodyShapeModel = this.bodyShapes[param1];
			return _loc2_.defaultMotionId;
		}
	}
}
