package anifire.creator.components.editor
{
	import anifire.creator.skins.ConfirmPopUpSkin;
	import anifire.event.StudioEvent;
	import anifire.util.UtilDict;
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import mx.core.FlexGlobals;
	import mx.events.PropertyChangeEvent;
	import spark.components.Label;
	import spark.components.Panel;
	import spark.components.supportClasses.ButtonBase;
	import spark.events.PopUpEvent;
	import spark.primitives.BitmapImage;
	
	public class ConfirmPopUp extends DefaultPopUpContainer
	{
		
		public static const CONFIRM_POPUP_NO_ICON:int = 0;
		public static const CONFIRM_POPUP_INFO:int = 1;
		public static const CONFIRM_POPUP_ALERT:int = 2;
		public static const CONFIRM_POPUP_ERROR:int = 3;
		[Embed(source="../../../images/popup/imgAlert.png")]
		public static const imgAlert:Class;
		[Embed(source="../../../images/popup/imgConfirm.png")]
		public static const imgConfirm:Class;
		[Embed(source="../../../images/popup/imgError.png")]
		public static const imgError:Class;
		
		
		[SkinPart(required="false")]
		public var confirmButton:ButtonBase;
		
		[SkinPart(required="false")]
		public var cancelButton:ButtonBase;
		
		[SkinPart(required="false")]
		public var closeButton:ButtonBase;
		
		[SkinPart(required="true")]
		public var panel:Panel;
		
		[SkinPart(required="false")]
		public var messageLabel:Label;
		
		[SkinPart(required="false")]
		public var iconDisplay:BitmapImage;
		
		protected var _iconType:int = 2;
		
		protected var _showConfirmButton:Boolean = true;
		
		protected var _showCancelButton:Boolean = true;
		
		protected var _showCloseButton:Boolean = true;
		
		public function ConfirmPopUp()
		{
			super();
			setStyle("fontSize",14);
			setStyle("skinClass",ConfirmPopUpSkin);
		}
		
		public static function openDefaultPopUpWithLocale(param1:String, param2:String = null, param3:DisplayObjectContainer = null, param4:Boolean = true, param5:Function = null) : ConfirmPopUp
		{
			if(param1)
			{
				param1 = UtilDict.toDisplay("go",param1);
			}
			if(param2)
			{
				param2 = UtilDict.toDisplay("go",param2);
			}
			return openDefaultPopUp(param1,param2,param3,param4,param5);
		}
		
		public static function openDefaultPopUp(param1:String, param2:String = null, param3:DisplayObjectContainer = null, param4:Boolean = true, param5:Function = null) : ConfirmPopUp
		{
			var _loc6_:ConfirmPopUp;
			(_loc6_ = new ConfirmPopUp()).createDefaultPopUp();
			_loc6_.message = param1;
			if(param2)
			{
				_loc6_.title = param2;
			}
			if(param5 != null)
			{
				_loc6_.addEventListener(PopUpEvent.CLOSE,param5);
			}
			if(!param3)
			{
				param3 = FlexGlobals.topLevelApplication as DisplayObjectContainer;
			}
			_loc6_.open(param3,param4);
			return _loc6_;
		}
		
		public function createDefaultPopUp() : void
		{
			this.showCloseButton = false;
			this.confirmText = UtilDict.toDisplay("go","OK");
			this.cancelText = UtilDict.toDisplay("go","Cancel");
		}
		
		[Bindable]
		public function get iconType() : int
		{
			return this._iconType;
		}
		public function set iconType(param1:int) : void
		{
			if(this._iconType != param1)
			{
				this._iconType = param1;
				if(this.iconDisplay)
				{
					this.updateIconDisplay();
				}
			}
		}
		
		protected function updateIconDisplay() : void
		{
			switch(this._iconType)
			{
				case CONFIRM_POPUP_INFO:
					this.iconDisplay.source = imgConfirm;
					break;
				case CONFIRM_POPUP_ALERT:
					this.iconDisplay.source = imgAlert;
					break;
				case CONFIRM_POPUP_ERROR:
					this.iconDisplay.source = imgError;
					break;
				default:
					this.iconDisplay.source = null;
			}
		}
		
		[Bindable]
		public function get showConfirmButton() : Boolean
		{
			return this._showConfirmButton;
		}
		public function set showConfirmButton(param1:Boolean) : void
		{
			this._showConfirmButton = param1;
			if(this.confirmButton)
			{
				this.confirmButton.includeInLayout = param1;
				this.confirmButton.visible = param1;
			}
		}
		
		[Bindable]
		public function get showCancelButton() : Boolean
		{
			return this._showCancelButton;
		}
		public function set showCancelButton(param1:Boolean) : void
		{
			this._showCancelButton = param1;
			if(this.cancelButton)
			{
				this.cancelButton.includeInLayout = param1;
				this.cancelButton.visible = param1;
			}
		}
		
		[Bindable]
		public function get showCloseButton() : Boolean
		{
			return this._showCloseButton;
		}
		public function set showCloseButton(param1:Boolean) : void
		{
			this._showCloseButton = param1;
			if(this.closeButton)
			{
				this.closeButton.includeInLayout = param1;
				this.closeButton.visible = param1;
			}
		}
		
		override public function set confirmText(param1:String) : void
		{
			super.confirmText = param1;
			if(this.confirmButton)
			{
				this.confirmButton.label = param1;
			}
		}
		
		override public function set cancelText(param1:String) : void
		{
			super.cancelText = param1;
			if(this.cancelButton)
			{
				this.cancelButton.label = param1;
			}
		}
		
		override public function set message(param1:String) : void
		{
			super.message = param1;
			if(this.messageLabel)
			{
				this.messageLabel.text = param1;
			}
		}
		
		override protected function partAdded(param1:String, param2:Object) : void
		{
			if(param2 == this.confirmButton)
			{
				this.confirmButton.label = confirmText;
				this.confirmButton.includeInLayout = this.showConfirmButton;
				this.confirmButton.visible = this.showConfirmButton;
				this.confirmButton.addEventListener(MouseEvent.CLICK,this.onConfirmButtonClick);
			}
			else if(param2 == this.cancelButton)
			{
				this.cancelButton.label = cancelText;
				this.cancelButton.includeInLayout = this.showCancelButton;
				this.cancelButton.visible = this.showCancelButton;
				this.cancelButton.addEventListener(MouseEvent.CLICK,this.onCancelButtonClick);
			}
			else if(param2 == this.closeButton)
			{
				this.closeButton.includeInLayout = this.showCloseButton;
				this.closeButton.visible = this.showCloseButton;
				this.closeButton.addEventListener(MouseEvent.CLICK,this.onCloseButtonClick);
			}
			else if(param2 == this.messageLabel)
			{
				this.messageLabel.text = message;
			}
			else if(param2 == this.iconDisplay)
			{
				this.updateIconDisplay();
			}
		}
		
		override protected function partRemoved(param1:String, param2:Object) : void
		{
			if(param2 == this.confirmButton)
			{
				this.confirmButton.removeEventListener(MouseEvent.CLICK,this.onConfirmButtonClick);
			}
			else if(param2 == this.cancelButton)
			{
				this.cancelButton.removeEventListener(MouseEvent.CLICK,this.onCancelButtonClick);
			}
			else if(param2 == this.closeButton)
			{
				this.closeButton.removeEventListener(MouseEvent.CLICK,this.onCloseButtonClick);
			}
		}
		
		protected function onConfirmButtonClick(param1:MouseEvent) : void
		{
			this.dispatchEvent(new StudioEvent(StudioEvent.POPUP_CONFIRM));
			confirm();
		}
		
		protected function onCancelButtonClick(param1:MouseEvent) : void
		{
			cancel();
		}
		
		protected function onCloseButtonClick(param1:MouseEvent) : void
		{
			cancel();
		}
	}
}
