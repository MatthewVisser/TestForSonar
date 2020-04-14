package app.services.serverapi.calls
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import app.services.serverapi.APIEvent;
	
	public class CallAuthenticate extends EventDispatcher implements ICall
	{
		private var _apiURL:String;
		private var _urlLoader:URLLoader;
		
		public function CallAuthenticate()
		{
			
		}
		
		public function doCall(data:Object):void
		{
			_urlLoader = new URLLoader();
			_urlLoader.addEventListener(Event.COMPLETE, loadedHandler);
			_urlLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, responseStatusHandler);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);

			var _urlRequest:URLRequest = new URLRequest(data.url);
			
			var _headerToken:URLRequestHeader = new URLRequestHeader("Authorization", "Basic Y29rZV9waG90b19ib290aDpZUzFKRTcwM0szVFVLWE9OSUZZWA==");
			//var _headerAppKey:URLRequestHeader = new URLRequestHeader("grant_type", "client_credentials");
			//_urlRequest.requestHeaders.push(_headerToken, _headerAppKey);
			_urlRequest.requestHeaders.push(_headerToken);
			_urlRequest.method = URLRequestMethod.POST;
			var _requestVars:URLVariables = new URLVariables();
			//_requestVars.grant_type = "client_credentials";
			_requestVars.username = "smart_machine@colensobbdo.co.nz";
			_requestVars.password = "haveAL0vely$ale";
			_urlRequest.data = _requestVars;
			_urlLoader.load(_urlRequest);
		}
		
		protected function securityErrorHandler(event:SecurityErrorEvent):void
		{
			dispatchEvent(new APIEvent(APIEvent.EVENT_AUTH_FAIL));
			removeHandlers();
		}
		
		protected function ioErrorHandler(event:IOErrorEvent):void
		{
			dispatchEvent(new APIEvent(APIEvent.EVENT_AUTH_FAIL));
			removeHandlers();
		}
		
		protected function responseStatusHandler(event:HTTPStatusEvent):void
		{
		}
		
		protected function loadedHandler(event:Event):void
		{
			var _dataString:String = event.target.data;
			if(_dataString.indexOf("</error>") > -1){
				dispatchEvent(new APIEvent(APIEvent.EVENT_AUTH_FAIL));
			} else {
				try {
					var _responseData:Object = JSON.parse(event.target.data);
					dispatchEvent(new APIEvent(APIEvent.EVENT_AUTH_SUCCESS,_responseData));
				} catch(e:Error){
					"Error parsing json for AUTH call";
				}
			}
			removeHandlers();
		}
		
		protected function removeHandlers():void
		{
			_urlLoader.removeEventListener(Event.COMPLETE, loadedHandler);
			_urlLoader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, responseStatusHandler);
			_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		}
	}
}