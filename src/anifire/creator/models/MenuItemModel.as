package anifire.creator.models
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import mx.collections.ArrayCollection;
	import mx.events.PropertyChangeEvent;
	
	public class MenuItemModel implements IEventDispatcher
	{
		
		public static const MENU_TYPE_NORMAL:int = 0;
		
		public static const MENU_TYPE_RADIO:int = 1;
		
		public static const MENU_TYPE_CHECKBOX:int = 2;
		
		public static const MENU_TYPE_SEPARATOR:int = 3;
		
		[Bindable]
		public var label:String;
		[Bindable]
		public var value:*;
		[Bindable]
		public var icon:Class;
		[Bindable]
		public var parentMenu:MenuItemModel;
		protected var _subMenu:ArrayCollection;
		protected var _selectable:Boolean = true;
		[Bindable]
		public var selectedIndex:int;
		[Bindable]
		public var menuType:int;
		[Bindable]
		public var enabled:Boolean = true;
		[Bindable]
		public var sortOrder:int;
		
		protected var _selected:Boolean;
		
		private var _bindingEventDispatcher:EventDispatcher;
		
		public function MenuItemModel(param1:String, param2:*, param3:int = 0, param4:ArrayCollection = null, param5:Class = null)
		{
			this._bindingEventDispatcher = new EventDispatcher(IEventDispatcher(this));
			super();
			this.menuType = param3;
			this.label = param1;
			this.value = param2;
			this.subMenu = param4;
			this.icon = param5;
			if(param3 == MENU_TYPE_SEPARATOR)
			{
				this.enabled = false;
			}
		}
		[Bindable]
		public function get subMenu() : ArrayCollection
		{
			return this._subMenu;
		}
		
		private function set subMenu(param1:ArrayCollection) : void
		{
			var _loc2_:int = 0;
			var _loc3_:MenuItemModel = null;
			if(this._subMenu != param1)
			{
				this._subMenu = param1;
				if(this._subMenu)
				{
					_loc2_ = 0;
					while(_loc2_ < this._subMenu.length)
					{
						_loc3_ = this._subMenu.getItemAt(_loc2_) as MenuItemModel;
						_loc3_.parentMenu = this;
						_loc2_++;
					}
				}
			}
		}
		
		public function hasSubMenu() : Boolean
		{
			return Boolean(this._subMenu) && this._subMenu.length > 0;
		}

		public function get selectable() : Boolean
		{
			return this._selectable && !this.subMenu;
		}
		[Bindable]
		public function set selectable(param1:Boolean) : void
		{
			if(this._selectable != param1)
			{
				this._selectable = param1;
			}
		}
		
		public function get selectedItem() : *
		{
			if(this.subMenu)
			{
				if(this.selectedIndex > 0 && this.selectedIndex < this.subMenu.length)
				{
					return this.subMenu.getItemAt(this.selectedIndex);
				}
			}
			return null;
		}

		public function get selected() : Boolean
		{
			return this._selected;
		}
		[Bindable]
		public function set selected(param1:Boolean) : void
		{
			if(this._selected != param1)
			{
				this._selected = param1;
			}
		}
		
		public function toggle() : void
		{
			var _loc1_:ArrayCollection = null;
			var _loc2_:int = 0;
			var _loc3_:MenuItemModel = null;
			switch(this.menuType)
			{
				case MENU_TYPE_NORMAL:
					break;
				case MENU_TYPE_RADIO:
					this.selected = true;
					if(this.parentMenu)
					{
						_loc1_ = this.parentMenu.subMenu;
						_loc2_ = 0;
						while(_loc2_ < _loc1_.length)
						{
							_loc3_ = _loc1_.getItemAt(_loc2_) as MenuItemModel;
							if(Boolean(_loc3_) && _loc3_ != this)
							{
								_loc3_.selected = false;
							}
							_loc2_++;
						}
					}
					break;
				case MENU_TYPE_CHECKBOX:
					this.selected = !this.selected;
			}
		}
		
		public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
		{
			this._bindingEventDispatcher.addEventListener(param1,param2,param3,param4,param5);
		}
		
		public function dispatchEvent(param1:Event) : Boolean
		{
			return this._bindingEventDispatcher.dispatchEvent(param1);
		}
		
		public function hasEventListener(param1:String) : Boolean
		{
			return this._bindingEventDispatcher.hasEventListener(param1);
		}
		
		public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
		{
			this._bindingEventDispatcher.removeEventListener(param1,param2,param3);
		}
		
		public function willTrigger(param1:String) : Boolean
		{
			return this._bindingEventDispatcher.willTrigger(param1);
		}
	}
}
