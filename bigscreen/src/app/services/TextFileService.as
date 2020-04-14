package app.services
{
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	
	public class TextFileService extends EventDispatcher
	{
		private var _targetFile:File;
		private var _currentData:String = "";
		private var _fs:FileStream = new FileStream();
		private var _delimiter:String;
		
		public function TextFileService(targetFile:File, defaultHeading:String="",delimiter:String=",\r\n")
		{
			_targetFile = targetFile;
			_delimiter = delimiter;
			if(_targetFile.exists){
				_fs.open(_targetFile, "read");
				_currentData = _fs.readUTFBytes(_fs.bytesAvailable);
				_fs.close();
			} else {
				if(defaultHeading != ""){
					addToFile(defaultHeading);
				} else {
					emptyFile();
				}
			}
		}
		
		public function emptyFile():void
		{
			_currentData = "";
			_fs.open(_targetFile, "write");
			_fs.writeUTFBytes(_currentData);
			_fs.close();
		}
		
		public function addToFile(textToAdd:String):void
		{
			_fs.open(_targetFile, "read");
			_currentData = _fs.readUTFBytes(_fs.bytesAvailable);
			_fs.close();
			
			_currentData +=  textToAdd + _delimiter;
			
			_fs.open(_targetFile, "write");
			_fs.writeUTFBytes(_currentData);
			_fs.close();
		}
		
		public function getFileContents():String
		{
			return _currentData;
		}
		
		public function getFileContentsAsArray():Array
		{
			return _currentData.split(_delimiter);
		}
		
		public function checkFileForUpdates():void
		{
			_fs.open(_targetFile, "read");
			_currentData = _fs.readUTFBytes(_fs.bytesAvailable);
			_fs.close();
		}
		
		public function getTextFile():File
		{
			return _targetFile;
		}
		
		public function deleteLast():void
		{
			_fs.open(_targetFile, "read");
			_currentData = _fs.readUTFBytes(_fs.bytesAvailable);
			_fs.close();
			
			var _index:int = _currentData.lastIndexOf(_delimiter);
			_currentData = _currentData.substring(0, _index);
			var _index:int = _currentData.lastIndexOf(_delimiter);
			
			if(_index != -1){
				_currentData = _currentData.substring(0, _index+_delimiter.length);
			} else {
				_currentData = "";
			}
			
			_fs.open(_targetFile, "write");
			_fs.writeUTFBytes(_currentData);
			_fs.close();
		}
		
		public function getLast():String
		{
			_fs.open(_targetFile, "read");
			_currentData = _fs.readUTFBytes(_fs.bytesAvailable);
			_fs.close();
			
			var _dataArray:Array = _currentData.split(_delimiter);
			trace("_dataArray:"+_dataArray);
			var _dataString:String = _dataArray[_dataArray.length-2];
			return _dataString;
		}
		
		public function getFirst():String
		{
			_fs.open(_targetFile, "read");
			_currentData = _fs.readUTFBytes(_fs.bytesAvailable);
			_fs.close();
			
			var _dataArray:Array = _currentData.split(_delimiter);
			var _dataString:String = _dataArray[0];
			return _dataString;
		}
		
		public function deleteFirst():void
		{
			_fs.open(_targetFile, "read");
			_currentData = _fs.readUTFBytes(_fs.bytesAvailable);
			_fs.close();
			
			var _dataArray:Array = _currentData.split(_delimiter);
			trace("deleting:"+_dataArray.shift());
			_currentData = _dataArray.join(_delimiter);
			_fs.open(_targetFile, "write");
			_fs.writeUTFBytes(_currentData);
			_fs.close();
		}
		
		public function getItemOfIndex(index:int):String
		{
			_fs.open(_targetFile, "read");
			_currentData = _fs.readUTFBytes(_fs.bytesAvailable);
			_fs.close();
			var _dataArray:Array = _currentData.split(_delimiter);
			var _dataString:String = _dataArray[index];
			return _dataString;
		}
		
		public function length():int
		{
			_fs.open(_targetFile, "read");
			_currentData = _fs.readUTFBytes(_fs.bytesAvailable);
			_fs.close();
			var _dataArray:Array = _currentData.split(_delimiter);
			var _length:int = _dataArray.length-2;
			if(_length < 0 )_length = 0;
			return _length;
		}
	}
}
