package app.services
{
	import com.greensock.TweenMax;
	
	import flash.desktop.NativeApplication;
	import flash.events.DatagramSocketDataEvent;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.net.DatagramSocket;
	import flash.net.GroupSpecifier;
	import flash.net.InterfaceAddress;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import starling.display.Stage;
	import starling.events.EventDispatcher;
	
	public class NetworkConnection extends EventDispatcher
	{
		public static const MESSAGE_RECIEVED:String = "messageRecieved";
		private var _serverSocket:DatagramSocket = new DatagramSocket();
		private var _clientSocket:DatagramSocket = new DatagramSocket();
		private var _groupName:String;
		private var _netConnection:NetConnection;
		private var _group:NetGroup;
		private var _connectedRTMP:Boolean = false;
		private var _stage:Stage;
		private var _groupIPAddresses:Array = [];
		private var _ipAddress:String = "";
		private var _deviceID:Number;
		private var _deviceName:String;
		private var _messageID:Number = 0;
		private var _listenPort:int;
		private var _sendPort:int;
		private var _messageHistory:Dictionary = new Dictionary();
		
		public function NetworkConnection(stage:Stage, groupName:String, listenPort:int=8080, sendPort:int=8080)
		{
			_groupName = groupName;
			_stage = stage;
			_listenPort = listenPort;
			_sendPort = sendPort;
			updateIPAddress();
			_ipAddress = getIPAddress();
			_deviceID = Math.round(Math.random() * 100000000);
			connectUDP();
			connectRTMP();
		}
		
		public function set deviceName(value:String):void
		{
			_deviceName = value;
		}

		private function updateIPAddress():void
		{
			_ipAddress = getIPAddress();
			TweenMax.delayedCall(20, updateIPAddress);
		}
		
		private function connectUDP():void
		{
			try{
				_serverSocket.bind(_listenPort);
				_serverSocket.addEventListener(DatagramSocketDataEvent.DATA, dataReceived);
				_serverSocket.receive();
			} catch (e:Error){
				//Logger.log("Couldnt bind to udp", Logger.NETWORK);
			}
			
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, exitHandler);
		}
		
		private function connectRTMP():void{
			_netConnection = new NetConnection();
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
			_netConnection.connect("rtmfp:");
		}
			
		private function netStatus(e:NetStatusEvent):void{
			//Logger.log(e.info.code, Logger.NETWORK);

			switch (e.info.code)
			{
				case "NetConnection.Connect.Success" :
					setupGroup();
					break;
				
				case "NetGroup.Connect.Success" :
					_connectedRTMP = true;
					sendMessage({type:"connected"});
					break;
				
				case "NetGroup.Posting.Notify" :
					processMessage(e.info.message);
					break;
				
				case "NetConnection.Connect.NetworkChange":
					_ipAddress = getIPAddress();
					break;
			}
		}
		
		private function setupGroup():void{
			if(!_group){
				var groupspec:GroupSpecifier = new GroupSpecifier(_groupName);
				groupspec.postingEnabled = true;
				groupspec.ipMulticastMemberUpdatesEnabled = true;
				groupspec.addIPMulticastAddress("225.225.0.1:30303");
				_group = new NetGroup(_netConnection, groupspec.groupspecWithAuthorizations());
				_group.addEventListener(NetStatusEvent.NET_STATUS,netStatus);
				
			}
		}
		
		public function sendMessage(message:Object, onlyUDP:Boolean=false, targetIPAddress:String = ""):void{
			_messageID++;
			message.time = new Date().time;
			message.messageID = _messageID;
			message.deviceID = _deviceID;
			message.deviceIP = _ipAddress;
			message.deviceName = _deviceName;
			if(_group && !onlyUDP){
				sendRTMP(message);
			} 	
			sendUDP(message, targetIPAddress);
		}
		
		private function sendUDP(message:Object, targetIPAddress:String=""):void
		{
			var _data:ByteArray = new ByteArray();
			message.kind = "UDP";
			var _messageString:String = JSON.stringify(message); 
			
			//If data is less then 9216 its not going to break the socket connection when we try to send it, so don't
			if(_messageString.length <= 9000){
				_data.writeUTFBytes(_messageString);
				
				//If we can get a device ip address out of targetDevice then use it
				//Otherwise send to everyone
				if(targetIPAddress){
					try{
						if(_clientSocket){
							_clientSocket.send(_data, 0, 0, targetIPAddress, _sendPort);
						}
					} catch(error:Error) {
						trace("error sending1:"+_messageString.length);
					}
					
				} else {
					for each (var _groupIPAddress:String in _groupIPAddresses) {
						try{
							if(_clientSocket){
								trace("_groupIPAddress:"+_groupIPAddress);
								_clientSocket.send(_data, 0, 0, _groupIPAddress, _sendPort);
							}
							
						} catch(error:Error) {
							trace("error sending2:"+_messageString.length);
						}
					}
				}
				
			}
		}
		
		private function sendRTMP(message:Object):void
		{
			message.kind = "RTMP";
			_group.post(message);
		}
		
		private function dataReceived(e:DatagramSocketDataEvent):void
		{
			var _dataString:String = e.data.readUTFBytes(e.data.bytesAvailable);
			var _data:Object = JSON.parse(_dataString);
			processMessage(_data);
		}
		
		private function processMessage(data:Object):void
		{
			var _deviceIDFromMsg:Number = data.deviceID;
			var _messageID:Number = data.messageID;
			var _previousMessageID:Number = 0;
			if(_messageHistory[_deviceIDFromMsg]){
				_previousMessageID = _messageHistory[_deviceIDFromMsg];
			}
			if(_groupIPAddresses.indexOf(data.deviceIP) == -1) {
				_groupIPAddresses.push(data.deviceIP);
			}
			//Ignore if this id has already been recieved
			//if(_messageID <= _previousMessageID) return;
			
			if(data.targetDevice){//If a targetDevice found
				if(data.targetDevice != _deviceID) return;//And if it doesnt match up return
			}
			
			_messageHistory[_deviceIDFromMsg] = _messageID;
			dispatchEventWith(MESSAGE_RECIEVED, true, data);
		}
		
		public function getIPAddress():String
		{
			var networkInfo:NetworkInfo = NetworkInfo.networkInfo; 
			var interfaces:Vector.<NetworkInterface> = networkInfo.findInterfaces(); 
			var _address:String = "";
			var _addressArray:Array = [];
			if( interfaces != null ) 
			{ 
				for each ( var interfaceObj:NetworkInterface in interfaces ) 
				{ 
					var _active:Boolean = interfaceObj.active;
					for each ( var address:InterfaceAddress in interfaceObj.addresses ) 
					{ 
						if(_active){
							_address = address.address;
							if(address.ipVersion == "IPv4"){
								_addressArray.push(_address);
							}
						}
					}
				}             
			}
			return _addressArray[0];
		}
		
		public function open():void
		{
			try{
				_serverSocket.bind(_listenPort);
				_serverSocket.addEventListener(DatagramSocketDataEvent.DATA, dataReceived);
				_serverSocket.receive();
			} catch (e:Error){
				//Logger.log("Couldnt bind to udp", Logger.NETWORK);
			}
		}
		
		public function close():void
		{
			//Logger.log("closing udp", Logger.NETWORK);
			if(_serverSocket){
				try{
					_serverSocket.removeEventListener(DatagramSocketDataEvent.DATA, dataReceived);
					_serverSocket.close();
					_serverSocket = null;
				} catch (e:Error){
					//Logger.log("error closing server udp", Logger.NETWORK);
				}
			}
			if(_group){
				_group.close();
			}
		}
		
		protected function exitHandler(event:Event):void
		{
			close();
		}
		
		public function addIPAddress(ipAddress:String):void
		{
			if(ipAddress.indexOf(".") == -1) return;
			if(ipAddress.length < 6) return;
			if(_groupIPAddresses.indexOf(_ipAddress) > -1) return;
			_groupIPAddresses.push(ipAddress);
		}
	}
}
