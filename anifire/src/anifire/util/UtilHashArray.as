package anifire.util
{
	public class UtilHashArray
	{
		private var keyToIndexMap:UtilHashMap;
		private var indexToKeyMap:Array;
		private var data:Array;
		
		public function UtilHashArray()
		{
			super();
			this.keyToIndexMap = new UtilHashMap();
			this.indexToKeyMap = new Array();
			this.data = new Array();
		}

		/**
		 * pushes a value to the array with a key
		 * @param key key to use
		 * @param value value to push
		 * @param replace replace if key exists
		 */
		public function push(key:String, value:*, replace:Boolean = true) : int
		{
			var i:int = 0;
			if (this.keyToIndexMap.containsKey(key)) {
				if (replace) {
					i = this.keyToIndexMap.getValue(key) as int;
					this.data[i] = value;
				}
			} else {
				i = int(this.data.length);
				this.data.push(value);
				this.indexToKeyMap.push(key);
				this.keyToIndexMap.put(key, i);
			}
			return i;
		}

		/**
		 * removes n elements from an index
		 * @param start starting index
		 * @param deleteCount number of elements to delete
		 */
		public function remove(start:int, deleteCount:int) : void
		{
			if (start >= this.length || start + deleteCount - 1 >= this.length) {
				throw new Error("UtilHashArray index out of bound error. Index --> " + start);
			}
			var i:int = 0;
			for (i = 0; i < deleteCount; i++) {
				this.keyToIndexMap.remove(this.indexToKeyMap[start + i]);
			}
			this.data.splice(start, deleteCount);
			this.indexToKeyMap.splice(start, deleteCount);
			for (i = start; i < this.length; i++) {
				this.keyToIndexMap.remove(this.indexToKeyMap[i]);
				this.keyToIndexMap.put(this.indexToKeyMap[i], i);
			}
		}

		/**
		 * removes an element by its key
		 */
		public function removeByKey(key:String) : void
		{
			var i:int = this.getIndex(key);
			if (i != -1) {
				this.remove(i, 1);
			}
		}

		/**
		 * inserts an array of elements at a starting index
		 * @param start starting index
		 * @param insertArray elements to be inserted
		 * @param replace should existing elements be replaced
		 * it should've been me
		 */
		public function insert(start:int, insertArray:UtilHashArray, replace:Boolean = true) : void
		{
			var i:int = 0;
			var insert:UtilHashArray = insertArray.clone();
			if (replace) {
				for (i = insert.length - 1; i >= 0; i--) {
					var key:String = insert.getKey(i);
					if (this.containsKey(key)) {
						this.replaceValueByKey(key, insert.getValueByIndex(i));
						insert.remove(i, 1);
					}
				}
			} else {
				for (i = 0; i < insert.length; i++) {
					if (this.containsKey(insert.getKey(i))) {
						throw new Error("The key already exist in the HashArray");
					}
				}
			}
			var spliceFunc:Function = this.indexToKeyMap.splice;
			var clone:Array = insert.indexToKeyMap.concat();
			clone.unshift(0);
			clone.unshift(start);
			spliceFunc.apply(this.indexToKeyMap, clone);
			spliceFunc = this.data.splice;
			clone = insert.data.concat();
			clone.unshift(0);
			clone.unshift(start);
			spliceFunc.apply(this.data, clone);
			insert.removeAll();
			insert = null;
			for (i = start; i < this.length; i++) {
				this.keyToIndexMap.put(this.indexToKeyMap[i], i);
			}
		}

		public function containsKey(key:String) : Boolean
		{
			return this.keyToIndexMap.containsKey(key);
		}

		public function containsValue(value:*) : Boolean
		{
			for (var i:int = 0; i < this.data.length; i++) {
				if (this.data[i] == value) {
					return true;
				}
			}
			return false;
		}

		public function getKey(index:int) : String
		{
			return this.indexToKeyMap[index];
		}

		public function getKeys() : Array
		{
			return this.indexToKeyMap;
		}

		public function getIndex(key:String) : int
		{
			var i:* = this.keyToIndexMap.getValue(key);
			if (i != null) {
				return int(i);
			}
			return -1;
		}

		public function getValueByKey(key:String) : *
		{
			var i:* = this.keyToIndexMap.getValue(key);
			if (i != null) {
				return this.data[int(i)];
			}
			return null;
		}

		public function getValueByIndex(index:int) : *
		{
			return this.data[index];
		}

		public function replaceValueByIndex(index:int, value:*) : void
		{
			if (index >= this.length || index < 0) {
				throw new Error("index out of bound");
			}
			this.data[index] = value;
		}

		public function replaceValueByKey(key:String, value:*) : void
		{
			var i:* = this.keyToIndexMap.getValue(key);
			if (i == null) {
				throw new Error("key not exist!");
			}
			this.data[i as int] = value;
		}

		public function get length() : int
		{
			return this.data.length;
		}

		public function removeAll() : void
		{
			this.keyToIndexMap.clear();
			this.keyToIndexMap = new UtilHashMap();
			this.indexToKeyMap.splice(0, this.indexToKeyMap.length);
			this.indexToKeyMap = new Array();
			this.data.splice(0, this.data.length);
			this.data = new Array();
		}

		public function getArray() : Array
		{
			return this.data;
		}

		public function unShift(key:String, value:Object) : uint
		{
			if (this.keyToIndexMap.containsKey(key)) {
				this.remove(this.getIndex(key), 1);
			}
			this.data.unshift(value);
			this.indexToKeyMap.unshift(key);
			for (var i:int = 0; i < this.indexToKeyMap.length; i++) {
				this.keyToIndexMap.put(this.indexToKeyMap[i], i);
			}
			return this.length;
		}

		public function clone() : UtilHashArray
		{
			var clone:UtilHashArray = new UtilHashArray();
			clone.data = this.data.concat();
			clone.indexToKeyMap = this.indexToKeyMap.concat();
			for (var i:int = 0; i < clone.indexToKeyMap.length; i++) {
				clone.keyToIndexMap.put(clone.indexToKeyMap[i], i);
			}
			return clone;
		}

		public function isIdentical(compare:UtilHashArray) : Boolean
		{
			if (
				this.data.toString() == compare.data.toString() && 
				this.indexToKeyMap.toString() == compare.indexToKeyMap.toString()
			) {
				return true;
			}
			return false;
		}
	}
}
