package app.services
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import benkuper.nativeExtensions.NativeSerial;
	import benkuper.nativeExtensions.SerialEvent;
	import benkuper.nativeExtensions.SerialPort;
	
	import starling.events.EventDispatcher;
	
	public class ArduinoController extends EventDispatcher
	{
		public static const EVENT_SERIAL_DATA:String = "eventSerialData";
		private var _port:SerialPort;
		private var _portBaudRate:int = 9600;//19200;
		public function ArduinoController()
		{
			super();
			trace("init");
			NativeSerial.init();
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, exitHandler);
		}
		
		protected function exitHandler(event:Event):void
		{
			if(_port){
				try{
					_port.removeEventListener(SerialEvent.DATA, serialData);
					_port.close();
					_port.clean();
					_port = null;
				} catch (error:Error){
					trace("error closing arduino port");
				}
			}
		}
		
		public function connectToPort(comPort:String):void
		{
			trace("connectToPort:"+comPort);
			if(_port){
				_port.removeEventListener(SerialEvent.DATA, serialData);
				_port.close();
				_port.clean();
				_port = null;
			}
			_port = NativeSerial.getPort(comPort);
			
			if(_port){
				_port.open(_portBaudRate );
				_port.mode = SerialPort.MODE_NEWLINE;
				_port.addEventListener(SerialEvent.DATA, serialData);
			}
			
		}
		
		private function serialData(e:SerialEvent):void 
		{
			if (_port == null) return;
			var _text:String = _port.buffer.readUTFBytes(_port.buffer.bytesAvailable);
			_port.buffer.position = 0;
			dispatchEventWith(EVENT_SERIAL_DATA, true, {data:_text});
		}
		
		public function send(value:String):void
		{
			trace("value:"+value);
			if(_port){
				var _ba:ByteArray = new ByteArray();
				_ba.writeUTFBytes(value);
				_port.writeBytes(_ba);
			}
		}
		
	}
}