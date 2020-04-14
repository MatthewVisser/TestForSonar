package app.services.serverapi
{
	import flash.events.EventDispatcher;
	
	import app.services.serverapi.calls.CallAuthenticate;
	import app.services.serverapi.calls.CallGetPhotos;

	public class ServerAPI extends EventDispatcher
	{
		public static const CALL_AUTHENTICATE:String = "callAuthenticate";
		public static const CALL_GET_PHOTOS:String = "callGetPhotos";
		public static const CALL_POST_PHOTO:String = "callPostPhoto";
		private var _apiURL:String = "";
		private var _accessToken:String ="";
		private var _uploader:Uploader;
		private var _uploadSuccessCallback:Function;
		private var _uploadFailCallback:Function;
		private var _uploadAttempts:int = 0;
		private var _previousFileName:String;
		public function ServerAPI(apiURL:String, uploadSuccessCallback:Function=null, uploadFailCallback:Function=null)
		{
			_apiURL = apiURL;
			_uploader = new Uploader(_apiURL+"/photo");
			_uploader.addEventListener(APIEvent.EVENT_POST_PHOTO_SUCCESS, eventHandler);
			_uploader.addEventListener(APIEvent.EVENT_POST_PHOTOS_FAIL, eventHandler);
			_uploader.addEventListener(APIEvent.EVENT_AUTH_INVALID, eventHandler);
			_uploadSuccessCallback = uploadSuccessCallback;
			_uploadFailCallback = uploadFailCallback;
		}
		
		public function doCall(callType:String, data:Object=null):void
		{
			if(!data) data = new Object();
			
			if(_accessToken == ""){//If no valid access token, get one.
				callType = CALL_AUTHENTICATE;
				data = new Object();
			}
			switch(callType)
			{
				case CALL_AUTHENTICATE:
				{
					data.url =  _apiURL + "/token";
					var _callAuthenticate:CallAuthenticate = new CallAuthenticate();
					_callAuthenticate.addEventListener(APIEvent.EVENT_AUTH_SUCCESS, eventHandler, false, 0, true);
					_callAuthenticate.addEventListener(APIEvent.EVENT_AUTH_FAIL, eventHandler, false, 0, true);
					_callAuthenticate.doCall(data);
					break;
				}
					
				case CALL_GET_PHOTOS:
				{
					data.url =  _apiURL + "/photo";
					data.accessToken = _accessToken;
					var _callGetPhotos:CallGetPhotos = new CallGetPhotos();
					_callGetPhotos.addEventListener(APIEvent.EVENT_GET_PHOTOS_SUCCESS, eventHandler, false, 0, true);
					_callGetPhotos.addEventListener(APIEvent.EVENT_GET_PHOTOS_FAIL, eventHandler, false, 0, true);
					_callGetPhotos.addEventListener(APIEvent.EVENT_AUTH_INVALID, eventHandler, false, 0, true);
					_callGetPhotos.doCall(data);
					break;
				}
					
				case CALL_POST_PHOTO:
				{
					_uploader.uploadFile(data.file, data.phoneNumber, data.event, data.location, data.commonId, _accessToken);
					
					break;
				}
			}
		}
		
		protected function eventHandler(event:APIEvent):void
		{
			switch(event.type)
			{
				case APIEvent.EVENT_AUTH_INVALID:
				{
					_accessToken = "";//Reset access token if invalid token detected
					break;
				}
					
				case APIEvent.EVENT_AUTH_SUCCESS:
				{
					_accessToken = event.data.access_token;	
					break;
				}
					
				case APIEvent.EVENT_GET_PHOTOS_SUCCESS:
				{

					break;
				}
					
				case APIEvent.EVENT_POST_PHOTO_SUCCESS:
				{
					_uploadSuccessCallback.call(null, event.data.file.name);
					break;
				}
					
				case APIEvent.EVENT_POST_PHOTOS_FAIL:
				{
					if(_previousFileName != event.data.file.name){
						_previousFileName = event.data.file.name;
						_uploadAttempts = 0;
					} else {
						_uploadAttempts++;
					}
					if(_uploadAttempts >= 10){
						_uploadFailCallback.call(null, event.data.file.name);
					}
					break;
				}
			}
			
		}
	}
}