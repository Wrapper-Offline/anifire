package anifire.browser.models
{
   import anifire.browser.core.CharThumb;
   import anifire.browser.core.Theme;
   import anifire.browser.events.ProductExplorerEvent;
   import anifire.browser.events.ProductGroupCollectionEvent;
   import anifire.constant.ServerConstants;
   import anifire.managers.AppConfigManager;
   import anifire.util.UtilURLStream;
   import anifire.util.UtilUser;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.utils.ByteArray;
   import mx.events.PropertyChangeEvent;
   
   public class CharacterExplorerCollection extends ProductGroupCollection
   {
      
      public static var categoryPattern:RegExp = /^\s*_?cat:(.+)\s*$/;
      
      private static var _configManager:AppConfigManager = AppConfigManager.instance;
       
      
      protected var _isCCTheme:Boolean;
      
      protected var _nextUserCharacterPage:int;
      
      private var _696739087hasMore:Boolean;
      
      protected var _theme:Theme;
      
      protected var _shouldLockTemplate:Boolean;
      
      public var searchResult:anifire.browser.models.SearchCollection;
      
      private var _1999925397userCharacters:anifire.browser.models.CharacterCollection;
      
      public var stockCharacters:anifire.browser.models.CharacterCollection;
      
      protected var storeCharacters:anifire.browser.models.CharacterCollection;
      
      protected var categoryList:Object;
      
      public function CharacterExplorerCollection(param1:Theme)
      {
         super();
         this.categoryList = {};
         this._theme = param1;
         this._shouldLockTemplate = UtilUser.userType == UtilUser.BASIC_USER && this._theme.isCCTheme && !this._theme.isBusinessTheme;
         this.hasMore = true;
         this._nextUserCharacterPage = 0;
         this.userCharacters = new anifire.browser.models.CharacterCollection("Custom characters");
         this.storeCharacters = new anifire.browser.models.CharacterCollection("Stock characters");
         this.storeCharacters.locked = this._shouldLockTemplate;
         this.storeCharacters.sortOrder = 1;
         this.stockCharacters = new anifire.browser.models.CharacterCollection("All stock characters");
         addCollection(this.storeCharacters);
         addCollection(this.stockCharacters);
      }
      
      public function get nextUserCharacterPage() : int
      {
         return this._nextUserCharacterPage;
      }
      
      override public function addProduct(param1:ThumbModel, param2:Boolean = true) : Boolean
      {
         var _loc4_:anifire.browser.models.CharacterCollection = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:Object = null;
         var _loc9_:Array = null;
         var _loc3_:CharThumb = param1.thumb as CharThumb;
         param1.copyable = !this._shouldLockTemplate && this._theme.isUserCreateEnable;
         if(param1.isStoreCharacter)
         {
            param1.locked = this._shouldLockTemplate || _loc3_.locked && !this._theme.isBusinessTheme;
            if(param1.thumb.tags)
            {
               _loc6_ = int((_loc9_ = param1.thumb.tags.split(",")).length);
               _loc5_ = 0;
               while(_loc5_ < _loc6_)
               {
                  if(_loc8_ = categoryPattern.exec(_loc9_[_loc5_]))
                  {
                     _loc7_ = String(_loc8_[1]);
                     break;
                  }
                  _loc5_++;
               }
            }
            else
            {
               _loc6_ = int(param1.thumb.sysTags.length);
               _loc5_ = 0;
               while(_loc5_ < _loc6_)
               {
                  if(_loc8_ = categoryPattern.exec(param1.thumb.sysTags[_loc5_]))
                  {
                     _loc7_ = String(_loc8_[1]);
                     break;
                  }
                  _loc5_++;
               }
            }
            if(_loc7_)
            {
               (_loc4_ = this.getCategoryCollection(_loc7_)).addProduct(param1);
            }
            else
            {
               this.storeCharacters.addProduct(param1,param2);
            }
            this.stockCharacters.addProduct(param1,param2);
         }
         else
         {
            param1.locked = _loc3_.locked && !this._theme.isBusinessTheme;
            this.userCharacters.addProduct(param1,param2);
         }
         registerProduct(param1);
         dispatchEvent(new Event(Event.CHANGE));
         return true;
      }
      
      protected function getCategoryCollection(param1:String) : anifire.browser.models.CharacterCollection
      {
         var _loc3_:ProductGroupCollectionEvent = null;
         var _loc2_:anifire.browser.models.CharacterCollection = this.categoryList[param1];
         if(!_loc2_)
         {
            _loc2_ = new anifire.browser.models.CharacterCollection(param1);
            _loc2_.locked = this._shouldLockTemplate;
            _loc2_.sortOrder = 2;
            this.categoryList[param1] = _loc2_;
            addCollection(_loc2_);
            _loc3_ = new ProductGroupCollectionEvent(ProductGroupCollectionEvent.PRODUCT_GROUP_ADDED);
            _loc3_.collection = _loc2_;
            dispatchEvent(_loc3_);
         }
         return _loc2_;
      }
      
      public function loadNextPage() : void
      {
         var _loc1_:URLVariables = new URLVariables();
         _configManager.appendURLVariables(_loc1_);
         var _loc2_:UtilURLStream = new UtilURLStream();
         _loc2_.addEventListener(Event.COMPLETE,this.onLoadCharacterComplete);
         _loc2_.addEventListener(UtilURLStream.TIME_OUT,this.onLoadCharacterError);
         _loc2_.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadCharacterError);
         _loc2_.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadCharacterError);
         _loc1_["count"] = 1000;
         _loc1_["page"] = this._nextUserCharacterPage;
         _loc1_["type"] = "char";
         _loc1_["themeId"] = this._theme.id;
         var _loc3_:URLRequest = new URLRequest(ServerConstants.ACTION_GET_USER_ASSETS_XML);
         _loc3_.data = _loc1_;
         _loc3_.method = URLRequestMethod.POST;
         _loc2_.load(_loc3_);
      }
      
      private function onLoadCharacterError(param1:Event) : void
      {
         dispatchEvent(new ProductGroupCollectionEvent(ProductGroupCollectionEvent.THEME_CHAR_ERROR));
      }
      
      private function onLoadCharacterComplete(param1:Event) : void
      {
         var _loc7_:CharThumb = null;
         var _loc8_:XML = null;
         var _loc2_:UtilURLStream = UtilURLStream(param1.target);
         var _loc3_:ByteArray = new ByteArray();
         _loc2_.readBytes(_loc3_);
         var _loc4_:XML = new XML(_loc3_);
         this.hasMore = _loc4_.@more == "1";
         var _loc5_:XMLList;
         var _loc6_:int = (_loc5_ = _loc4_.children()).length();
         var _loc9_:Theme = new Theme();
         var _loc10_:int = 0;
         while(_loc10_ < _loc6_)
         {
            _loc8_ = _loc5_[_loc10_];
            (_loc7_ = new CharThumb()).deSerialize(_loc8_,_loc9_);
            _loc7_.xml = _loc8_;
            this.addProduct(new ThumbModel(_loc7_));
            _loc10_++;
         }
         ++this._nextUserCharacterPage;
         dispatchEvent(new ProductGroupCollectionEvent(ProductGroupCollectionEvent.THEME_CHAR_COMPLETE));
      }
      
      private function onAdminSearchComplete(param1:Event) : void
      {
         dispatchEvent(new ProductExplorerEvent(ProductExplorerEvent.SEARCHED));
      }
      
      override public function getSearchCollection() : anifire.browser.models.SearchCollection
      {
         return this.searchResult;
      }
      
      [Bindable(event="propertyChange")]
      public function get hasMore() : Boolean
      {
         return this._696739087hasMore;
      }
      
      public function set hasMore(param1:Boolean) : void
      {
         var _loc2_:Object = this._696739087hasMore;
         if(_loc2_ !== param1)
         {
            this._696739087hasMore = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"hasMore",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get userCharacters() : anifire.browser.models.CharacterCollection
      {
         return this._1999925397userCharacters;
      }
      
      public function set userCharacters(param1:anifire.browser.models.CharacterCollection) : void
      {
         var _loc2_:Object = this._1999925397userCharacters;
         if(_loc2_ !== param1)
         {
            this._1999925397userCharacters = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"userCharacters",_loc2_,param1));
            }
         }
      }
   }
}
