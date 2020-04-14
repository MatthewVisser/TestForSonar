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
	
	public class CallGetPhotos extends EventDispatcher implements ICall
	{
		private var _apiURL:String;
		private var _urlLoader:URLLoader;
		
		public function CallGetPhotos()
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
			var _headerToken:URLRequestHeader = new URLRequestHeader("Authorization", "Bearer "+data.accessToken);
			_urlRequest.requestHeaders.push(_headerToken);
			_urlRequest.method = URLRequestMethod.GET;
			var _requestVars:URLVariables = new URLVariables();
			_requestVars.location = data.location;
			_urlRequest.data = _requestVars;
			_urlLoader.load(_urlRequest);
		}
		
		protected function securityErrorHandler(event:SecurityErrorEvent):void
		{
			dispatchEvent(new APIEvent(APIEvent.EVENT_GET_PHOTOS_FAIL));
			removeHandlers();
		}
		
		protected function ioErrorHandler(event:IOErrorEvent):void
		{
			dispatchEvent(new APIEvent(APIEvent.EVENT_GET_PHOTOS_FAIL));
			removeHandlers();
		}
		
		protected function responseStatusHandler(event:HTTPStatusEvent):void
		{
			if(event.status == 401){
				dispatchEvent(new APIEvent(APIEvent.EVENT_AUTH_INVALID));
			}
		}
		
		protected function loadedHandler(event:Event):void
		{
			var _dataString:String = event.target.data;
			if(_dataString.indexOf("</error>") > -1){
				dispatchEvent(new APIEvent(APIEvent.EVENT_GET_PHOTOS_FAIL));
			} else {
				var _responseData:Object = JSON.parse(event.target.data);
				dispatchEvent(new APIEvent(APIEvent.EVENT_GET_PHOTOS_SUCCESS,_responseData));
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