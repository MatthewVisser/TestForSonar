package app.services
{
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.globalization.DateTimeFormatter;

	public class Logger
	{
		public static const NETWORK:String = "network";
		public static const GENERAL:String = "general";
		public static const SERVER:String = "server";
		public static const WEB_SOCKET:String = "websocket";
		public static const ERROR:String = "error";
		public function Logger()
		{
		}
		
		public static function setup(header:String):void
		{
			var _file:File = File.desktopDirectory.resolvePath("log.txt");
			var _fs:FileStream = new FileStream();
			if(!_file.exists){
				_fs.open(_file, "write");
				_fs.writeUTFBytes(header+ "\r\n");
				_fs.close();
			} 
		}
		
		protected static function getFileName(category:String):String
		{
			category = category.split(" ").join("");
			category = category.toLowerCase();
			var now:Date = new Date;
			var myFormatter:DateTimeFormatter = new DateTimeFormatter('en-NZ');
			myFormatter.setDateTimePattern('yyyyMMdd-HH');
			return "logging"+File.separator+category+"-"+myFormatter.format(now) +"00.txt"
		}
		
		public static function log(value:String,category:String=GENERAL):void
		{
			var _file:File = File.desktopDirectory.resolvePath(getFileName(category));
			var _fs:FileStream = new FileStream();
			var _currentData:String = "";
			if(_file.exists){
				_fs.open(_file, "read");
				_currentData = _fs.readUTFBytes(_fs.bytesAvailable);
				_fs.close();
			} 
			var _date:Date = new Date;
			var _dateFormatter:DateTimeFormatter = new DateTimeFormatter('en-NZ');
			_dateFormatter.setDateTimePattern('yyyyMMdd-HH:mm:ss');
			_currentData += _dateFormatter.format(_date)+", "+value+"\r\n";
			_fs.open(_file, "write");
			_fs.writeUTFBytes(_currentData);
			_fs.close();
		}
	}
}