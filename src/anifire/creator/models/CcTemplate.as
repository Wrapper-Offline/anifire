package anifire.creator.models
{
   import anifire.util.UtilHashArray;
   
   public class CcTemplate extends anifire.creator.models.CcCharacter
   {
      
      public static const XML_NODE_NAME:String = "template";
       
      
      private var _id:String;
      
      public function CcTemplate()
      {
         super();
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function set id(param1:String) : void
      {
         this._id = param1;
      }
      
      override public function deserialize(param1:XML, param2:UtilHashArray) : void
      {
         var _loc3_:XML = null;
         var _loc4_:anifire.creator.models.CcComponent = null;
         var _loc5_:anifire.creator.models.CcColor = null;
         var _loc6_:anifire.creator.models.CcLibrary = null;
         var _loc7_:String = null;
         var _loc8_:anifire.creator.models.CcComponentThumb = null;
         this.id = param1.@id;
         this.removeAllUserChosenComponent();
         this.currentTheme = param2.getValueByIndex(0) as anifire.creator.models.CcTheme;
         for each(_loc3_ in param1.child(anifire.creator.models.CcComponent.XML_NODE_NAME))
         {
            _loc7_ = anifire.creator.models.CcComponent.getComponentThumbTypeFromXml(_loc3_);
            (_loc4_ = new anifire.creator.models.CcComponent()).deserialize(_loc3_,param2);
            this.addUserChosenComponent(_loc4_);
         }
         this.removeAllUserChosenColors();
         for each(_loc3_ in param1.child(anifire.creator.models.CcColor.XML_NODE_NAME))
         {
            if((_loc5_ = new anifire.creator.models.CcColor()).deserialize(_loc3_,this.currentTheme,this))
            {
               this.addUserChosenColor(_loc5_);
            }
         }
         this.removeAllUserChosenLibraries();
         for each(_loc3_ in param1.child(anifire.creator.models.CcLibrary.XML_NODE_NAME))
         {
            _loc6_ = new anifire.creator.models.CcLibrary();
            if(_loc8_ = this.currentTheme.getComponentThumbByInternalId(anifire.creator.models.CcComponentThumb.generateInternalId(_loc3_.@type,_loc3_.@component_id)))
            {
               _loc3_.@money = _loc8_.money;
               _loc3_.@sharing = _loc8_.sharingPoint;
            }
            _loc6_.deserialize(_loc3_);
            this.addUserChosenLibrary(_loc6_);
         }
      }
   }
}
