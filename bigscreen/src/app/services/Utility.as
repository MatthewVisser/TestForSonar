package app.services
{
	import flash.desktop.NativeApplication;
	import flash.globalization.DateTimeFormatter;
	
	import feathers.controls.LayoutGroup;
	
	import starling.display.Quad;

	public class Utility
	{
		public static var _date:Date = new Date();
		protected static var _startTime:int;
		protected static var _endTime:int;
		public static var categoriesWithProductsData:Array = [];
		
		public function Utility()
		{
		}
		
		public static function debugModeDetected():Boolean
		{

			var _debugModeDetected:Boolean = (new Error().getStackTrace().search(/:[0-9]+]$/m) > -1);
			return _debugModeDetected;
		}
		
		public static function getAppVersion():String
		{
			var appXML:XML =  NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXML.namespace();
			var _appVersion:String = appXML.ns::versionNumber;
			return _appVersion;
		}
		
		public static function convertTime(time:String=""):String
		{
			time = time.split("-").join("/");
			time = time.split("T").join(" ");
			time = time.split("+")[0];
			
			return time;
		}
		
		public static function convertTimeToUTC(time:String=""):Number
		{
			time = time.split("-").join("/");
			time = time.split("T").join(" ");
			time = time.split("+")[0];
			
			_date.setTime(Date.parse(time));
			return Math.round(_date.valueOf()/1000);
		}
		
		public static function convertUTCtoDate(time:Number):Date
		{
			return  new Date(time * 1000);
		}
		
		public static function getCurrentTimeAsUTC():Number
		{
			_date = new Date();
			return Math.round(_date.valueOf()/1000);
		}

		public static function santiseString(value:String):String
		{
			if(!value) return "";
			value = value.split(" ").join("").toLowerCase().split("-").join("").split("+").join("");
			var _regEx:RegExp = /\d+/; 
			value = value.replace(_regEx, '');
			return value;
		}
	
		public static function timeString():String
		{
			var _date:Date = new Date;
			var _dateFormatter:DateTimeFormatter = new DateTimeFormatter('en-NZ');
			//_dateFormatter.setDateTimePattern('yyyyMMdd-HH:mm:ss');
			_dateFormatter.setDateTimePattern('HH:mm:ss');
			return _dateFormatter.format(_date);
		}
		
		public static function randomize ( a : *, b : * ) : int {
			return ( Math.random() > .5 ) ? 1 : -1;
		}
		
		public static function addGapVert(target:LayoutGroup, gapHeight:Number=1):void
		{
			var _gap:Quad = new Quad(1,gapHeight);
			_gap.alpha = 0;
			target.addChild(_gap);
		}
		
		public static function colorUint2hex(dec:uint):String {
			
			var digits:String = "0123456789ABCDEF";
			var hex:String = '';
			while (dec > 0) {
				var next:uint = dec & 0xF;
				dec >>= 4;
				hex = digits.charAt(next) + hex;
			}
			if (hex.length == 0) hex = '0'
			return "#"+hex;
		}
		
		public static function cleanAPIUrl(url:String):String
		{
			url = url.split("http://").join("https://");
			if(url.charAt(url.length-1) == '/'){
				url = url.substr(0, url.length-1);
			}
			return url;
		}
	}
}