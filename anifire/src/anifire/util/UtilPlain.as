package anifire.util
{
	import anifire.constant.AnimeConstants;
	import anifire.constant.CcLibConstant;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import nochump.util.zip.ZipEntry;
	import nochump.util.zip.ZipFile;

	public class UtilPlain
	{
		public static const THE_CHAR:String = "theChar";
		public static const THE_CHAR_FLIP:String = "theCharFlip";
		public static const THE_COLOR:String = "theColor";
		public static const COLORABLE_PREFIX:String = "Color";
		public static const THE_PROP:String = AnimeConstants.MOVIECLIP_THE_PROP;
		public static const THE_HEAD:String = AnimeConstants.MOVIECLIP_THE_HEAD;
		public static const THE_WEAR:String = AnimeConstants.MOVIECLIP_THE_WEAR;
		public static const THE_TAIL:String = AnimeConstants.MOVIECLIP_THE_TAIL;
		public static const THE_MOUTH:String = AnimeConstants.MOVIECLIP_THE_MOUTH;
		public static const PROPERTY_SCALEX:String = "scalex";
		public static const PROPERTY_SCALEY:String = "scaley";
		private static const SPEECH_MOUTH:String = "speechMouth";

		public function UtilPlain()
		{
			super();
		}

		public static function get PARTS_NOT_CONTROL_BY_PLAYER() : Array
		{
			var _loc1_:Array = new Array();
			_loc1_.push(SPEECH_MOUTH);
			return _loc1_;
		}

		public static function playFamily(iObj:DisplayObject) : void
		{
			var treatment:Function = function (obj:DisplayObject):void
			{
				if (obj is MovieClip)
				{
					var clip:MovieClip = MovieClip(obj);
					clip.play();
				}
			};
			UtilPlain.transverseFamily(iObj, treatment, PARTS_NOT_CONTROL_BY_PLAYER);
		}

		public static function stopFamily(iObj:DisplayObject) : void
		{
			var treatment:Function = function (obj:DisplayObject):void
			{
				var clip:MovieClip = null;
				if (obj is MovieClip)
				{
					clip = MovieClip(obj);
					clip.stop();
				}
			};
			UtilPlain.transverseFamily(iObj, treatment);
		}

		public static function advanceFamilyToNextFrame(iObj:DisplayObject) : Boolean
		{
			var result:Boolean = false;
			var treatment:Function = function (obj:DisplayObject):void
			{
				if (obj is MovieClip)
				{
					var clip:MovieClip = MovieClip(obj);
					clip.nextFrame();
					if (clip.name == THE_CHAR)
					{
						if (clip.currentFrame < clip.totalFrames)
						{
							result = true;
						}
					}
				}
			};
			UtilPlain.transverseFamily(iObj, treatment);
			return result;
		}

		public static function traceDisplayList(container:DisplayObjectContainer, unused:String = "") : void
		{
			for (var i:int = 0; i < container.numChildren; i++)
			{
				var child:DisplayObject = container.getChildAt(i);
				if (child != null)
				{
				}
				if (container.getChildAt(i) is DisplayObjectContainer)
				{
					traceDisplayList(DisplayObjectContainer(child), unused + "	 ");
				}
			}
		}

		public static function removeAllSon(container:DisplayObjectContainer) : void
		{
			var length:int = container.numChildren;
			for (var i:int = length - 1; i >= 0; i--)
			{
				var child:Object = container.getChildAt(i);
				container.removeChildAt(i);
				child = null;
			}
		}

		public static function getCharacter(param1:DisplayObjectContainer) : MovieClip
		{
			return getInstance(param1, THE_CHAR) as MovieClip;
		}

		public static function getCharacterFlip(param1:DisplayObjectContainer) : MovieClip
		{
			return getInstance(param1, THE_CHAR_FLIP) as MovieClip;
		}

		public static function getAllShaderObj(theObj:DisplayObject) : Array
		{
			var objArray:Array = new Array();
			var treatment:Function = function (obj:DisplayObject):void
			{
				if (obj != null)
				{
					if (DisplayObject(obj).name == "shaderObj")
					{
						objArray.push(obj);
					}
				}
			};
			UtilPlain.transverseFamily(theObj, treatment);
			return objArray;
		}

		public static function getLoaderItem(theObj:DisplayObject) : Array
		{
			var objArray:Array = new Array();
			var treatment:Function = function (obj:DisplayObject):void
			{
				if (obj != null)
				{
					if (obj is Loader)
					{
						objArray.push(obj);
					}
				}
			};
			UtilPlain.transverseFamily(theObj, treatment);
			return objArray;
		}

		public static function getLoaderItemExcludeTheHeadTheHand(theObj:DisplayObject) : Array
		{
			var objArray:Array = new Array();
			var treatment:Function = function (obj:DisplayObject):void
			{
				if (obj != null)
				{
					if (obj is Loader)
					{
						objArray.push(obj);
					}
				}
			};
			UtilPlain.transverseFamily(theObj, treatment, [UtilPlain.THE_HEAD, UtilPlain.THE_PROP]);
			return objArray;
		}

		public static function getColorItem(theObj:DisplayObject, spec:String = "") : Array
		{
			var objArray:Array = new Array();
			var treatment:Function = function (obj:DisplayObject):void
			{
				if (obj != null)
				{
					var _loc2_:String = getColorItemName(DisplayObject(obj).name);
					if (_loc2_ != "" && (spec == "" || spec != "" && _loc2_ == spec))
					{
						objArray.push(obj);
					}
				}
			};
			UtilPlain.transverseFamily(theObj, treatment);
			return objArray;
		}

		public static function getColorItemName(param1:String) : String
		{
			var _loc4_:String = null;
			var _loc2_:String = "";
			if (param1.indexOf(THE_COLOR) == 0)
			{
				var _loc3_:Array = param1.split("_");
				if (_loc3_.length > 1)
				{
					_loc2_ = _loc3_[1];
				}
			}
			else if (param1.indexOf(COLORABLE_PREFIX) == 0)
			{
				_loc4_ = param1.substring(COLORABLE_PREFIX.length);
				_loc2_ = _loc4_;
			}
			return _loc2_;
		}

		public static function extractCharFlip(swfLoader:Loader) : DisplayObject
		{
			try
			{
				var charFlip:Class = swfLoader.content.loaderInfo.applicationDomain.getDefinition(THE_CHAR_FLIP) as Class;
			}
			catch (e:Error)
			{
				return null;
			}
			var char:DisplayObject = new charFlip();
			char.name = THE_CHAR_FLIP;
			return char;
		}

		public static function extractEffectThumbnail(effectSwfLoader:Loader) : DisplayObject
		{
			try
			{
				var thumbnailClass:Class = effectSwfLoader.content.loaderInfo.applicationDomain.getDefinition("EFFECT_THUMBNAIL") as Class;
			}
			catch (e:Error)
			{
				return null;
			}
			var thumbnail:DisplayObject = new thumbnailClass();
			return thumbnail;
		}

		public static function extractSymbolFromLoader(loader:Loader, symbolName:String) : DisplayObject
		{
			try
			{
				var symbolClass:Class = loader.content.loaderInfo.applicationDomain.getDefinition(symbolName) as Class;
			}
			catch (e:Error)
			{
				return null;
			}
			var obj:DisplayObject = new symbolClass();
			return obj;
		}

		public static function getMultipleInstance(iObj:DisplayObject, pattern:*) : Array
		{
			var instances:Array = new Array();
			getMultipleInstanceRecursive(iObj, pattern, instances);
			return instances;
		}

		/**
		 * Looks for matches to `pattern` in a display object and its children.
		 */
		private static function getMultipleInstanceRecursive(iObj:DisplayObject, pattern:*, instances:Array) : void
		{
			if (iObj.name.match(pattern) != null)
			{
				instances.push(iObj);
			}
			if (iObj is DisplayObjectContainer)
			{
				var container:DisplayObjectContainer = iObj as DisplayObjectContainer;
				for (var i:int = 0; i < container.numChildren; i++)
				{
					var child:DisplayObject = container.getChildAt(i);
					if (child)
					{
						getMultipleInstanceRecursive(child, pattern, instances);
					}
				}
			}
		}

		public static function centerAlignObj(param1:DisplayObject, param2:Rectangle, param3:Boolean) : void
		{
			var _loc4_:Rectangle = param1.getRect(param1);
			var _loc5_:Number = 1;
			if (param3)
			{
				if (param2.width / param2.height > _loc4_.width / _loc4_.height)
				{
					_loc5_ = param2.height / _loc4_.height;
				}
				else
				{
					_loc5_ = param2.width / _loc4_.width;
				}
				param1.scaleX = param1.scaleX * _loc5_;
				param1.scaleY = param1.scaleY * _loc5_;
			}
			var _loc6_:Point = new Point();
			_loc6_.x = (_loc4_.left + _loc4_.right) / 2 * _loc5_;
			_loc6_.y = (_loc4_.top + _loc4_.bottom) / 2 * _loc5_;
			var _loc7_:Point = new Point();
			_loc7_.x = (param2.left + param2.right) / 2;
			_loc7_.y = (param2.top + param2.bottom) / 2;
			var _loc8_:Point = _loc7_.subtract(_loc6_);
			param1.x = param1.x + _loc8_.x;
			param1.y = param1.y + _loc8_.y;
		}

		public static function getInstance(param1:DisplayObjectContainer, param2:String) : DisplayObjectContainer
		{
			var _loc3_:DisplayObjectContainer = null;
			var _loc4_:DisplayObjectContainer = null;
			var _loc5_:int = 0;
			if (param1 == null)
			{
				return null;
			}
			if (param1.name == param2)
			{
				return param1;
			}
			_loc5_ = 0;
			while (_loc5_ < param1.numChildren)
			{
				if (param1.getChildAt(_loc5_) is DisplayObjectContainer)
				{
					_loc4_ = DisplayObjectContainer(param1.getChildAt(_loc5_));
					_loc3_ = UtilPlain.getInstance(_loc4_, param2);
					if (_loc3_ != null)
					{
						return _loc3_;
					}
				}
				_loc5_++;
			}
			return null;
		}

		public static function getMouth(param1:DisplayObjectContainer) : DisplayObjectContainer
		{
			var _loc2_:DisplayObjectContainer = null;
			var _loc3_:DisplayObjectContainer = null;
			var _loc4_:int = 0;
			if (param1 == null)
			{
				return null;
			}
			if (param1.name == UtilPlain.THE_MOUTH && param1.getChildByName(AnimeConstants.MOVIECLIP_DEFAULT_MOUTH) != null)
			{
				return param1;
			}
			_loc4_ = 0;
			while (_loc4_ < param1.numChildren)
			{
				if (param1.getChildAt(_loc4_) is DisplayObjectContainer)
				{
					_loc3_ = DisplayObjectContainer(param1.getChildAt(_loc4_));
					_loc2_ = UtilPlain.getMouth(_loc3_);
					if (_loc2_ != null)
					{
						return _loc2_;
					}
				}
				_loc4_++;
			}
			return null;
		}

		public static function getHead(param1:DisplayObjectContainer) : DisplayObjectContainer
		{
			var _loc2_:DisplayObjectContainer = null;
			var _loc3_:DisplayObjectContainer = null;
			var _loc4_:int = 0;
			if (param1 == null)
			{
				return null;
			}
			if (param1.name == UtilPlain.THE_HEAD && param1.getChildByName(AnimeConstants.MOVIECLIP_DEFAULT_HEAD) != null)
			{
				return param1;
			}
			_loc4_ = 0;
			while (_loc4_ < param1.numChildren)
			{
				if (param1.getChildAt(_loc4_) is DisplayObjectContainer)
				{
					_loc3_ = DisplayObjectContainer(param1.getChildAt(_loc4_));
					_loc2_ = UtilPlain.getHead(_loc3_);
					if (_loc2_ != null)
					{
						return _loc2_;
					}
				}
				_loc4_++;
			}
			return null;
		}

		public static function getTail(param1:DisplayObjectContainer) : DisplayObjectContainer
		{
			var _loc2_:DisplayObjectContainer = null;
			var _loc3_:DisplayObjectContainer = null;
			var _loc4_:int = 0;
			if (param1 == null)
			{
				return null;
			}
			if (param1.name == UtilPlain.THE_TAIL && param1.getChildByName(AnimeConstants.MOVIECLIP_DEFAULT_TAIL) != null)
			{
				return param1;
			}
			_loc4_ = 0;
			while (_loc4_ < param1.numChildren)
			{
				if (param1.getChildAt(_loc4_) is DisplayObjectContainer)
				{
					_loc3_ = DisplayObjectContainer(param1.getChildAt(_loc4_));
					_loc2_ = UtilPlain.getTail(_loc3_);
					if (_loc2_ != null)
					{
						return _loc2_;
					}
				}
				_loc4_++;
			}
			return null;
		}

		public static function getProp(param1:DisplayObjectContainer) : DisplayObjectContainer
		{
			var _loc2_:DisplayObjectContainer = null;
			var _loc3_:DisplayObjectContainer = null;
			var _loc4_:int = 0;
			if (param1 == null)
			{
				return null;
			}
			if (param1.name == UtilPlain.THE_PROP)
			{
				return param1;
			}
			_loc4_ = 0;
			while (_loc4_ < param1.numChildren)
			{
				if (param1.getChildAt(_loc4_) is DisplayObjectContainer)
				{
					_loc3_ = DisplayObjectContainer(param1.getChildAt(_loc4_));
					_loc2_ = UtilPlain.getProp(_loc3_);
					if (_loc2_ != null)
					{
						return _loc2_;
					}
				}
				_loc4_++;
			}
			return null;
		}

		public static function flipObj(param1:DisplayObject, param2:Boolean = false, param3:Boolean = false) : Number
		{
			if (param2)
			{
				param1.scaleX = Math.abs(param1.scaleX);
			}
			else if (param3)
			{
				param1.scaleX = -1 * Math.abs(param1.scaleX);
			}
			else
			{
				param1.scaleX = param1.scaleX * -1;
			}
			var _loc4_:DisplayObject = null;
			var _loc5_:DisplayObject = null;
			var _loc6_:DisplayObjectContainer = param1 as DisplayObjectContainer;
			if (_loc6_ != null)
			{
				_loc4_ = UtilPlain.getInstance(_loc6_, THE_CHAR);
				_loc5_ = UtilPlain.getInstance(_loc6_, THE_CHAR_FLIP);
			}
			if (_loc5_ != null)
			{
				if (_loc6_.scaleX < 0)
				{
					_loc4_.visible = false;
					_loc5_.visible = true;
				}
				else
				{
					_loc4_.visible = true;
					_loc5_.visible = false;
				}
			}
			return param1.scaleX;
		}

		public static function isObjectFlipped(param1:DisplayObjectContainer) : Boolean
		{
			if (param1.scaleX >= 0)
			{
				return false;
			}
			return true;
		}

		/**
		 * Recursively traverses a family of display objects and applies a function.
		 * @param obj A family of display objects
		 * @param treatment A function to run on each display object
		 * @param exclusions A list of display object names to not run the treatment on
		 */
		public static function transverseFamily(obj:DisplayObject, treatment:Function, exclusions:Array = null) : void
		{
			treatment(obj);
			if (obj is DisplayObjectContainer)
			{
				var container:DisplayObjectContainer = DisplayObjectContainer(obj);
				var i:int;
				for (i = 0; i < container.numChildren; i++)
				{
					var child:DisplayObject = container.getChildAt(i);
					if (!(exclusions && child && exclusions.indexOf(child.name) > -1))
					{
						UtilPlain.transverseFamily(child, treatment, exclusions);
					}
				}
			}
		}

		/**
		 * Traverses the family of display objects with a check.
		 */
		private static function transverseFamilyWithCheck(obj:DisplayObject, treatment:Function) : void
		{
			treatment(obj);
			if (obj is DisplayObjectContainer)
			{
				var container:DisplayObjectContainer = obj as DisplayObjectContainer;
				var i:int;
				for (i = 0; i < container.numChildren; i++)
				{
					var data:Object = new Object();
					data["rootNode"] = obj;
					data["treatment"] = treatment;
					data["targetIndex"] = i;
					data["targetParent"] = obj;
					var agent:EventListenerWithData = new EventListenerWithData(null, data);
					UtilPlain.transverseFamilyListener(agent);
				}
			}
		}

		private static function transverseFamilyListener(listenerObj:EventListenerWithData) : void
		{
			var rootNode:DisplayObjectContainer = listenerObj.data["rootNode"] as DisplayObjectContainer;
			var treatment:Function = listenerObj.data["treatment"];
			var targetIndex:int = listenerObj.data["targetIndex"];
			var targetParent:DisplayObjectContainer = listenerObj.data["targetParent"] as DisplayObjectContainer;
			var targetNode:DisplayObject = null;
			try
			{
				targetNode = targetParent.getChildAt(targetIndex);
			}
			catch (e:Error)
			{
				return;
			}
			targetParent.removeEventListener(Event.ADDED, listenerObj.listener);
			var data:Object;
			var agent:EventListenerWithData;
			if (targetNode != null)
			{
				treatment(targetNode);
				if (targetNode is DisplayObjectContainer)
				{
					var container:DisplayObjectContainer = targetNode as DisplayObjectContainer;
					var i:int;
					for (i = 0; i < container.numChildren; i++)
					{
						data = new Object();
						data["rootNode"] = rootNode;
						data["treatment"] = treatment;
						data["targetIndex"] = i;
						data["targetParent"] = container;
						agent = new EventListenerWithData(UtilPlain.transverseFamilyListener, data);
						transverseFamilyListener(agent);
					}
				}
			}
			else
			{
				data = new Object();
				data["rootNode"] = rootNode;
				data["treatment"] = treatment;
				data["targetIndex"] = targetIndex;
				data["targetParent"] = targetParent;
				agent = new EventListenerWithData(UtilPlain.transverseFamilyListener, data);
				targetParent.addEventListener(Event.ADDED, agent.listener);
			}
		}

		/**
		 * Checks if the whole family of display objects is ready.
		 */
		private static function isWholeFamilyReady(obj:DisplayObject) : Boolean
		{
			if (obj == null)
			{
				return false;
			}
			if (obj is DisplayObjectContainer)
			{
				var container:DisplayObjectContainer = obj as DisplayObjectContainer;
				var i:int;
				for (i = 0; i < container.numChildren; i++)
				{
					if (!UtilPlain.isWholeFamilyReady(container.getChildAt(i)))
					{
						return false;
					}
				}
			}
			return true;
		}

		/**
		 * Stops a family of DisplayObjects at the first frame.
		 */
		public static function gotoAndStopFamilyAt1(iObj:DisplayObject) : void
		{
			var treatment:Function = function (obj:DisplayObject):void
			{
				if (obj is MovieClip)
				{
					var clip:MovieClip = obj as MovieClip;
					clip.gotoAndStop(1);
				}
			};
			UtilPlain.transverseFamilyWithCheck(iObj, treatment);
		}

		/**
		 * Increments a family of DisplayObjects by one frame.
		 */
		public static function nextFrameAtFamily(iObj:DisplayObject) : void
		{
			var treatment:Function = function (obj:DisplayObject):void
			{
				if (obj is MovieClip)
				{
					var clip:MovieClip = obj as MovieClip;
					if (clip.currentFrame >= clip.totalFrames)
					{
						clip.gotoAndStop(1);
					}
					else
					{
						clip.nextFrame();
					}
				}
			};
			UtilPlain.transverseFamilyWithCheck(iObj, treatment);
		}

		/**
		 * Copies all children from copyFrom to the end of copyTo
		 */
		public static function switchParent(copyFrom:DisplayObjectContainer, copyTo:DisplayObjectContainer) : void
		{
			var ctnr2Length:int = copyTo.numChildren;
			var ctnrInd:int = copyFrom.numChildren - 1;
			for (; ctnrInd >= 0; ctnrInd--)
			{
				copyTo.addChildAt(copyFrom.getChildAt(ctnrInd), ctnr2Length);
			}
		}

		/**
		 * checks if two time ranges overlap
		 */
		public static function isTimeRangesOverlap(start1:Number, end1:Number, start2:Number, end2:Number) : Boolean
		{
			if (start1 >= start2 && start1 <= end2)
			{
				return true;
			}
			if (end1 >= start2 && end1 <= end2)
			{
				return true;
			}
			if (start2 >= start1 && start2 <= end1)
			{
				return true;
			}
			if (end2 >= start1 && end2 <= end1)
			{
				return true;
			}
			return false;
		}

		public static function getRelativeProperty(targetObj:DisplayObject, referenceContainer:DisplayObjectContainer, property:String) : Number
		{
			if (targetObj == null)
			{
				throw new Error("The target Obj is null.");
			}
			if (referenceContainer == null)
			{
				throw new Error("The reference container is null.");
			}
			var _loc4_:DisplayObject = targetObj;
			var _loc5_:Number = 1;
			while (true)
			{
				switch (property)
				{
					case PROPERTY_SCALEX:
						_loc5_ = _loc5_ * _loc4_.scaleX;
						break;
					case PROPERTY_SCALEY:
						_loc5_ = _loc5_ * _loc4_.scaleY;
				}
				_loc4_ = _loc4_.parent;
				if (_loc4_ == null)
				{
					break;
				}
				if (!(_loc4_ != referenceContainer && _loc4_ != targetObj.stage))
				{
					if (targetObj.stage != referenceContainer && _loc4_ == targetObj.stage)
					{
						throw new Error("referenceContainer does not contain targetObj");
					}
					return _loc5_;
				}
			}
			throw new Error("Reference Container is not found during reverse-parent finding");
		}

		/**
		 * randomizes all keys in an array
		 */
		public static function randomizeArray(array:Array) : void
		{
			var length:int = array.length;
			for (var i:int = 0; i < length; i++)
			{
				var swapWithI:int = Math.floor(Math.random() * length);
				var originalObj:Object = array[i];
				array[i] = array[swapWithI];
				array[swapWithI] = originalObj;
			}
		}

		/**
		 * returns a random number within a range of numbers
		 */
		public static function randomNumberRange(start:Number, end:Number) : Number
		{
			end++;
			return Math.floor(start + Math.random() * (end - start));
		}

		/**
		 * Transfers all entires in an asset zip into an object.
		 * returns `{"xml": <desc.xml>, "imagedata": <*.swf>[]}`
		 */
		public static function convertZipAsImagedataObject(zip:ZipFile) : Object
		{
			var files:UtilHashArray = new UtilHashArray();
			var imagedata:Object = new Object();
			for (var i:int = 0; i < zip.size; i++)
			{
				var entry:ZipEntry = zip.entries[i];
				if (entry.name == "desc.xml")
				{
					imagedata["xml"] = new XML(zip.getInput(entry).toString());
				}
				else if (entry.name.substr(entry.name.length - 3, 3).toLowerCase() == "swf")
				{
					var type:String = entry.name.split(".")[1];
					var input:ByteArray = zip.getInput(entry);
					if (CcLibConstant.ALL_LIBRARY_TYPES.indexOf(type) == -1)
					{
						var crypto:UtilCrypto = new UtilCrypto();
						crypto.decrypt(input);
					}
					files.push(entry.name, input);
				}
			}
			imagedata["imageData"] = files;
			return imagedata;
		}
	}
}

import flash.events.Event;

class EventListenerWithData
{
	public var data:Object;
	public var event:Event;
	private var callBack:Function;

	function EventListenerWithData(callback:Function, data:Object = null)
	{
		super();
		this.callBack = callback;
		this.data = data;
	}

	public function listener(event:Event) : void
	{
		this.event = event;
		this.callBack(this);
	}
}
