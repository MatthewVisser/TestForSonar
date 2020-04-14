package app.services
{
	
	import flash.desktop.NativeApplication;
	import flash.net.SharedObject;
	
	public class SharedObjectService 
	{
		static private var _flashCookieID:String = "";
		
		public function SharedObjectService() 
		{
			
		}
		
		public static function setup():void
		{
			var _descriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = _descriptor.namespace();
			_flashCookieID = NativeApplication.nativeApplication.applicationID;
		}
		
		public static function clearData():void
		{
			var sharedObject:SharedObject = SharedObject.getLocal(_flashCookieID);
			sharedObject.clear();
			sharedObject.flush();
		}
		
		public static function getBoolean(name:String):Boolean
		{
			var sharedObject:SharedObject = SharedObject.getLocal(_flashCookieID);
			return sharedObject.data[name];
		}
		
		public static function saveBoolean(name:String, value:Boolean):Boolean
		{
			var sharedObject:SharedObject = SharedObject.getLocal(_flashCookieID);
			sharedObject.data[name] = value;
			sharedObject.flush();
			return value;
		}
		
		public static function getString(name:String, defaultValue:String=""):String
		{
			var sharedObject:SharedObject = SharedObject.getLocal(_flashCookieID);
			if(!sharedObject.data[name] && defaultValue != ""){
				return saveString(name, defaultValue);
			}
			return sharedObject.data[name];
		}
		
		public static function saveString(name:String, value:String):String
		{
			var sharedObject:SharedObject = SharedObject.getLocal(_flashCookieID);
			sharedObject.data[name] = value;
			sharedObject.flush();
			return value;
		}
		
		public static function getNumber(name:String,defaultValue:Number=NaN):Number
		{
			var sharedObject:SharedObject = SharedObject.getLocal(_flashCookieID);
			if(!sharedObject.data[name] && defaultValue is Number) {
				return saveNumber(name, defaultValue);
			}
			return sharedObject.data[name];
		}
		
		public static function saveNumber(name:String, value:Number):Number
		{
			var sharedObject:SharedObject = SharedObject.getLocal(_flashCookieID);
			sharedObject.data[name] = value;
			sharedObject.flush();
			return value;
		}
		
		public static function getArray(name:String):Array
		{
			var sharedObject:SharedObject = SharedObject.getLocal(_flashCookieID);
			return sharedObject.data[name];
		}
		
		public static function saveArray(name:String, value:Array):Array
		{
			var sharedObject:SharedObject = SharedObject.getLocal(_flashCookieID);
			sharedObject.data[name] = value;
			sharedObject.flush();
			return value;
		}
	}
}