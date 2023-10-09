package anifire.creator.models
{
   import anifire.creator.events.CcComponentLoadEvent;
   import anifire.util.UtilHashArray;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   
   public class CcAction extends EventDispatcher
   {
      
      public static const PACK_XML_NODE_NAME:String = "actionpack";
      
      public static const XML_NODE_NAME:String = "action";
       
      
      private var _id:String;
      
      private var _name:String;
      
      private var _enable:Boolean;
      
      private var _category:String;
      
      private var _group:String;
      
      private var _selections:UtilHashArray;
      
      private var _require_components:Array;
      
      public var imageData:ByteArray = null;
      
      private var _isLoadingImageData:Boolean = false;
      
      public function CcAction()
      {
         this._selections = new UtilHashArray();
         this._require_components = new Array();
         super();
      }
      
      public function get group() : String
      {
         return this._group;
      }
      
      public function set group(param1:String) : void
      {
         this._group = param1;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function get enable() : Boolean
      {
         return this._enable;
      }
      
      public function get category() : String
      {
         return this._category;
      }
      
      public function get requireComponents() : Array
      {
         return this._require_components;
      }
      
      public function get filename() : String
      {
         return this.id + ".swf";
      }
      
      public function getSelectionByComponentType(param1:String) : anifire.creator.models.CcSelection
      {
         return this._selections.getValueByKey(param1) as anifire.creator.models.CcSelection;
      }
      
      public function deserialize(param1:XML) : void
      {
         var _loc2_:XML = null;
         var _loc3_:XML = null;
         var _loc4_:anifire.creator.models.CcRequireComponent = null;
         var _loc5_:anifire.creator.models.CcSelection = null;
         this._id = param1.@id;
         this._name = param1.@name;
         this._enable = param1.@enable == "N" ? false : true;
         this._category = param1.@category;
         this._group = param1.@group;
         for each(_loc2_ in param1.child(anifire.creator.models.CcSelection.XML_NODE_NAME))
         {
            (_loc5_ = new anifire.creator.models.CcSelection()).deserialize(_loc2_);
            this._selections.push(_loc5_.type,_loc5_);
         }
         for each(_loc3_ in param1.child("require_component"))
         {
            (_loc4_ = new anifire.creator.models.CcRequireComponent()).deserialize(_loc3_);
            this._require_components.push(_loc4_);
         }
      }
      
      public function loadImageData(param1:URLRequest) : void
      {
         var _loc2_:URLLoader = null;
         if(this.imageData != null)
         {
            this.dispatchLoadCompleteEvent();
         }
         else if(!this._isLoadingImageData)
         {
            _loc2_ = new URLLoader();
            _loc2_.dataFormat = URLLoaderDataFormat.BINARY;
            _loc2_.addEventListener(Event.COMPLETE,this.onLoadImageDataComplete);
            _loc2_.load(param1);
         }
      }
      
      private function onLoadImageDataComplete(param1:Event) : void
      {
         (param1.target as IEventDispatcher).removeEventListener(param1.type,this.onLoadImageDataComplete);
         var _loc2_:URLLoader = param1.target as URLLoader;
         this.imageData = _loc2_.data as ByteArray;
         this.dispatchLoadCompleteEvent();
      }
      
      private function dispatchLoadCompleteEvent() : void
      {
         this.dispatchEvent(new CcComponentLoadEvent(CcComponentLoadEvent.LOAD_ACTION_IMAGE_DATA_COMPLETE,this,this.id));
      }
   }
}
