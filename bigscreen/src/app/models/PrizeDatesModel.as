package app.models
{
	import com.greensock.TweenMax;
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.globalization.DateTimeFormatter;
import flash.globalization.DateTimeStyle;

public class PrizeDatesModel
	{
		public static const PRIZE_TABLE_BIG_BOYS_TOYS:String = "prizeTableBigBoysToys";
		
		private var _connection:SQLConnection;
		private var _createStatement:SQLStatement;
		private var _deleteStatement:SQLStatement;
		private var _addRecordStatement:SQLStatement;
		private var _getRecordStatement:SQLStatement;
		private var _getTotalRecords:SQLStatement;
		private var _getRecordsStatement:SQLStatement;
		private var _getRecordsSinceStatement:SQLStatement;
		private var _deleteItemStatement:SQLStatement;
		private var _getEverythingStatement:SQLStatement;
		private var _getEmailCountStatement:SQLStatement;
		private var _getAllUsersStatement:SQLStatement;
		private var _sessions:Array = [];
		private var _getPrizeCountsStatement:SQLStatement;
		private var _totalPrizes:Number;
		private var _getPrizeStatement:SQLStatement;
		private var _markPrizeAsVendedStatement:SQLStatement;
		private var _previousTime:Number = 0;
		private var _dbFile:File;
		private var _getPhoneCountStatement:SQLStatement;
		
		public function PrizeDatesModel()
		{
			_connection = new SQLConnection(); 
			_dbFile = new File("app-storage:/prizedates4.db");

			var _createNewDB:Boolean = false;
			
			if(_createNewDB){
				if(_dbFile.exists) _dbFile.deleteFile();
				_connection.open(_dbFile);
				init();
				createPrizes();	
			} else {
				if(!_dbFile.exists){
					var _backupFile:File = new File("app:/prizedates4.db");
					_backupFile.copyTo(_dbFile);
				}
				_connection.open(_dbFile);
				init();
			}
			countPrizes(PRIZE_TABLE_BIG_BOYS_TOYS);
		}
		
		public function createPrizes():void
		{
			generateTimestampsFromFile("app:/prizeTimesBBT.json", PRIZE_TABLE_BIG_BOYS_TOYS);
		}
		
		public function generateTimestampsFromFile(jsonFilePath:String,prizeTable:String):void
		{
			var _file:File = new File(jsonFilePath);
			if(!_file.exists) {
				trace("file not found");
				return;
			}
			var _fs:FileStream = new FileStream();
			var _currentData:String = "";
			_fs.open(_file, "read");
			_currentData = _fs.readUTFBytes(_fs.bytesAvailable);
			_fs.close();
			
			var _dataArray:Array = JSON.parse(_currentData) as Array;
			for (var i:int = 0; i < _dataArray.length; i++) 
			{
				var _obj:Object = _dataArray[i];
				addPrize(_obj.Prize, _obj.Timestamp, prizeTable);
			}
		}
		
		public function deleteDB():void
		{
			var now:Date = new Date;
			_connection.close();
			var myFormatter:DateTimeFormatter = new DateTimeFormatter('en-NZ');
			myFormatter.setDateTimePattern('yyyyMMdd-HHmmss');
			var _deletedLocation:File = new File("app-storage:/deleted_app_"+myFormatter.format(now)+".db");
			_dbFile.copyTo(_deletedLocation);
			
			TweenMax.delayedCall(1, deleteDB);
		}
		
		private function deleteFile():void
		{
			_dbFile.deleteFileAsync();
		}
			
		public function get connection():SQLConnection
		{
			return _connection;
		}
		
		private function createPrizeTable(tableName:String):void
		{
			var _createSQL:String =  
				"CREATE TABLE IF NOT EXISTS "+tableName+" (" +    
				"    id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
				"    prize TEXT, " +  
				"    vended INTEGER, " +  
				"    rfid TEXT, " +  
				"    phone TEXT, " +  
				"    email TEXT, " +  
				"    barcode TEXT, " +  
				"    date TEXT, " +  
				"    timestamp NUMBER)"; 
			_createStatement = new SQLStatement(); 
			_createStatement.sqlConnection = _connection; 
			_createStatement.text = _createSQL;
			_createStatement.execute();
		}

		private function init():void
		{
			createPrizeTable(PRIZE_TABLE_BIG_BOYS_TOYS);
			
			_addRecordStatement = new SQLStatement();
			_addRecordStatement.sqlConnection = _connection;
			
			
			_deleteItemStatement = new SQLStatement();
			_deleteItemStatement.sqlConnection = _connection;
			
			
			_getEverythingStatement = new SQLStatement();
			_getEverythingStatement.sqlConnection = _connection;
			
	
			_getEmailCountStatement = new SQLStatement();
			_getEmailCountStatement.sqlConnection = _connection;
			
			
			_getPhoneCountStatement = new SQLStatement();
			_getPhoneCountStatement.sqlConnection = _connection;
			
			_getAllUsersStatement = new SQLStatement();
			_getAllUsersStatement.sqlConnection = _connection;
			
			
			_getPrizeCountsStatement = new SQLStatement();
			_getPrizeCountsStatement.sqlConnection = _connection;
			
			
			_getPrizeStatement = new SQLStatement();
			_getPrizeStatement.sqlConnection = _connection;
			//_getPrizeStatement.text ="SELECT * FROM "+_tableName+" WHERE timestamp < :timestamp AND timestamp > :timecutoff AND vended = 0"; 
			
			//_getPrizeStatement.text ="SELECT * FROM "+_tableName+" WHERE vended = 0"; 
			
			_markPrizeAsVendedStatement = new SQLStatement();
			_markPrizeAsVendedStatement.sqlConnection = _connection;
		}
		
		public function getPrizeStatement(tableName:String):Object
		{
			var _dateTime:Number = new Date().time;
			_getPrizeStatement.text ="SELECT * FROM "+tableName+" WHERE timestamp < :timestamp AND vended = 0";
			_getPrizeStatement.parameters[":timestamp"] = _dateTime;
			//_getPrizeStatement.parameters[":timecutoff"] = _dateTime - 1000 * 60 * 60 * 24 * 30;//Changed cut off to 100 days 
			_getPrizeStatement.execute();
			var _result:SQLResult = _getPrizeStatement.getResult();
			if(_result.data){
				return _result.data[0];
			}
			
			return null;
		}
		
		public function markPrizeAsVended(rfid:String, barcode:String, email:String, phone:String, prizeObj:Object,tableName:String):void
		{
			_markPrizeAsVendedStatement.text = "UPDATE "+tableName+" SET vended = 1, rfid = :rfid, barcode = :barcode, email = :email, phone = :phone WHERE id = :id";
			_markPrizeAsVendedStatement.parameters[":id"] = prizeObj.id;
			_markPrizeAsVendedStatement.parameters[":rfid"] = rfid;
			_markPrizeAsVendedStatement.parameters[":barcode"] = barcode;
			_markPrizeAsVendedStatement.parameters[":email"] = email;
			_markPrizeAsVendedStatement.parameters[":phone"] = phone;
			_markPrizeAsVendedStatement.execute();
		}
		
		private function createPrizeSession(startDate:Date, endDate:Date, prizes:Array, tableName:String):void
		{
			_sessions = [];
			addSession(startDate, endDate);
			var _totalSessionTime:Number = getTotalSessionTime();
			trace("_totalSessionTime:"+_totalSessionTime);
			var _prizeCountForSession:Number = 0;
			for (var i:int = 0; i < prizes.length; i++) 
			{
				var _prizeObj:Object = prizes[i];
				trace("_prizeObj.num:"+_prizeObj.num);
				_prizeCountForSession += _prizeObj.num;
			}
			var _prizesPerMinute:Number = _prizeCountForSession / _totalSessionTime;
			trace("_prizesPerMinute:"+_prizesPerMinute);
			generateTimesForSessions(_prizesPerMinute);
			
			var _prizePool:Array = createPrizePool(prizes);
			generatePrizesForSessions(_prizePool);
			
			addSessionsToDB(tableName);
		}
		
		private function createPrizePool(prizes:Array):Array
		{
			var _returnArray:Array = [];
			
			for (var i:int = 0; i < prizes.length; i++) {
				var _prizeObj:Object = prizes[i];
				var _countOfPrize:int = _prizeObj.num;
				for (var j:int = 0; j < _countOfPrize; j++) 
				{
					_returnArray.push(_prizeObj.prize);
				}
			}
			_returnArray.sort(randomize);
			return _returnArray;
		}
		
		private function addSession(startDate:Date, endDate:Date):void
		{
			var _sessionLengthMinutes:Number = (endDate.time - startDate.time) / 1000 / 60;
			_sessions.push({startDate:startDate,endDate:endDate,sessionLengthMin:_sessionLengthMinutes})
		}
		
		private function getTotalSessionTime():Number
		{
			var _totalTime:Number = 0;
			for (var i:int = 0; i < _sessions.length; i++) {
				_totalTime += _sessions[i].sessionLengthMin;
			}
			return _totalTime;
		}
		
		private function generateTimesForSessions(prizesPerMinute:Number):void
		{
			for (var i:int = 0; i < _sessions.length; i++) {
				var _sessionObj:Object = _sessions[i];
				_sessionObj.times = generateRandomNumbers(_sessionObj.startDate.time, _sessionObj.endDate.time, _sessionObj.sessionLengthMin*prizesPerMinute);
				
				//_sessionObj.times = generateNumbers(_sessionObj.startDate.time, _sessionObj.endDate.time, _sessionObj.sessionLengthMin*prizesPerMinute);
			}
		}
	
		
		private function generatePrizesForSessions(prizePool:Array):void
		{
			for (var i:int = 0; i < _sessions.length; i++) {
				var _sessionObj:Object = _sessions[i];
				var _times:Array = _sessionObj.times;
				var _prizesForSession:Array = [];
				for (var j:int = 0; j < _times.length; j++) 
				{
					if(prizePool.length > 0){
						var _prizeObj:Object = new Object();
						_prizeObj.prize = prizePool.pop();
						_prizeObj.time = _times[j];
						_prizeObj.date_string = new Date(_prizeObj.time).toString().split(" GMT")[0];
						_prizesForSession.push(_prizeObj);
					}
				}
				_sessionObj.prizes = _prizesForSession;
			}
		}
		
		private function addSessionsToDB(prizeTable:String):void
		{
			for (var i:int = 0; i < _sessions.length; i++) {
				var _sessionObj:Object = _sessions[i];
				var _prizesForSession:Array = _sessionObj.prizes;
				_prizesForSession.sortOn("time");
				for (var j:int = 0; j < _prizesForSession.length; j++) {
					add(_prizesForSession[j],prizeTable);
				}
			}
		}
		
		//Space according to difference
		private function generateNumbers(rangeStart:Number, rangeEnd:Number, count:Number, difference:Number=60000):Array
		{
			_previousTime = rangeStart;
			var _returnNumbers:Array = [];
			while(_returnNumbers.length < count)
			{
				_previousTime +=  difference;
				_returnNumbers.push(_previousTime);
			}
			return _returnNumbers;
		}
		
		//Trying to ensure a minimum spacing of 1 minute between prizes
		private function generateRandomNumbers(rangeStart:Number, rangeEnd:Number, count:Number, minDifference:Number=60000):Array
		{
			var _returnNumbers:Array = [];
			var _range:Number = rangeEnd - rangeStart;
			while(_returnNumbers.length < count)
			{
				var _randomTime:Number = Math.round(_range * Math.random()) + rangeStart;
				var _numberValid:Boolean = true;
				for (var i:int = 0; i < _returnNumbers.length; i++) 
				{
					var _previousNumber:Number = _returnNumbers[i];
					var _dif:Number = Math.abs(_previousNumber - _randomTime);
					if(_dif <= minDifference){
						_numberValid = false;
					}
				}
				if(_numberValid){
					_returnNumbers.push(_randomTime);
				}
			}
			return _returnNumbers;
		}
		
		public function countPrizes(tableName:String):Array
		{
			_getPrizeCountsStatement.text = "SELECT prize,COUNT(*) as count FROM "+tableName+" GROUP BY prize ORDER BY count DESC";
			_getPrizeCountsStatement.execute();
			var _result:SQLResult = _getPrizeCountsStatement.getResult();
			if(_result.data){
				trace("results:"+JSON.stringify(_result.data));
				return _result.data;
			}
			return [];
		}
		
		public function getPrizesVendedCount(tableName:String):Array
		{
			_getPrizeCountsStatement.text = "SELECT prize,COUNT(*) as count FROM "+tableName+" WHERE vended = 1 GROUP BY prize ORDER BY count DESC";
			_getPrizeCountsStatement.execute();
			var _result:SQLResult = _getPrizeCountsStatement.getResult();
			trace("_result.data:"+_result.data);
			if(_result.data){
				trace("results:"+JSON.stringify(_result.data));
				return _result.data;
			}
			return [];
		}
		
		public function getAllUsers(tableName:String):Array
		{
			_getAllUsersStatement.text = "SELECT * FROM "+tableName+" ORDER BY first_name, last_name, barcode";
			_getAllUsersStatement.execute();
			var _result:SQLResult = _getAllUsersStatement.getResult(); 
			if(_result.data){
				return _result.data;
			}
			return [];
		}
		
		public function getCountForEmail(email:String, tableName:String):Number
		{
			if(!email || email == "") return 0;
			_getEmailCountStatement.text = "SELECT email,COUNT(*) as count FROM "+tableName+" WHERE email = :email";
			_getEmailCountStatement.parameters[":email"] = email;
			_getEmailCountStatement.execute();
			
			var _result:SQLResult = _getEmailCountStatement.getResult(); 
			if(_result.data){
				return _result.data[0].count;
			}
			return 0;
		}
		
		public function getCountForPhone(phone:String, tableName:String):Number
		{
			if(!phone || phone == "") return 0;
			_getPhoneCountStatement.text = "SELECT phone,COUNT(*) as count FROM "+tableName+" WHERE phone = :phone";
			_getPhoneCountStatement.parameters[":phone"] = phone;
			_getPhoneCountStatement.execute();
			
			var _result:SQLResult = _getPhoneCountStatement.getResult(); 
			if(_result.data){
				return _result.data[0].count;
			}
			return 0;
		}
		
		public function getEverything(tableName:String):Array
		{
			_getEverythingStatement.text = "SELECT * FROM "+tableName;
			_getEverythingStatement.execute();
			var _result:SQLResult = _getEverythingStatement.getResult(); 
			if(_result.data){
				
				return _result.data;
			}
			return [];
		}
		
		public function wipe(tableName:String):void
		{
			_deleteStatement = new SQLStatement();
			_deleteStatement.sqlConnection = _connection;
			_deleteStatement.text = "DROP TABLE IF EXISTS "+tableName;
			_deleteStatement.execute();
			_createStatement.execute();
		}
		
		public function addPrize(prize:String, dateString:String, tableName:String):void
		{
			//var _splitString:Array = dateString.split(" ");
			//var _dateStartSplit:Array = _splitString[0].split('/');
			//var _dateStringModified:String = _dateStartSplit.reverse().join('/') +" "+ _splitString[1];
			//var _date:Date = new Date(_dateStringModified);
			var _date:Date = new Date(dateString);
			_addRecordStatement.text = "INSERT INTO "+tableName+" (prize, vended, barcode, date, timestamp) VALUES (:prize, :vended, :barcode, :date, :timestamp)";
			_addRecordStatement.parameters[":prize"] = prize;
			_addRecordStatement.parameters[":vended"] = 0;
			_addRecordStatement.parameters[":barcode"] = "";
			_addRecordStatement.parameters[":timestamp"] = _date.time;
			_addRecordStatement.parameters[":date"] = _date.toString().split(" GMT")[0];
			_addRecordStatement.execute();
		}
		
		public function add(data:Object,tableName:String):void
		{
			_addRecordStatement.text = "INSERT INTO "+tableName+" (prize, vended, barcode, date, timestamp) VALUES (:prize, :vended, :barcode, :date, :timestamp)";
			_addRecordStatement.parameters[":prize"] = data.prize;
			_addRecordStatement.parameters[":vended"] = 0;
			_addRecordStatement.parameters[":barcode"] = "";
			_addRecordStatement.parameters[":timestamp"] = data.time;
			_addRecordStatement.parameters[":date"] = data.date_string;
			_addRecordStatement.execute();
		}
		
		public function getDateString():String
		{
			var _date:Date = new Date();
			var _dateString:String = _date.date + "."+(_date.month+1)+"."+_date.fullYear;
			return _dateString;
		}
		
		public function deleteItem(data:Object,tableName:String):void
		{
			_deleteItemStatement.text = "DELETE FROM "+tableName+" WHERE id = :id";
			_deleteItemStatement.parameters[":id"] = data.id;
			_deleteItemStatement.execute();
		}
		
		private function randomize ( a : *, b : * ) : int {
			return ( Math.random() > .5 ) ? 1 : -1;
		}
		
		public function getDB():File
		{
			return _dbFile;
		}
	}
}

