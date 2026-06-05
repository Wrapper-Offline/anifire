package anifire.cc.view
{
	import anifire.assets.AssetImageLibraryObject;
	import anifire.cc.model.CcComponentModel;
	import anifire.color.SelectedColor;
	import anifire.component.ProcessRegulator;
	import anifire.constant.CcLibConstant;
	import anifire.interfaces.IRegulatedProcess;
	import anifire.models.creator.CCBodyComponentModel;
	import anifire.models.creator.CCCharActionComponentModel;
	import anifire.models.creator.CCCharacterActionModel;
	import anifire.models.creator.CCColor;
	import anifire.util.UtilColor;
	import anifire.util.UtilErrorLogger;
	import anifire.util.UtilHashArray;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.display.DisplayObjectContainer;
	import anifire.util.UtilPlain;
	import flash.utils.ByteArray;
	
	public class CCHeadView extends CcHeadComponent
	{
		 
		
		private const STATE_LOADING:String = "STATE_LOADING";
		
		private const STATE_LOADED:String = "STATE_LOADED";
		
		private var _myActionModel:CCCharacterActionModel;
		
		private var _sceneId:String;
		
		private var _assetImageIdArray:UtilHashArray;
		
		private var _useImageLibrary:Boolean = false;
		
		private var _state:String;
		
		private var _containers:UtilHashArray;
		
		public function CCHeadView()
		{
			this._assetImageIdArray = new UtilHashArray();
			this._containers = new UtilHashArray();
			super();
			this.createComponentContainers();
		}
		
		private function createComponentContainers() : void
		{
			var _loc1_:Array = CcLibConstant.GET_COMPONENT_ORDER_IN_HEAD;
			this._containers = new UtilHashArray();
			var _loc2_:int = 0;
			while(_loc2_ < _loc1_.length)
			{
				var _loc3_:Sprite = new Sprite();
				_loc3_.name = _loc1_[_loc2_] + CcLibConstant.MC_NAME_EXT;
				this.addChild(_loc3_);
				this._containers.push(_loc3_.name, _loc3_);
				_loc2_++;
			}
		}
		
		private function createFaceDecorationContainers() : void
		{
			if (this._myActionModel)
			{
				var fdContainer:Sprite = this._containers.getValueByKey("facedecorationMC");
				if (fdContainer)
				{
					for (var type:String in this._myActionModel.components)
					{
						if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(type) > -1)
						{
							var decorations:Object = this._myActionModel.getComponentByType(type);
							if (decorations)
							{
								for (var i:String in decorations)
								{
									var component:CCBodyComponentModel = decorations[i] as CCBodyComponentModel;
									if (component.id)
									{
										var sprite:Sprite = new Sprite();
										sprite.name = component.id + CcLibConstant.MC_NAME_EXT;
										fdContainer.addChild(sprite);
									}
								}
							}
						}
					}
				}
			}
		}
		
		public function initByCam(param1:CCCharacterActionModel, param2:String = null, param3:Boolean = false) : void
		{
			this._myActionModel = param1;
			this._sceneId = param2;
			this._useImageLibrary = param3;
		}
		
		private function createAllComponents(keep:Boolean = false) : void
		{
			if (this._myActionModel) {
				var _loc4_:ProcessRegulator = new ProcessRegulator();
				if (!keep) {
					_componentList.removeAll();
				}
				for (var type:String in this._myActionModel.components) {
					var component:CcComponent = null;
					var listIndex:String = type;
					if (CcLibConstant.ALL_HEAD_COMPONENT_TYPES.indexOf(type) >= 0) {
						if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(type) > -1) {
							var components:Object = this._myActionModel.getComponentByType(type);
							for (var i:String in components) {
								if (type == CcLibConstant.COMPONENT_TYPE_FACIAL_DECORATION && components[i].id) {
									listIndex = components[i].id;
								}
								component = this.createComponentFromCam(type, i);
								if (component) {
									_loc4_.addProcess(component as IRegulatedProcess, Event.COMPLETE);
									if (!keep) {
										_componentList.push(listIndex, component);
									}
								}
							}
						} else {
							component = this.createComponentFromCam(type);
							if (component) {
								_loc4_.addProcess(component as IRegulatedProcess, Event.COMPLETE);
								if (!keep) {
									_componentList.push(listIndex, component);
								}
							}
						}
					}
				}
				_loc4_.addEventListener(Event.COMPLETE, this.onAllCcComponentCreated);
				_loc4_.startProcess();
			}
		}
		
		private function onAllCcComponentCreated(param1:Event) : void
		{
			IEventDispatcher(param1.target).removeEventListener(param1.type, this.onAllCcComponentCreated);
			if (!this._useImageLibrary)
			{
				this.prepareImage(this._sceneId);
			}
			this._state = this.STATE_LOADED;
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		override public function prepareImage(sceneId:String, isFirstBehaviour:Boolean = true) : void
		{
			try
			{
				this._sceneId = sceneId;
				this.borrowAllComponents(isFirstBehaviour);
				var i:uint = 0;
				while(i < _componentList.length)
				{
					this.addComponent(_componentList.getValueByIndex(i) as CcComponent);
					i++;
				}
				this.setColors();
			}
			catch(e:Error)
			{
				UtilErrorLogger.getInstance().appendCustomError("CcHeadComponent:prepareImage:" + sceneId, e);
			}
		}

		public function setComponent(type:String, id:String, swfBytes:ByteArray) : Boolean
		{
			var index:String = "";
			if (id) {
				var components:Object = this._myActionModel.getComponentByType(type);
				for (var i:String in components) {
					if ((components[i] as CCCharActionComponentModel).id == id) {
						index = i;
					}
				}	
			}
			var component:CcComponent = this.createComponentFromCam(type, index);
			if (component) {
				var listIndex:String = type;
				if (type == "facedecoration") {
					listIndex = id;
					var spriteName:String = id + CcLibConstant.MC_NAME_EXT;
					var _loc6_:DisplayObjectContainer = UtilPlain.getInstance(this, spriteName);
					if (!_loc6_) {
						// throw id;
						var fdContainer:Sprite = this._containers.getValueByKey("facedecorationMC");
						if (fdContainer) {
							var sprite:Sprite = new Sprite();
							sprite.name = spriteName;
							fdContainer.addChild(sprite);
						}
					}
				}
				this._componentList.push(listIndex, component);
				component.addEventListener(Event.COMPLETE, this.onComponentLoaded);
				component.loadFromBytes(swfBytes);
				return true;
			}
			return false;
		}

		protected function onComponentLoaded(param1:Event) : void
		{
			var component:CcComponent = param1.target as CcComponent;
			if(component)
			{
				component.removeEventListener(Event.COMPLETE,this.onComponentLoaded);
				this.addComponent(component);
			}
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function createComponentFromCam(type:String, index:String = "") : CcComponent
		{
			var component:CcComponent = CcComponentFactory.create(type);
			var components:Object;
			if (this._useImageLibrary) {
				if (this._myActionModel) {
					var path:String;
					if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(type) > -1) {
						components = this._myActionModel.getComponentByType(type);
						path = components[index].path;
					} else {
						path = this._myActionModel.getComponentByType(type).path;
					}
					var _loc6_:Number = 0;
					_loc6_ = CcImageLibrary.library.requestImage(path, this._sceneId, component);
					if (_loc6_ > 0) {
						return null;
					}
				}
			}
			if (component) {
				var _loc7_:CcComponentModel = CcComponentModel.createModelByType(type);
				if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(type) > -1) {
					components = this._myActionModel.getComponentByType(type);
					_loc7_.initByCACam(components[index] as CCCharActionComponentModel);
				} else {
					_loc7_.initByCam(this._myActionModel, type);
				}
				component.init(_loc7_);
			}
			return component;
		}
		
		override public function requestImage(sceneId:String) : void
		{
			try
			{
				if (this._useImageLibrary)
				{
					this._sceneId = sceneId;
					this.createAllComponents(true);
				}
				else
				{
					this.dispatchEvent(new Event(Event.COMPLETE));
				}
			}
			catch(e:Error)
			{
				this.dispatchEvent(new Event(Event.COMPLETE));
				UtilErrorLogger.getInstance().appendCustomError("CcHeadComponent:requestImage:" + sceneId, e);
			}
		}
		
		override public function load() : void
		{
			if (this._state == this.STATE_LOADING)
			{
				if (this._useImageLibrary)
				{
					this.requestImage(this._sceneId);
				}
				return;
			}
			if (this._state == this.STATE_LOADED)
			{
				if (this._useImageLibrary)
				{
					this.requestImage(this._sceneId);
				}
				else
				{
					this.dispatchEvent(new Event(Event.COMPLETE));
				}
				return;
			}
			this._state = this.STATE_LOADING;
			this.createFaceDecorationContainers();
			this.createAllComponents();
		}
		
		private function borrowAllComponents(param1:Boolean = true) : void
		{
			if (this._useImageLibrary)
			{
				if (this._myActionModel)
				{
					var _loc2_:String;
					var _loc3_:CcComponent;
					var _loc4_:String;
					var _loc5_:Object;
					var _loc6_:String;
					_componentList.removeAll();
					for (_loc2_ in this._myActionModel.components)
					{
						_loc3_ = null;
						_loc4_ = _loc2_ = String(_loc2_);
						if (CcLibConstant.ALL_HEAD_COMPONENT_TYPES.indexOf(_loc2_) >= 0)
						{
							if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(_loc2_) > -1)
							{
								_loc5_ = this._myActionModel.components[_loc2_];
								for (_loc6_ in _loc5_)
								{
									_loc4_ = _loc6_;
									_loc3_ = this.borrowComponentByCam(_loc2_, param1, _loc4_);
									if (_loc3_)
									{
										_componentList.push(_loc4_, _loc3_);
									}
								}
							}
							else
							{
								_loc3_ = this.borrowComponentByCam(_loc2_, param1, this._myActionModel.getComponentByType(_loc2_).path);
								if (_loc3_)
								{
									_componentList.push(_loc4_, _loc3_);
								}
							}
						}
					}
				}
			}
		}
		
		private function borrowComponentByCam(param1:String, param2:Boolean, param3:String) : CcComponent
		{
			var _loc4_:CcComponent;
			var _loc5_:Object;
			var _loc6_:String;
			var _loc7_:Object;
			if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(param1) > -1)
			{
				_loc7_ = this._myActionModel.getComponentByType(param1);
				_loc6_ = _loc7_[param3].path;
			}
			else
			{
				_loc6_ = this._myActionModel.getComponentByType(param1).path;
			}
			var _loc8_:AssetImageLibraryObject;
			var _loc9_:Number = 0;
			if (!param2)
			{
				_loc9_ = this._assetImageIdArray.getValueByKey(_loc6_);
			}
			_loc8_ = CcImageLibrary.library.borrowImage(_loc6_, _loc9_, this._sceneId);
			if (_loc8_)
			{
				this._assetImageIdArray.push(_loc6_, _loc8_.imageId);
				_loc4_ = _loc8_.image as CcComponent;
				if (_loc4_)
				{
					var _loc10_:CcComponentModel = CcComponentModel.createModelByType(param1);
					if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(param1) > -1)
					{
						_loc10_.initByCACam(_loc7_[param3]);
					}
					else
					{
						_loc10_.initByCam(this._myActionModel, param1);
					}
					_loc4_.reset(_loc10_);
				}
			}
			return _loc4_;
		}
		
		public function restoreColors() : void
		{
			this.setColors();
		}
		
		override protected function setColors() : void
		{
			UtilColor.resetAssetPartsColor(this);
			if (this._myActionModel)
			{
				for (var _loc1_:String in this._myActionModel.colorCodes)
				{
					var color:CCColor = this._myActionModel.getColor(_loc1_);
					var selColor:SelectedColor = new SelectedColor(color.type, color.oc, color.dest);
					changeColor(selColor, !!color.targetComponent ? color.targetComponent : "");
				}
			}
		}
	}
}
