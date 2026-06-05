package anifire.creator.components
{
	import anifire.component.CustomCharacterMaker;
	import anifire.constant.CcLibConstant;
	import anifire.event.LoadEmbedMovieEvent;
	import anifire.managers.NativeCursorManager;
	import anifire.util.UtilLoadMgr;
	import mx.core.UIComponent;
	import anifire.models.creator.CCBodyModel;
	import anifire.models.creator.CCBodyComponentModel;
	import anifire.models.creator.CCThemeModel;
	import anifire.models.creator.CCCharacterActionModel;
	import anifire.models.creator.CCColor;
	import anifire.models.creator.CCComponentModel;
	import anifire.models.creator.CCBodyShapeModel;
	import anifire.component.CcActionLoader;
	import anifire.component.CcComponentLoader;
	import anifire.util.UtilErrorLogger;
	import anifire.models.creator.CCCharActionComponentModel;
	import anifire.util.ExtraDataLoader;
	import anifire.models.creator.CCLibraryModel;
	import flash.net.URLRequest;
	import flash.display.LoaderInfo;
	import flash.events.MouseEvent;
	import anifire.creator.managers.CommandBarManager;
	import anifire.creator.events.CommandBarEvent;
	import mx.events.SandboxMouseEvent;
	import spark.components.Group;
	import mx.events.FlexEvent;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.events.IOErrorEvent;
	import flash.events.IEventDispatcher;
	import flash.events.Event;
	import flash.system.LoaderContext;

	public class CharPreview extends Group
	{
		private static const DEFAULT_SCALE:Number = 1.3;
		private static const LOADER:String = "loader";
		public var showFace:Boolean = false;
		private var myUI:UIComponent;
		private var _isBuilding:int = 0;
		private var cam:CCCharacterActionModel;
		private var faceCam:CCCharacterActionModel;
		private var theme:CCThemeModel;
		private var actionId:String;
		private var facialId:String;
		private var _facing:int = -1;
		private var dragStart:Array;
		private var charStart:Array;
		private static var instance:CharPreview;

		public function CharPreview()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, creationComplete);
			instance = this;
		}

		public static function get facing() : int
		{
			return instance._facing;
		}

		private function get ccm() : CustomCharacterMaker
		{
			return CustomCharacterMaker(myUI.getChildByName(LOADER));
		}

		private function creationComplete(e:FlexEvent) : void
		{
			var charMaker:CustomCharacterMaker = new CustomCharacterMaker();
			charMaker.name = LOADER;
			charMaker.visible = false;
			charMaker.scaleX = DEFAULT_SCALE * _facing;
			charMaker.scaleY = DEFAULT_SCALE;
			charMaker.x = 755;
			charMaker.y = 270;
			myUI = new UIComponent();
			myUI.addChild(charMaker);
			addElement(myUI);
			addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			CommandBarManager.instance.addEventListener(CommandBarEvent.PREVIEW_FLIP, flip);
		}

		private function mouseWheel(event:MouseEvent) : void
		{
			var pow:Number = .075;
			var direction:int = event.delta > 0 ? 1 : -1;
			var self:CharPreview = this;
			var func:Function = function scrollDecay(e:Event = null) {
				var factor:Number = Math.exp(direction * pow);
				var newScale:Number = self.ccMaker.scaleY * factor;
				if (pow < 0.002 || newScale > 5 || newScale < 0.5) {
					self.removeEventListener(Event.ENTER_FRAME, func);
					pow = 0;
					return;
				}
				var dX:Number = event.stageX - self.ccMaker.x;
				var dY:Number = event.stageY - self.ccMaker.y;
				self.ccMaker.x = event.stageX - dX * factor;
				self.ccMaker.y = event.stageY - dY * factor;
				self.ccMaker.scaleX = newScale * self._facing;
				self.ccMaker.scaleY = newScale;
				pow -= 0.015;
			};
			addEventListener(Event.ENTER_FRAME, func);
			func();
		}

		private function mouseDown(event:MouseEvent) : void
		{
			charStart = [ccMaker.x, ccMaker.y];
			dragStart = [event.stageX, event.stageY];
			systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			systemManager.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUp);
		}

		private function mouseMove(event:MouseEvent) : void
		{
			ccMaker.x = charStart[0] + (event.stageX - dragStart[0]);
			ccMaker.y = charStart[1] + (event.stageY - dragStart[1]);
		}

		private function mouseUp(event:Event) : void
		{
			systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			systemManager.getSandboxRoot().removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUp);
		}

		private function flip(event:CommandBarEvent) : void
		{
			_facing = -_facing;
			ccMaker.scaleX *= -1;
		}

		/**
		 * Replaces the character currently being previewed
		 * with another.
		 * @param ccChar CC character body
		 * @param theme Character theme
		 */
		public function initByCcBody(ccChar:CCBodyModel, theme:CCThemeModel) : void
		{
			if (this._isBuilding == 1) {
				return;
			}
			this.theme = theme;
			this.actionId = theme.getCharacterDefaultActionId(ccChar.bodyShapeId);
			this.cam = theme.getCharacterActionModel(ccChar, this.actionId);

			// merge the facial model into the action model
			this.facialId = this.cam.actionModel.defaultFacialId.replace(/\.xml$/, "");
			this.faceCam = theme.getCharacterFacialModel(ccChar, this.facialId);
			for (var type:String in this.faceCam.components) {
				this.cam.components[type] = this.faceCam.components[type];
			}

			this._isBuilding = 1;
			NativeCursorManager.instance.setBusyCursor();
			this.ccMaker.visible = false;
			this.ccMaker.destroy();
			
			this.ccMaker.ver = ccChar.version;
			this.ccMaker.addEventListener(LoadEmbedMovieEvent.COMPLETE_EVENT, this.onLoaded);
			this.ccMaker.initByCam(this.cam);
		}

		/**
		 * Called by `initByCcBody` when `CustomCharacterMaker`
		 * has finished loading the character, and it is ready
		 * to be displayed.
		 */
		private function onLoaded(event:LoadEmbedMovieEvent) : void
		{
			(event.target as IEventDispatcher).removeEventListener(event.type, this.onLoaded);
			this._isBuilding = 2;
			NativeCursorManager.instance.removeBusyCursor();
			this.ccMaker.visible = true;
			this.onRandomCharacterComplete();
			this.dispatchEvent(new LoadEmbedMovieEvent(LoadEmbedMovieEvent.COMPLETE_EVENT, this));
		}

		/**
		 * displays a library on the character
		 * @param type library type
		 * @param id library id
		 * @param bodyShapeId id of the character's bodyshape
		 */
		public function useLibrary(type:String, id:String, bodyShapeId:String) : void
		{
			var bodyShape:CCBodyShapeModel = this.theme.bodyShapes[bodyShapeId];
			var library:CCLibraryModel = bodyShape.getLibrary(type, id);
			var path:String = this.theme.themeId + "/" + library.getPath();
			var storeUrl:String = CcActionLoader.getStoreUrl(path);
			this.cam.addLibrary(library.type, path);
			this.ccMaker.myActionModel = this.cam;

			var loader:ExtraDataLoader = new ExtraDataLoader();
			var lc:LoaderContext = new LoaderContext();
			lc.allowCodeImport = true;
			var self:CharPreview = this;
			loader.contentLoaderInfo.addEventListener(
				Event.COMPLETE,
				function addComponent_successHandler(e:Event) : void
				{
					(e.target as IEventDispatcher).removeEventListener(e.type, addComponent_successHandler);
					var loaderInfo:LoaderInfo = LoaderInfo(e.target);
					if (!loaderInfo) {
						return;
					}
					
					self.ccMaker.CCM.addStyle(library.type, loaderInfo);
					self.ccMaker.addLibrary(library.type, library.id, self.theme.themeId);
					self.ccMaker.reloadSkin();
				}
			);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.addComponent_failHandler);
			loader.load(new URLRequest(storeUrl), lc);
		}

		public function onRandomCharacterComplete() : void
		{
			this.playBlurEffect();
		}
		
		private function playBlurEffect() : void
		{
			// this.fadeIn.play();
		}

		/**
		 * Replaces a color in the CAM and calls for the
		 * `CustomCharacterMaker` to update the color type
		 * accordingly.
		 */
		public function updateColor(color:CCColor) : void
		{
			try
			{
				var colorObj:Object = new Object();
				colorObj["colorReference"] = color.type;
				colorObj["originalColor"] = color.oc != uint.MAX_VALUE ? color.oc : uint.MAX_VALUE;
				colorObj["colorValue"] = color.dest;
				colorObj["targetComponentId"] = color.targetComponent == null ? "" : color.targetComponent;
				this.cam.addColor(color.type, color);
				this.ccMaker.myActionModel = this.cam;
				this.ccMaker.updateColor(colorObj);
			}
			catch(e:Error)
			{
				UtilErrorLogger.getInstance().appendCustomError("CharPreview:updateColor:", e);
			}
		}

		public function removeColor(type:String) : void
		{
			delete this.cam.colorCodes[type];
			this.refreshColors();
		}

		/**
		 * Adds a component to the CAM and updates the
		 * `CustomCharacterMaker`. If a component of the
		 * specified type already exists, and multiples of the
		 * type are not allowed, it will be replaced.
		 */
		public function addComponent(bodyCmpnt:CCBodyComponentModel, bodyShapeId:String, properties:Object) : void
		{
			// we have to get the right component state requested by the action
			var state:String = this.theme.faces[this.facialId].componentStates[bodyCmpnt.type];
			if (!state) {
				state = this.cam.actionModel.componentStates[bodyCmpnt.type];
				if (!state) {
					state = "default";
				}
			}
			var bodyShape:CCBodyShapeModel = this.theme.bodyShapes[bodyShapeId];
			var component:CCComponentModel = this.theme.getComponent(bodyShape, bodyCmpnt.type, bodyCmpnt.component_id);
			this.cam.addComponent(
				bodyCmpnt,
				component.getFilenameByState(state),
				this.theme.themeId + "/" + component.getPathByState(state)
			);
			// not sure if it updates without this, better to be safe
			// (i'm not wasting my time to check. you go ahead if you want to, though)
			this.ccMaker.myActionModel = this.cam;

			// finally, we'll load the component and give it to the cc character maker
			var path:String;
			var index:String;
			if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(bodyCmpnt.type) > -1) {
				var components:Vector.<CCCharActionComponentModel> = this.cam.getComponentByType(bodyCmpnt.type) as Vector.<CCCharActionComponentModel>;
				for (var i:String in components) {
					var actCmpnt:CCCharActionComponentModel = components[i];
					if (actCmpnt.id == bodyCmpnt.id) {
						path = actCmpnt.path;
						index = i;
					}
				}
				if (!path) {
					return;
				}
			} else {
				path = this.cam.getComponentByType(bodyCmpnt.type).path;
			}
			var storeUrl:String = CcActionLoader.getStoreUrl(path);
			var compLoader:CcComponentLoader = new CcComponentLoader(path, storeUrl);

			var self:CharPreview = this;
			compLoader.addEventListener(
				Event.COMPLETE,
				function addComponent_successHandler(e:Event) : void
				{
					(e.target as IEventDispatcher).removeEventListener(e.type, addComponent_successHandler);
					var loader:CcComponentLoader = CcComponentLoader(e.target);
					if (!loader) {
						return;
					}
					var loadMgr:UtilLoadMgr = new UtilLoadMgr();
					var extr = self.ccMaker.updateComponentImageData(
						bodyCmpnt.type,
						loader.swfBytes,
						properties,
						loadMgr,
						null,
						bodyCmpnt.id
					);
					if (extr) {
						extr.addEventListener(Event.INIT, self.dataLoader_init);
					}
					loadMgr.commit();
				}
			);
			compLoader.addEventListener(IOErrorEvent.IO_ERROR, this.addComponent_failHandler);
			compLoader.load();
		}

		/**
		 * Called when an error occurs in `addComponent` while
		 * trying to load the component.
		 * @param event `IOErrorEvent.IO_ERROR`
		 */
		private function addComponent_failHandler(event:IOErrorEvent) : void
		{
			(event.target as IEventDispatcher).removeEventListener(event.type, this.addComponent_failHandler);
			UtilErrorLogger.getInstance().appendCustomError("CharPreview:addComponent:", new Error(event.errorID));
		}

		/**
		 * Called to have `CustomCharacterMaker` update a
		 * component's colors after it is successfully loaded.
		 */
		protected function dataLoader_init(event:Event) : void
		{
			(event.target as IEventDispatcher).removeEventListener(event.type, this.refreshColors);
			this.refreshColors();
		}

		/**
		 * Called to have `CustomCharacterMaker` update a
		 * component's colors after it is successfully loaded.
		 */
		protected function refreshColors() : void
		{
			ccm.onReady();
		}
		
		public function highlightComponent(bodyCmpnt:CCBodyComponentModel) : void
		{
			ccm.highlightComponent(bodyCmpnt.id);
		}
		
		public function removeHighlightComponent(bodyCmpnt:CCBodyComponentModel) : void
		{
			ccm.removeHighlight(bodyCmpnt.id);
		}
		
		public function removeComponent(bodyComponent:CCBodyComponentModel) : void
		{
			var type:String = bodyComponent.type;
			var ccm:CustomCharacterMaker = ccm;

			if (type == CcLibConstant.COMPONENT_TYPE_HAIR) {
				ccm.removeComponent(type, bodyComponent.type);
				ccm.removeComponent(type, CcLibConstant.COMPONENT_TYPE_FRONT_HAIR);
				ccm.removeComponent(type, CcLibConstant.COMPONENT_TYPE_BACK_HAIR);
			} else if (CcLibConstant.ALL_OFFSETABLE_COMPONENT_TYPES.indexOf(type) > -1) {
				ccm.removeComponent(type, bodyComponent.type + CcLibConstant.LEFT, false, false);
				ccm.removeComponent(type, bodyComponent.type + CcLibConstant.RIGHT, false, false);
			} else if (CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(type) > -1) {
				ccm.removeComponent(type, bodyComponent.id, true);
				var components:Vector.<CCCharActionComponentModel> = this.cam.components[bodyComponent.type];
				for (var i:String in components) {
					var component:CCCharActionComponentModel = components[i];
					if (component.id == bodyComponent.id) {
						delete components[i];
						break;
					}
				}
				return;
			} else {
				ccm.removeComponent(type, bodyComponent.type);
			}

			delete this.cam.components[bodyComponent.type];
		}

		public function removeLibrary(type:String, id:String) : void
		{
			var ccm:CustomCharacterMaker = ccm;
			delete this.cam.libraryPaths[type];
			ccm.CCM.removeStyle(type);
			ccm.removeLibrary(type);
			ccm.reloadSkin();
		}
		
		public function updateLocation(component:CCBodyComponentModel) : void
		{
			var properties:Object = {
				"x": component.x,
				"y": component.y,
				"xscale": component.xscale,
				"yscale": component.yscale,
				"offset": component.offset,
				"rotation": component.rotation
			};
			ccm.updateLocation(component.type, properties, component.id || "");
			if (component.type == CcLibConstant.COMPONENT_TYPE_HAIR) {
				ccm.updateLocation(CcLibConstant.COMPONENT_TYPE_FRONT_HAIR, properties, "");
				ccm.updateLocation(CcLibConstant.COMPONENT_TYPE_BACK_HAIR, properties, "");
			}
		}
		
		public function setHeadScale(param1:Number, param2:Number) : void
		{
			ccm.updateHeadScale(param1,param2);
			this.updateCCPosition();
		}
		
		public function setBodyScale(param1:Number, param2:Number) : void
		{
			ccm.updateBodyScale(param1,param2);
			this.updateCCPosition();
		}
		
		public function resetHeadPos() : void
		{
			ccm.resetHeadPos();
		}
		
		public function setHeadPos(param1:Number = 0, param2:Number = 0) : void
		{
			ccm.updateHeadPos(param1,param2);
		}
		
		public function getHeadScale() : Point
		{
			return new Point(ccm.head.scaleX,ccm.head.scaleY);
		}
		
		public function getBodyScale() : Point
		{
			return new Point(ccm.bodyScale,ccm.bodyScale);
		}
		
		public function getHeadPos() : Point
		{
			return ccm.headPos;
		}
		
		private function updateCCPosition() : void
		{
			var _loc1_:Rectangle = ccm.getBounds(this.myUI);
			var _loc2_:Number = _loc1_.height + _loc1_.y;
			if(this.showFace)
			{
				this.myUI.y = this.height - 40;
			}
			else
			{
				this.myUI.y = this.height - _loc2_;
			}
			this.myUI.x = this.width / 2;
		}
		
		public function get ccMaker() : CustomCharacterMaker
		{
			return ccm;
		}

		public function capCharAsBitmap() : BitmapData
		{
			var _loc1_:BitmapData = null;
			return ccm.getBitmap();
		}
		
		public function capFaceAsBitmap() : BitmapData
		{
			var _loc1_:BitmapData = null;
			return ccm.getHeadBitmap();
		}
		
		public function reloadSkin() : void
		{
			ccm.reloadSkin();
		}
	}
}
