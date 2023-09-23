package anifire.browser.models
{
   import mx.collections.ArrayCollection;
   import mx.core.IFactory;
   import mx.events.PropertyChangeEvent;
   import spark.collections.Sort;
   import spark.layouts.supportClasses.LayoutBase;
   
   public class ProductCollection extends ArrayCollection
   {
       
      
      private var _426048681categoryName:String;
      
      private var _1109722326layout:LayoutBase;
      
      private var _133586166itemRenderer:IFactory;
      
      private var _738113884iconName:String = "";
      
      private var _858518010emptyMessage:String;
      
      private var _111972348valid:Boolean = true;
      
      public var productFilter:Function;
      
      public var sortOrder:int;
      
      protected var _label:String;
      
      protected var _productSort:Sort;
      
      private var _1097452790locked:Boolean;
      
      public function ProductCollection(param1:String, param2:Array = null)
      {
         super(param2);
         this.categoryName = param1;
         this.label = param1;
      }
      
      public function get properProductCount() : int
      {
         return this.isProperCollection ? int(length) : 0;
      }
      
      public function addProductIfAppropriate(param1:ThumbModel, param2:Boolean = true) : Boolean
      {
         if(this.productFilter != null && param1 && this.productFilter(param1))
         {
            this.addProduct(param1,param2);
            return true;
         }
         return false;
      }
      
      public function addProduct(param1:ThumbModel, param2:Boolean = true) : void
      {
         var _loc3_:int = param2 ? int(length) : 0;
         addItemAt(param1,_loc3_);
      }
      
      public function removeProductById(param1:String) : Boolean
      {
         var _loc3_:ThumbModel = null;
         var _loc2_:int = 0;
         while(_loc2_ < length)
         {
            _loc3_ = getItemAt(_loc2_) as ThumbModel;
            if(_loc3_.id == param1)
            {
               removeItemAt(_loc2_);
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      public function get isProperCollection() : Boolean
      {
         return true;
      }
      
      [Bindable(event="propertyChange")]
      public function get label() : String
      {
         return this._label;
      }
      
      private function set _102727412label(param1:String) : void
      {
         if(this._label != param1)
         {
            this._label = param1;
         }
      }
      
      public function sortProducts() : void
      {
         if(this._productSort)
         {
            this.sort = this._productSort;
            refresh();
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get categoryName() : String
      {
         return this._426048681categoryName;
      }
      
      public function set categoryName(param1:String) : void
      {
         var _loc2_:Object = this._426048681categoryName;
         if(_loc2_ !== param1)
         {
            this._426048681categoryName = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"categoryName",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get layout() : LayoutBase
      {
         return this._1109722326layout;
      }
      
      public function set layout(param1:LayoutBase) : void
      {
         var _loc2_:Object = this._1109722326layout;
         if(_loc2_ !== param1)
         {
            this._1109722326layout = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"layout",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get itemRenderer() : IFactory
      {
         return this._133586166itemRenderer;
      }
      
      public function set itemRenderer(param1:IFactory) : void
      {
         var _loc2_:Object = this._133586166itemRenderer;
         if(_loc2_ !== param1)
         {
            this._133586166itemRenderer = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"itemRenderer",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get iconName() : String
      {
         return this._738113884iconName;
      }
      
      public function set iconName(param1:String) : void
      {
         var _loc2_:Object = this._738113884iconName;
         if(_loc2_ !== param1)
         {
            this._738113884iconName = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"iconName",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get emptyMessage() : String
      {
         return this._858518010emptyMessage;
      }
      
      public function set emptyMessage(param1:String) : void
      {
         var _loc2_:Object = this._858518010emptyMessage;
         if(_loc2_ !== param1)
         {
            this._858518010emptyMessage = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"emptyMessage",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get valid() : Boolean
      {
         return this._111972348valid;
      }
      
      public function set valid(param1:Boolean) : void
      {
         var _loc2_:Object = this._111972348valid;
         if(_loc2_ !== param1)
         {
            this._111972348valid = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"valid",_loc2_,param1));
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get locked() : Boolean
      {
         return this._1097452790locked;
      }
      
      public function set locked(param1:Boolean) : void
      {
         var _loc2_:Object = this._1097452790locked;
         if(_loc2_ !== param1)
         {
            this._1097452790locked = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"locked",_loc2_,param1));
            }
         }
      }
      
      public function set label(param1:String) : void
      {
         var _loc2_:Object = this.label;
         if(_loc2_ !== param1)
         {
            this._102727412label = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"label",_loc2_,param1));
            }
         }
      }
   }
}
