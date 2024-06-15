package anifire.util
{
	import anifire.util.Crypto.FastRC4;
	import anifire.util.Crypto.TEA;
	import flash.utils.ByteArray;
	
	public class UtilCrypto
	{
		public static const MODE_DECRYPT_SWF:int = 0;
		public static const MODE_DECRYPT_RTMPE_TOKEN:int = 1;
		private static const KEY_MODE_DECRYPT_RTMPE_TOKEN:String = "gaGh0hiaEb8wa4wi";
		private var _mode:int;
		private var _legacyCryptKey:ByteArray;
		private var _modernCryptKey:ByteArray;

		/**
		 * used for decrypting assets
		 * @param {int} 0 for swf decryption, 1 for rtmpe token
		 */
		public function UtilCrypto(mode:int = 0)
		{
			var legacyKey:String = null;
			var legacyKeyIndex:int = 0;
			var modernKey:String = null;
			var modernKeyIndex:int = 0;
			super();
			this._mode = mode;
			if(this._mode == MODE_DECRYPT_SWF)
			{
				legacyKey = "g0o1a2n3i4m5a6t7e";
				this._legacyCryptKey = new ByteArray();
				legacyKeyIndex = 0;
				while(legacyKeyIndex < legacyKey.length)
				{
					this._legacyCryptKey[legacyKeyIndex] = legacyKey.charCodeAt(legacyKeyIndex) as uint;
					legacyKeyIndex++;
				}
				modernKey = "sorrypleasetryagainlater";
				this._modernCryptKey = new ByteArray();
				modernKeyIndex = 0;
				while(modernKeyIndex < modernKey.length)
				{
					this._modernCryptKey[modernKeyIndex] = modernKey.charCodeAt(modernKeyIndex) as uint;
					modernKeyIndex++;
				}
			}
			else if(this._mode == MODE_DECRYPT_RTMPE_TOKEN)
			{
			}
		}
		
		public function decrypt(bytes:ByteArray) : void
		{
			var decrypted:ByteArray = null;
			if (this._mode == MODE_DECRYPT_SWF)
			{
				// attempt to decrypt using the modern key first
				decrypted = new ByteArray();
				bytes.position = 0;
				bytes.readBytes(decrypted, 0, 10);
				this.decryptBytes(decrypted);
				if (this.isFlashPrefix(decrypted))
				{
					this.decryptBytes(bytes);
				}
				// try the legacy key if that didn't work
				else
				{
					bytes.position = 0;
					bytes.readBytes(decrypted, 0, 10);
					this.decryptBytesWithLegacyAlgorithm(decrypted);
					if (this.isFlashPrefix(decrypted))
					{
						this.decryptBytesWithLegacyAlgorithm(bytes);
					}
				}
			}
		}
		
		public function decryptString(encrypted:String) : String
		{
			var decrypted:String = null;
			if (this._mode == MODE_DECRYPT_RTMPE_TOKEN)
			{
				decrypted = TEA.decrypt(encrypted, KEY_MODE_DECRYPT_RTMPE_TOKEN);
			}
			return decrypted;
		}

		/**
		 * checks if the signature at the beginning matches an swf's
		 */
		private function isFlashPrefix(flashBytes:ByteArray) : Boolean
		{
			var signature:String = flashBytes.toString().substr(0, 3);
			return signature == "CWS" || signature == "FWS";
		}
		
		private function decryptBytes(bytes:ByteArray) : void
		{
			var rc4:FastRC4 = new FastRC4(this._modernCryptKey);
			rc4.decrypt(bytes);
		}
		
		private function decryptBytesWithLegacyAlgorithm(bytes:ByteArray) : void
		{
			var rc4:FastRC4 = new FastRC4(this._legacyCryptKey);
			rc4.decrypt(bytes);
		}
	}
}
