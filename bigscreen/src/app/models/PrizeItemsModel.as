package app.models
{
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	
	import app.util.Utility;

	public class PrizeItemsModel
	{
		private var _data:Array = [];
		private var _targetFile:File;
		public function PrizeItemsModel(targetFile:String)
		{
			_targetFile = new File(targetFile);
			
		}
		
		private function getFileContents(file:File):Object
		{
			if(!file.exists) {
				trace("file.exists:"+file.nativePath);
				trace("language file not found");
				return null;
			}
			var _fs:FileStream = new FileStream();
			var _currentData:String = "";
			_fs.open(file, "read");
			_currentData = _fs.readUTFBytes(_fs.bytesAvailable);
			_fs.close();
			var _returnData:Object;
			try {
				_returnData = JSON.parse(_currentData);
			} catch (e:Error) {
				trace("Please check the json is valid in: "+file.nativePath);
			}
			return _returnData;
		}
		
		public function getItems():Array{
			_data = getFileContents(_targetFile) as Array;
			var _returnArray:Array = [];
			for (var i:int = 0; i < _data.length; i++) {
				var _obj:Object = _data[i];
				_obj.text = _obj.name;
				_obj.image = "app:/items/"+_obj.image;
				_returnArray.push(_obj);	
			}
			return _returnArray.concat();
		}

		public function getItemById(id:String):Object{
			_data = getFileContents(_targetFile) as Array;
			for (var i:int = 0; i < _data.length; i++) {
				var _obj:Object = _data[i];
				_obj.text = _obj.name;
				_obj.image = "app:/items/"+_obj.image;
				if(_obj.id == id) return _obj;
			}
			return null;
		}
	}
}