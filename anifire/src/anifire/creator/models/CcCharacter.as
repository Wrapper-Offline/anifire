package anifire.creator.models
{
	import anifire.constant.CcLibConstant;
	import anifire.util.UtilHashArray;
	import com.adobe.crypto.MD5;
	import flash.geom.Point;
	
	public class CcCharacter
	{
		public static const XML_NODE_NAME:String = "cc_char";
		private var _userChosenColors:UtilHashArray;
		private var _userChosenComponents:Array;
		private var _userChosenLibraries:Array;
		private var _bodyShape:CcBodyShape;
		private var _assetId:String = "";
		private var _templateId:String = "";
		private var _templateMD5:String = "";
		private var _currentTheme:CcTheme;
		private var _name:String;
		private var _createDateTime:String = "";
		private var _tags:Array;
		private var _category:String = null;
		private var _headScaleX:Number = 1;
		private var _headScaleY:Number = 1;
		private var _headDX:Number = 0;
		private var _headDY:Number = 0;
		private var _scaleX:Number = 1;
		private var _scaleY:Number = 1;
		private var _ver:Number = 1;
		private var _isRandom:Boolean = false;
		
		public function CcCharacter()
		{
			this._userChosenColors = new UtilHashArray();
			this._userChosenComponents = new Array();
			this._userChosenLibraries = new Array();
			this._tags = new Array();
			super();
		}
		
		public static function getComponentScaling(param1:String) : Number
		{
			if(param1 == "female")
			{
				return CcLibConstant.COMPONENT_SCALE_FEMALE;
			}
			return CcLibConstant.COMPONENT_SCALE_MALE;
		}
		
		public function get isRandom() : Boolean
		{
			return this._isRandom;
		}
		
		public function set isRandom(param1:Boolean) : void
		{
			this._isRandom = param1;
		}
		
		public function get category() : String
		{
			var _loc1_:String = null;
			var _loc2_:String = null;
			var _loc3_:int = 0;
			if(this._category == null)
			{
				_loc1_ = "_category_";
				this._category = "";
				_loc3_ = 0;
				while(_loc3_ < this.tags.length)
				{
					_loc2_ = this.tags[_loc3_] as String;
					if(_loc2_.substr(0,_loc1_.length) == _loc1_)
					{
						this._category = _loc2_.substr(_loc1_.length);
						break;
					}
					_loc3_++;
				}
			}
			return this._category;
		}
		
		public function get tags() : Array
		{
			return this._tags;
		}
		
		public function get name() : String
		{
			return this._name;
		}
		
		public function set currentTheme(param1:CcTheme) : void
		{
			this._currentTheme = param1;
		}
		
		public function get currentTheme() : CcTheme
		{
			return this._currentTheme;
		}
		
		public function get templateId() : String
		{
			return this._templateId;
		}
		
		public function get copiedFromTemplate() : Boolean
		{
			return this._templateId != "";
		}
		
		public function markAsTemplate() : void
		{
			this._templateId = this.assetId;
			this._templateMD5 = MD5.hash(this.serialize());
		}
		
		public function isTemplateModified() : Boolean
		{
			return this.copiedFromTemplate && this._templateMD5 != MD5.hash(this.serialize());
		}
		
		public function get assetId() : String
		{
			return this._assetId;
		}
		
		public function set assetId(param1:String) : void
		{
			this._assetId = param1;
		}
		
		public function set bodyShape(param1:CcBodyShape) : void
		{
			this._bodyShape = param1;
		}
		
		public function get bodyShape() : CcBodyShape
		{
			return this._bodyShape;
		}
		
		public function get createDateTime() : String
		{
			return this._createDateTime;
		}
		
		public function get thumbnailActionId() : String
		{
			return this.bodyShape.thumbnailActionId;
		}
		
		public function set headScale(param1:Point) : void
		{
			this._headScaleX = param1.x;
			this._headScaleY = param1.y;
		}
		
		public function get headScale() : Point
		{
			return new Point(this._headScaleX,this._headScaleY);
		}
		
		public function set bodyScale(param1:Point) : void
		{
			this._scaleX = param1.x;
			this._scaleY = param1.y;
		}
		
		public function get bodyScale() : Point
		{
			return new Point(this._scaleX,this._scaleY);
		}
		
		public function set headShift(param1:Point) : void
		{
			this._headDX = param1.x;
			this._headDY = param1.y;
		}
		
		public function get headShift() : Point
		{
			return new Point(this._headDX,this._headDY);
		}
		
		public function set ver(param1:Number) : void
		{
			this._ver = param1;
		}
		
		public function get ver() : Number
		{
			return this._ver;
		}

		/**
		 * Returns a clone of the CcCharacter instance.
		 */
		public function clone() : CcCharacter
		{
			var clone:CcCharacter = new CcCharacter();
			clone.currentTheme = this.currentTheme;
			clone.assetId = this.assetId;
			clone.bodyShape = this.bodyShape;
			clone._name = this._name;
			clone._tags = this.tags.slice();
			clone.ver = this._ver;
			clone._templateId = this._templateId;
			clone._templateMD5 = this._templateMD5;
			var index:int = 0;
			for (index = 0; index < this.getUserChosenColorNum(); index++)
			{
				var color:CcColor = this.getUserChosenColorByIndex(index);
				clone.addUserChosenColor(color.clone());
			}
			for (index = 0; index < this.getUserChosenComponentSize(); index++)
			{
				var component:CcComponent = this.getUserChosenComponentByIndex(index);
				clone.addUserChosenComponent(component.clone());
			}
			for (index = 0; index < this.getUserChosenLibraryNum(); index++)
			{
				var library:CcLibrary = this.getUserChosenLibraryByIndex(index);
				clone.addUserChosenLibrary(library.clone());
			}
			clone.bodyScale = this.bodyScale;
			clone.headScale = this.headScale;
			clone.headShift = this.headShift;
			return clone;
		}

		/**
		 * Copies all properties from an existing CcCharacter
		 * instance to this one.
		 */
		public function cloneFromSourceToMe(source:CcCharacter) : void
		{
			this.currentTheme = source.currentTheme;
			this.removeAllUserChosenComponent();
			var index:int = 0;
			for (index = 0; index < source.getUserChosenComponentSize(); index++)
			{
				this.addUserChosenComponent(source.getUserChosenComponentByIndex(index));
			}
			this.removeAllUserChosenColors();
			for (index = 0; index < source.getUserChosenColorNum(); index++)
			{
				this.addUserChosenColor(source.getUserChosenColorByIndex(index));
			}
			this.removeAllUserChosenLibraries();
			for (index = 0; index < source.getUserChosenLibraryNum(); index++)
			{
				this.addUserChosenLibrary(source.getUserChosenLibraryByIndex(index));
			}
			this.bodyShape = source.bodyShape;
			this.assetId = source.assetId;
			this._name = source._name;
			this._tags = source.tags.slice();
			this._ver = source.ver;
			this._templateId = source._templateId;
			this._templateMD5 = source._templateMD5;
			this.bodyScale = source.bodyScale;
			this.headScale = source.headScale;
			this.headShift = source.headShift;
		}

		/**
		 * Returns a library at the specified index.
		 * @param index Index of the library to return.
		 */
		public function getUserChosenLibraryByIndex(index:Number) : CcLibrary
		{
			return this._userChosenLibraries[index];
		}

		/**
		 * Returns the number of libraries the character utilizes.
		 */
		public function getUserChosenLibraryNum() : Number
		{
			return this._userChosenLibraries.length;
		}

		/**
		 * Clears all libraries.
		 */
		public function removeAllUserChosenLibraries() : void
		{
			this._userChosenLibraries.splice(0, this._userChosenLibraries.length);
		}

		/**
		 * Adds a library.
		 * @param library Library to add.
		 */
		public function addUserChosenLibrary(library:CcLibrary) : void
		{
			this.removeUserChosenLibraryByType(library.type);
			this._userChosenLibraries.push(library);
		}

		/**
		 * Returns a library with the specified type.
		 * @param type Library type to return.
		 */
		public function getUserChosenLibraryByType(type:String) : CcLibrary
		{
			var index:int = int(this._userChosenLibraries.length - 1);
			for (; index >= 0; index--)
			{
				var library:CcLibrary = this._userChosenLibraries[index] as CcLibrary;
				if (library.type == type)
				{
					return library;
				}
			}
			return null;
		}

		/**
		 * Removes a library with the specified type.
		 * @param type Library type to remove.
		 */
		public function removeUserChosenLibraryByType(type:String) : void
		{
			var index:int = int(this._userChosenLibraries.length - 1);
			for (; index >= 0; index--)
			{
				var library:CcLibrary = this._userChosenLibraries[index] as CcLibrary;
				if (library.type == type)
				{
					this._userChosenLibraries.splice(index, 1);
				}
			}
		}

		/**
		 * Adds a color.
		 */
		public function addUserChosenColor(color:CcColor) : void
		{
			var id:String;
			if (color.ccComponent != null && CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(color.ccColorThumb.componentType) > -1)
			{
				id = color.ccComponent.id + color.ccColorThumb.internalId;
			}
			else
			{
				id = color.ccColorThumb.internalId;
			}
			this._userChosenColors.push(id, color);
		}

		/**
		 * Returns the amount of colors utilized by the character.
		 */
		public function getUserChosenColorNum() : Number
		{
			return this._userChosenColors.length;
		}

		/**
		 * Returns a color with the specified reference.
		 * @param type Color reference to return.
		 */
		public function getUserChosenColorByColorReference(ref:String) : CcColor
		{
			for (var index:int = 0; index < this._userChosenColors.length; index++)
			{
				var color:CcColor = this._userChosenColors.getValueByIndex(index) as CcColor;
				if (color.ccColorThumb.colorReference == ref)
				{
					return color;
				}
			}
			return null;
		}

		public function getUserChosenColorByComponentType(type:String) : Array
		{
			var colors:Array = new Array();
			// can we just rename "for" to "indexmaxx"
			for (var index:int = 0; index < this._userChosenColors.length; index++)
			{
				var color:CcColor = this._userChosenColors.getValueByIndex(index) as CcColor;
				if (color.ccColorThumb.componentType == type)
				{
					colors.push(color);
				}
			}
			return colors;
		}
		
		public function getUserChosenColorByIndex(param1:int) : CcColor
		{
			return this._userChosenColors.getValueByIndex(param1);
		}
		
		public function removeUserChosenColorByIndex(param1:int) : void
		{
			this._userChosenColors.remove(param1,1);
		}
		
		public function removeAllUserChosenColors() : void
		{
			this._userChosenColors.removeAll();
		}
		
		public function getUserChosenComponentSize() : Number
		{
			return this._userChosenComponents.length;
		}
		
		public function getUserChosenComponentByIndex(param1:int) : CcComponent
		{
			return this._userChosenComponents[param1] as CcComponent;
		}
		
		public function getUserChosenComponentByComponentType(param1:String) : Array
		{
			var _loc3_:CcComponent = null;
			var _loc2_:Array = new Array();
			var _loc4_:int = 0;
			while(_loc4_ < this._userChosenComponents.length)
			{
				_loc3_ = this._userChosenComponents[_loc4_] as CcComponent;
				if(_loc3_.componentThumb.type == param1)
				{
					_loc2_.push(_loc3_);
				}
				_loc4_++;
			}
			return _loc2_;
		}
		
		public function addUserChosenComponent(param1:CcComponent) : void
		{
			if(CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(param1.componentThumb.type) == -1)
			{
				this.removeUserChosenComponentByType(param1.componentThumb.type);
			}
			this._userChosenComponents.push(param1);
		}
		
		public function getFacialByFacialId(param1:String) : CcFacial
		{
			return this.currentTheme.getFacialById(param1);
		}

		/**
		 * does absolutely nothing don't even bother using it
		 */
		private function addBodyShapeThumb() : void
		{
		}
		
		public function removeUserChosenComponentByType(param1:String) : void
		{
			var _loc4_:CcLibrary = null;
			var _loc5_:CcComponent = null;
			var _loc2_:int = int(this._userChosenLibraries.length - 1);
			while(_loc2_ >= 0)
			{
				if((_loc4_ = this._userChosenLibraries[_loc2_] as CcLibrary).type == param1)
				{
					this._userChosenLibraries.splice(_loc2_,1);
				}
				_loc2_--;
			}
			var _loc3_:int = int(this._userChosenComponents.length - 1);
			while(_loc3_ >= 0)
			{
				if((_loc5_ = this._userChosenComponents[_loc3_] as CcComponent).componentThumb.type == param1)
				{
					this._userChosenComponents.splice(_loc3_,1);
				}
				_loc3_--;
			}
		}
		
		public function removeUserChosenComponentById(param1:String) : void
		{
			var _loc4_:CcComponent = null;
			var _loc5_:CcColor = null;
			var _loc2_:int = int(this._userChosenComponents.length - 1);
			while(_loc2_ >= 0)
			{
				if((_loc4_ = this._userChosenComponents[_loc2_] as CcComponent).id == param1)
				{
					this._userChosenComponents.splice(_loc2_,1);
				}
				_loc2_--;
			}
			var _loc3_:int = this._userChosenColors.length - 1;
			while(_loc3_ >= 0)
			{
				if((_loc5_ = this._userChosenColors.getValueByIndex(_loc3_) as CcColor).ccComponent != null && _loc5_.ccComponent.id == param1)
				{
					this._userChosenColors.remove(_loc3_,1);
				}
				_loc3_--;
			}
		}
		
		public function removeAllUserChosenComponent() : void
		{
			this._userChosenComponents.splice(0,this._userChosenComponents.length);
		}
		
		public function transformBodyShape(param1:CcBodyShape) : void
		{
			var _loc2_:CcComponent = null;
			var _loc3_:CcComponent = null;
			var _loc4_:String = null;
			var _loc5_:CcComponentThumb = null;
			var _loc6_:String = null;
			var _loc7_:UtilHashArray = null;
			var _loc8_:CcComponentThumb = null;
			if(param1.id != this.bodyShape.id)
			{
				this._bodyShape = param1;
				_loc2_ = new CcComponent();
				_loc2_.componentThumb = CcComponentThumb.createBodyShapeComponentThumb(this.bodyShape);
				this.addUserChosenComponent(_loc2_);
				_loc3_ = new CcComponent();
				_loc4_ = this.ver < 2 ? CcLibConstant.COMPONENT_TYPE_SKELETON : CcLibConstant.COMPONENT_TYPE_FREEACTION;
				_loc5_ = this.bodyShape.getComponentThumbByType(_loc4_).getValueByIndex(0) as CcComponentThumb;
				_loc3_.componentThumb = _loc5_;
				this.addUserChosenComponent(_loc3_);
				for each(_loc6_ in CcLibConstant.USER_CHOOSE_ABLE_BODY_COMPONENT_TYPES)
				{
					if(_loc6_ != CcLibConstant.COMPONENT_TYPE_BODYSHAPE)
					{
						if(this.ver == 1)
						{
							if(CcLibConstant.ALL_LIBRARY_TYPES.indexOf(_loc6_) > -1)
							{
								continue;
							}
						}
						else
						{
							if(CcLibConstant.ALL_LIBRARY_TYPES.indexOf(_loc6_) == -1)
							{
								continue;
							}
							if(CcLibConstant.HEAD_RELATED_LIBRARY.indexOf(_loc6_) > -1)
							{
								continue;
							}
						}
						_loc7_ = new UtilHashArray();
						if(this.bodyShape.getComponentThumbByType(_loc6_))
						{
							_loc8_ = this.bodyShape.getComponentThumbByType(_loc6_).getValueByIndex(0) as CcComponentThumb;
							_loc7_.push(_loc8_.componentId,_loc8_);
							this.randomlyChooseComponentInArray(_loc7_,this.bodyShape.bodyType);
						}
					}
				}
			}
		}
		
		public function randomize(param1:CcTheme, param2:String, param3:CcBodyShape = null) : void
		{
			var _loc4_:int = 0;
			var _loc5_:Boolean = false;
			var _loc6_:CcCharacter = null;
			if(Math.random() > CcLibConstant.PROBABILITY_RANDOM_FROM_PRE_MADE_CHAR)
			{
				_loc5_ = true;
			}
			else if(Boolean(param1.preMadeChars) && param1.preMadeChars.length <= 0)
			{
				_loc5_ = true;
			}
			else
			{
				_loc5_ = true;
				if(param1.preMadeChars)
				{
					_loc4_ = 0;
					while(_loc4_ < param1.preMadeChars.length)
					{
						if((_loc6_ = param1.preMadeChars[_loc4_] as CcCharacter).bodyShape.bodyType == param2)
						{
							_loc5_ = false;
							break;
						}
						_loc4_++;
					}
				}
			}
			if(_loc5_)
			{
				this.randomizeEverythingRandomlly(param1,param2,param3);
			}
			else
			{
				this.randomizeFromPreMadeChar(param1,param2);
			}
			this._isRandom = true;
		}
		
		private function randomizeFromPreMadeChar(param1:CcTheme, param2:String) : void
		{
			var _loc4_:CcCharacter = null;
			var _loc3_:Array = new Array();
			var _loc5_:int = 0;
			while(_loc5_ < param1.preMadeChars.length)
			{
				if((_loc4_ = param1.preMadeChars[_loc5_] as CcCharacter).bodyShape.bodyType == param2 && CcLibConstant.CHAR_TAG_MATCH_CURR_THEME(_loc4_.tags))
				{
					_loc3_.push(_loc4_);
				}
				_loc5_++;
			}
			var _loc6_:int = Math.floor(Math.random() * _loc3_.length);
			(_loc4_ = _loc3_[_loc6_] as CcCharacter).markAsTemplate();
			var _loc7_:UtilHashArray;
			(_loc7_ = new UtilHashArray()).push(param1.id,param1);
			this.cloneFromSourceToMe(_loc4_);
			this.assetId = "";
		}
		
		private function randomizeEverythingRandomlly(param1:CcTheme, param2:String, param3:CcBodyShape = null) : void
		{
			var _loc4_:String = null;
			var _loc5_:UtilHashArray = null;
			var _loc6_:CcComponentThumb = null;
			var _loc7_:CcColorThumb = null;
			var _loc8_:CcColor = null;
			var _loc10_:int = 0;
			var _loc13_:CcComponentThumb = null;
			var _loc14_:Number = NaN;
			var _loc9_:Array = param1.getBodyShapesByShapeType(param2);
			this._currentTheme = param1;
			this.removeAllUserChosenColors();
			this.removeAllUserChosenComponent();
			this.removeAllUserChosenLibraries();
			_loc10_ = 0;
			while(_loc10_ < param1.getColorThumbNum())
			{
				_loc7_ = param1.getColorThumbByIndex(_loc10_);
				if(CcLibConstant.ALL_MULTIPLE_COMPONENT_TYPES.indexOf(_loc7_.componentType) == -1)
				{
					(_loc8_ = new CcColor()).ccColorThumb = _loc7_;
					_loc8_.colorValue = _loc7_.colorChoices[Math.floor(Math.random() * _loc7_.colorChoices.length)];
					this.addUserChosenColor(_loc8_);
				}
				_loc10_++;
			}
			if(param3 == null)
			{
				this._bodyShape = _loc9_[Math.floor(Math.random() * _loc9_.length)] as CcBodyShape;
			}
			else
			{
				this._bodyShape = param3;
			}
			var _loc11_:CcComponent;
			(_loc11_ = new CcComponent()).componentThumb = CcComponentThumb.createBodyShapeComponentThumb(this.bodyShape);
			this.addUserChosenComponent(_loc11_);
			var _loc12_:CcComponent = new CcComponent();
			switch(this.ver)
			{
				case 2:
					_loc13_ = this.bodyShape.getComponentThumbByType(CcLibConstant.COMPONENT_TYPE_FREEACTION).getValueByIndex(0) as CcComponentThumb;
					break;
				default:
					_loc13_ = this.bodyShape.getComponentThumbByType(CcLibConstant.COMPONENT_TYPE_SKELETON).getValueByIndex(0) as CcComponentThumb;
			}
			_loc12_.componentThumb = _loc13_;
			this.addUserChosenComponent(_loc12_);
			for each(_loc4_ in CcLibConstant.USER_CHOOSE_ABLE_BODY_COMPONENT_TYPES)
			{
				_loc14_ = CcLibConstant.GET_COMPONENT_TYPE_OCCURANCE_PROBABILITY(_loc4_);
				if(Math.random() < _loc14_)
				{
					_loc5_ = this.bodyShape.getComponentThumbByType(_loc4_);
					this.randomlyChooseComponentInArray(_loc5_,this.bodyShape.bodyType);
				}
			}
			for each(_loc4_ in CcLibConstant.USER_CHOOSE_ABLE_HEAD_COMPONENT_TYPES)
			{
				_loc14_ = CcLibConstant.GET_COMPONENT_TYPE_OCCURANCE_PROBABILITY(_loc4_);
				if(Math.random() < _loc14_)
				{
					_loc5_ = param1.getComponentThumbByType(_loc4_);
					this.randomlyChooseComponentInArray(_loc5_,this.bodyShape.bodyType);
				}
			}
		}
		
		private function randomlyChooseComponentInArray(param1:UtilHashArray, param2:String) : void
		{
			var _loc3_:int = 0;
			var _loc4_:CcComponentThumb = null;
			var _loc5_:CcComponent = null;
			var _loc6_:CcColorThumb = null;
			var _loc7_:CcColor = null;
			var _loc8_:CcLibrary = null;
			if(param1 != null && param1.length > 0)
			{
				param1 = param1.clone();
				_loc3_ = param1.length - 1;
				while(_loc3_ >= 0)
				{
					if(!(_loc4_ = param1.getValueByIndex(_loc3_) as CcComponentThumb).is_randomable || !_loc4_.enable)
					{
						param1.remove(_loc3_,1);
					}
					_loc3_--;
				}
				_loc4_ = param1.getValueByIndex(Math.random() * param1.length) as CcComponentThumb;
				_loc5_ = new CcComponent();
				_loc5_.xscale = _loc5_.yscale = CcCharacter.getComponentScaling(param2);
				_loc5_.componentThumb = _loc4_;
				if(CcLibConstant.ALL_LIBRARY_TYPES.indexOf(_loc4_.type) > -1)
				{
					(_loc8_ = new CcLibrary()).type = _loc4_.type;
					_loc8_.theme_id = _loc4_.themeId;
					_loc8_.component_id = _loc4_.componentId;
					_loc8_.sharingPoint = _loc4_.sharingPoint;
					this.addUserChosenLibrary(_loc8_);
				}
				else
				{
					this.addUserChosenComponent(_loc5_);
				}
				_loc3_ = 0;
				while(_loc3_ < _loc4_.getMyOwnColorNum())
				{
					_loc6_ = _loc4_.getMyOwnColorByIndex(_loc3_);
					(_loc7_ = new CcColor()).ccColorThumb = _loc6_;
					_loc7_.colorValue = _loc6_.defaultColor;
					this.addUserChosenColor(_loc7_);
					_loc3_++;
				}
			}
		}
		
		public function serialize() : String
		{
			var _loc1_:int = 0;
			var _loc2_:* = "<" + XML_NODE_NAME + " xscale=\'" + this._scaleX + "\' yscale=\'" + this._scaleY + "\' hxscale=\'" + this._headScaleX + "\' hyscale=\'" + this._headScaleY + "\' headdx=\'" + this._headDX + "\' headdy=\'" + this._headDY + "\'>";
			_loc1_ = 0;
			while(_loc1_ < this.getUserChosenColorNum())
			{
				_loc2_ += this.getUserChosenColorByIndex(_loc1_).serialize();
				_loc1_++;
			}
			_loc1_ = 0;
			while(_loc1_ < this.getUserChosenComponentSize())
			{
				_loc2_ += this.getUserChosenComponentByIndex(_loc1_).serialize();
				_loc1_++;
			}
			_loc1_ = 0;
			while(_loc1_ < this.getUserChosenLibraryNum())
			{
				_loc2_ += this.getUserChosenLibraryByIndex(_loc1_).serialize();
				_loc1_++;
			}
			return _loc2_ + ("</" + XML_NODE_NAME + ">");
		}
		
		public function deserialize(charXml:XML, themeArray:UtilHashArray) : void
		{
			this._assetId = charXml.@aid;
			this._name = charXml.@name;
			this._createDateTime = charXml.@create || "";
			if (charXml.@tags != null)
			{
				var tagList:String = charXml.@tags;
				this._tags = tagList.split(",");
			}
			else
			{
				this._tags = new Array();
			}
			if (charXml.@xscale > 0 && charXml.@yscale > 0)
			{
				this._scaleX = Number(charXml.@xscale);
				this._scaleY = Number(charXml.@yscale);
			}
			if (charXml.@hxscale > 0 && charXml.@hyscale > 0)
			{
				this._headScaleX = Number(charXml.@hxscale);
				this._headScaleY = Number(charXml.@hyscale);
			}
			this._headDX = charXml.@headdx != 0 ? Number(charXml.@headdx) : 0;
			this._headDY = charXml.@headdy != 0 ? Number(charXml.@headdy) : 0;
			this.removeAllUserChosenComponent();
			var element:XML;
			for each (element in charXml.child(CcComponent.XML_NODE_NAME))
			{
				var _loc8_:String = CcComponent.getComponentThumbTypeFromXml(element);
				if (_loc8_ == CcLibConstant.COMPONENT_TYPE_BODYSHAPE)
				{
					var _loc9_:String = CcComponent.getComponentThemeIdFromXml(element);
					var _loc10_:String = CcComponent.getComponentIdFromXml(element);
					this._bodyShape = (themeArray.getValueByKey(_loc9_) as CcTheme).getBodyShapeByShapeId(_loc10_);
					this.currentTheme = themeArray.getValueByKey(_loc9_) as CcTheme;
					var _loc11_:CcComponent = new CcComponent();
					_loc11_.componentThumb = CcComponentThumb.createBodyShapeComponentThumb(this.bodyShape);
					this.addUserChosenComponent(_loc11_);
				}
				else
				{
					var _loc4_:CcComponent = new CcComponent();
					_loc4_.deserialize(element, themeArray);
					this.addUserChosenComponent(_loc4_);
				}
			}
			this.removeAllUserChosenColors();
			for each (element in charXml.child(CcColor.XML_NODE_NAME))
			{
				var _loc5_:CcColor = new CcColor();
				if (_loc5_.deserialize(element, this.currentTheme, this))
				{
					this.addUserChosenColor(_loc5_);
				}
			}
			this.removeAllUserChosenLibraries();
			for each (element in charXml.child(CcLibrary.XML_NODE_NAME))
			{
				var _loc6_:CcLibrary = new CcLibrary();
				var _loc12_:CcComponentThumb = this.currentTheme.getComponentThumbByInternalId(CcComponentThumb.generateInternalId(element.@type, element.@component_id));
				if (_loc12_)
				{
					element.@sharing = _loc12_.sharingPoint;
				}
				_loc6_.deserialize(element);
				this.addUserChosenLibrary(_loc6_);
			}
			if (this.getUserChosenLibraryNum() > 0)
			{
				this.ver = 2;
			}
			else
			{
				this.ver = 1;
			}
		}
		
		public function getComponentTypeOrdering() : Array
		{
			if(this._ver == 1)
			{
				return CcLibConstant.COMPONENT_TYPE_CHOOSER_ORDERING_VER1;
			}
			if(this._ver == 2)
			{
				return CcLibConstant.COMPONENT_TYPE_CHOOSER_ORDERING_VER2;
			}
			return null;
		}
	}
}
