package app.services.serverapi
{
	//import com.gamua.flox.Flox;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	//import app.services.Logger;
	
	public class Uploader extends EventDispatcher
	{
		private var files:Array;
		private var totalSize:uint;
		private var uploadedSoFar:uint;
		private var currentFile:File;
		public var url:String;
		private var eventName:String;
		private var _currentlyUploading:Boolean = false;
		
		public function Uploader(url:String):void
		{
			this.url = url;
		}
	
		public function uploadFile(file:File, phoneNumber:String, event:String, location:String, commonId:String, accessToken:String ):void
		{
			if(_currentlyUploading){
				return;
			}
			currentFile = file;
			_currentlyUploading = true;
			var urlRequest:URLRequest = new URLRequest(url);
			urlRequest.method = URLRequestMethod.POST;
			
			var _headerToken:URLRequestHeader = new URLRequestHeader("Authorization", "Bearer "+accessToken);
			var params:URLVariables = new URLVariables(); 
			params.phoneNumber = phoneNumber;
			params.event = event;
			params.commonId = commonId;
			params.location = location;
			//Logger.log("params: "+params);
			urlRequest.data = params;
			urlRequest.requestHeaders.push(_headerToken);
			file.addEventListener(ProgressEvent.PROGRESS, uploadProgress);
			file.addEventListener(Event.COMPLETE, uploadComplete);
			file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA , uploadServerData);
			file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, uploadError);
			file.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, responseStatusHandler);
			file.addEventListener(IOErrorEvent.IO_ERROR, uploadError);
			
			uploadedSoFar = 0;
			file.upload(urlRequest, "image");
		}
		
		protected function responseStatusHandler(event:HTTPStatusEvent):void
		{
			//Logger.log("responseStatusHandler:"+event);
			if(event.status == 201){
				_currentlyUploading = false;
				uploadedSoFar += currentFile.size;
				//Logger.log("SuccesfullyUploaded: " + currentFile.nativePath, "ERROR");
				dispatchEvent(new APIEvent(APIEvent.EVENT_POST_PHOTO_SUCCESS, {file:currentFile}));
			}
			if(event.status == 401){
				dispatchEvent(new APIEvent(APIEvent.EVENT_AUTH_INVALID));
			}
		}		

		private function uploadProgress(event:ProgressEvent):void 
		{
			//var errorStr:String = event.toString();
			//Logger.log("uploadProgress:"+errorStr);
			var uploadedAmt:uint = uploadedSoFar + event.bytesLoaded;
			var progressEvt:ProgressEvent = event;
			event.bytesLoaded = uploadedAmt;
			event.bytesTotal = totalSize;
			dispatchEvent(event);
		}
		
		private function uploadServerData(event:DataEvent):void
		{
			//var errorStr:String = event.toString();
			//Logger.log("uploadServerData:"+errorStr);
		}
		
		private function uploadComplete(event:Event):void
		{
			//var errorStr:String = event.toString();
			//Logger.log("uploadComplete:"+errorStr);
		}
		
		private function uploadError(event:IOErrorEvent):void
		{
			_currentlyUploading = false;
			//var errorStr:String = event.toString();
			//Logger.log('Error uploading: ' + currentFile.nativePath+ "\n  Message: " + errorStr, "ERROR");
			//Flox.logError("Error uploading: " + currentFile.nativePath + "\n  Message: " + errorStr);
			dispatchEvent(new APIEvent(APIEvent.EVENT_POST_PHOTOS_FAIL, {file:currentFile}));
		}
	}
}