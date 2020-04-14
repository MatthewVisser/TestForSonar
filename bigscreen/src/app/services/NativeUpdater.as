package app.services
{
	import com.greensock.TweenMax;
	
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;
	
	import app.factories.Factory;
	import app.factories.Fonts;
	
	public class NativeUpdater
	{
		public static const  NO_UPDATE_FOUND:String = "No update found";
		public static const  DOWNLOADING_UPDATE:String = "Downloading update";
		public static const  ERROR_DOWNLOADING_UPDATE:String = "Error downloading update";
		/**
		 * URL pointing to the file with the update descriptor.
		 * 
		 * In the ADC demo it only points to a local folder where application is installed.
		 * In case of real application it should point to a file on HTTP server.
		 */
		protected var _updateURL:String = "";
		
		/**
		 * Downloaded update file
		 */
		protected var updateFile:File;
		
		/**
		 * FileStream used to write update file downloaded bytes.
		 */
		protected var fileStream:FileStream;
		
		/**
		 * URLStream used to download update file bytes.
		 */
		protected var urlStream:URLStream;
		
		/**
		 * Initiates update procedure. Update procedure will run if current application
		 * version is not equal to the remote version. This comparison is done based on
		 * the values from application descriptor and downloaded update descriptor.
		 */
		
		private var _continueCallback:Function;
		private var _updateInProgress:Boolean = false;
		private var _stage:Stage;
		private var _container:Sprite = new Sprite();
		private var _viewCreated:Boolean = false;
		private var _topContainer:Sprite = new Sprite();
		private var _textfieldStatus:TextField;
		
		public function NativeUpdater(updateURL:String,continueCallback:Function, stage:Stage):void
		{
			_stage = stage;
			_continueCallback = continueCallback;
			_updateURL = updateURL; 
			createView();
		}
		
		public function start():void
		{
			if(!_updateInProgress){
				_updateInProgress = true;
				statusUpdate("Checking...");
				downloadUpdateDescriptor();
				_topContainer.addChild(_container);
				_container.x = 280;
				_container.y = 90;
				_stage.addChild(_topContainer);
				_stage.addEventListener(Event.RESIZE, resize);
				resize();
			}
		}
		
		private function resize(event:Event=null):void{
			var _targetRatio:Number;
			var _screenRatio:Number;
			var _calcWidth:int;
			var _calcHeight:int;
			var _calcOffsetX:int;
			var _calcOffsetY:int;
			var _target:Object;
			var _targetWidth:Number = 1280;
			var _targetHeight:Number = 800;
		
			_targetRatio = _targetWidth / _targetHeight;
			_screenRatio = _stage.stageWidth / _stage.stageHeight;
			_calcOffsetX = 0;
			_calcOffsetY = 0;	
			if(_screenRatio < _targetRatio){
				_calcWidth = _stage.stageWidth;
				_calcHeight = _calcWidth / _targetRatio;
				_calcOffsetY = (_stage.stageHeight - _calcHeight) * 0.5;
			} else {
				_calcHeight = _stage.stageHeight;
				_calcWidth = _calcHeight * _targetRatio;
				_calcOffsetX = (_stage.stageWidth - _calcWidth) * 0.5;
			}
			var _scaleFactor:Number = _calcWidth/ _targetWidth;
			_topContainer.x = _calcOffsetX;
			_topContainer.y = _calcOffsetY;
			_topContainer.scaleX = _topContainer.scaleY = _scaleFactor;
			
			
		}
		
		private function createView():void
		{
			if(_viewCreated) return;
			
			_container.graphics.beginFill(0xffffff);
			_container.graphics.drawRect(0, 0, 800, 600);
			var _targetWidth:Number = 800;
			var _textfieldHeading:TextField = new TextField();
			_container.addChild(_textfieldHeading);
			_textfieldHeading.y = 40;
			_textfieldHeading.embedFonts = true;
			
			var _textFormatHeading:TextFormat = new TextFormat();
			_textFormatHeading.align = TextFormatAlign.CENTER;
			_textFormatHeading.size = 44;
			_textFormatHeading.font = Fonts.FONT_BOLD;
			_textFormatHeading.color = 0x000000;
			_textfieldHeading.defaultTextFormat = _textFormatHeading;
			_textfieldHeading.text = "Application Updater";
			_textfieldHeading.width = _targetWidth;

			_textfieldStatus = new TextField();
			_container.addChild(_textfieldStatus);
			_textfieldStatus.y = 300;
			_textfieldStatus.width = _targetWidth;
			_textfieldStatus.embedFonts = true;
			_textfieldStatus.text = "TEST";
			
			var _textFormat:TextFormat = new TextFormat();
			_textFormat.align = TextFormatAlign.CENTER;
			_textFormat.size = 30;
			_textFormat.color = 0x000000;
			_textFormat.font = Fonts.FONT_BOLD;
			
			_textfieldStatus.width = _targetWidth;
			_textfieldStatus.defaultTextFormat = _textFormat;
		}
		
		protected function downloadUpdateDescriptor():void
		{
			var updateDescLoader:URLLoader = new URLLoader;
			updateDescLoader.addEventListener(Event.COMPLETE, updateDescLoader_completeHandler);
			updateDescLoader.addEventListener(IOErrorEvent.IO_ERROR, updateDescLoader_ioErrorHandler);
			updateDescLoader.load(new URLRequest(_updateURL));
		}
		
		protected function updateDescLoader_completeHandler(event:Event):void
		{
			var loader:URLLoader = URLLoader(event.currentTarget);
			
			// Closing update descriptor loader
			closeUpdateDescLoader(loader);
		
			// Getting update descriptor XML from loaded data
			var updateDescriptor:XML = XML(loader.data);
			// Getting default namespace of update descriptor
			var udns:Namespace = updateDescriptor.namespace();
			
			// Getting application descriptor XML
			var applicationDescriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
			// Getting default namespace of application descriptor
			var adns:Namespace = applicationDescriptor.namespace();
			
			// Getting versionNumber from update descriptor
			var updateVersion:String = updateDescriptor.udns::versionNumber.toString();
			// Getting versionNumber from application descriptor
			var currentVersion:String = applicationDescriptor.adns::versionNumber.toString();
			
			// Getting update url			
			var updateUrl:String = updateDescriptor.udns::url.toString();
			updateUrl = updateUrl.split(".air").join(".exe");

			// Comparing current version with update version
			if (currentVersion != updateVersion)
			{
				
				// Downloading update file
				downloadUpdate(updateUrl);
				statusUpdate(DOWNLOADING_UPDATE);
			} else {
				statusUpdate(NO_UPDATE_FOUND);
				_updateInProgress = false;
			}
		}
		
		private function statusUpdate(text:String):void
		{
			_textfieldStatus.text = text;
			if(text == NativeUpdater.NO_UPDATE_FOUND || text == NativeUpdater.ERROR_DOWNLOADING_UPDATE) {
				TweenMax.delayedCall(1, finish);
			}
		}
		
		private function finish():void
		{
			if(_continueCallback){
				_continueCallback.call(null);
			}
			if(_container.parent){
				_topContainer.parent.removeChild(_topContainer);
			}
			_stage.removeEventListener(Event.RESIZE, resize);
		}
		
		protected function updateDescLoader_ioErrorHandler(event:IOErrorEvent):void
		{
			closeUpdateDescLoader(URLLoader(event.currentTarget));
			statusUpdate(ERROR_DOWNLOADING_UPDATE);
			//Alert.show("ERROR loading update descriptor:", event.text);
		}
		
		protected function closeUpdateDescLoader(loader:URLLoader):void
		{
			loader.removeEventListener(Event.COMPLETE, updateDescLoader_completeHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, updateDescLoader_ioErrorHandler);
			loader.close();
		}
		
		protected function downloadUpdate(updateUrl:String):void
		{
			// Parsing file name out of the download url
			var fileName:String = updateUrl.substr(updateUrl.lastIndexOf("/") + 1);
			
			// Creating new file ref in temp directory
			updateFile = File.createTempDirectory().resolvePath(fileName);

			// Using URLStream to download update file
			urlStream = new URLStream;
			urlStream.addEventListener(Event.OPEN, urlStream_openHandler);
			urlStream.addEventListener(ProgressEvent.PROGRESS, urlStream_progressHandler);
			urlStream.addEventListener(Event.COMPLETE, urlStream_completeHandler);
			urlStream.addEventListener(IOErrorEvent.IO_ERROR, urlStream_ioErrorHandler);
			urlStream.load(new URLRequest(updateUrl));
		}
		
		protected function urlStream_openHandler(event:Event):void
		{
			// Creating new FileStream to write downloaded bytes into
			fileStream = new FileStream;
			fileStream.open(updateFile, FileMode.WRITE);
		}
		
		protected function urlStream_progressHandler(event:ProgressEvent):void
		{
			// ByteArray with loaded bytes
			var loadedBytes:ByteArray = new ByteArray;
			// Reading loaded bytes
			urlStream.readBytes(loadedBytes);
			// Writing loaded bytes into the FileStream
			fileStream.writeBytes(loadedBytes);
			var _percent:Number = Math.round(event.bytesLoaded / event.bytesTotal * 100);
			statusUpdate("Downloading: "+_percent+"%");
		}
		
		protected function urlStream_completeHandler(event:Event):void
		{
			// Closing URLStream and FileStream
			closeStreams();
			
			// Installing update
			installUpdate();
		}
		
		protected function installUpdate():void
		{
			// Running the installer using NativeProcess API
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo;
			info.executable = updateFile;
			
			var process:NativeProcess = new NativeProcess;
			process.start(info);
			statusUpdate("Restarting app");
			// Exit application for the installer to be able to proceed
			NativeApplication.nativeApplication.exit();
		}
		
		protected function urlStream_ioErrorHandler(event:IOErrorEvent):void
		{
			closeStreams();
			_updateInProgress = false;
			statusUpdate(ERROR_DOWNLOADING_UPDATE);
			//Alert.show("ERROR downloading update:", event.text);
		}
		
		protected function closeStreams():void
		{
			urlStream.removeEventListener(Event.OPEN, urlStream_openHandler);
			urlStream.removeEventListener(ProgressEvent.PROGRESS, urlStream_progressHandler);
			urlStream.removeEventListener(Event.COMPLETE, urlStream_completeHandler);
			urlStream.removeEventListener(IOErrorEvent.IO_ERROR, urlStream_ioErrorHandler);
			urlStream.close();
			
			// Checking if FileStream was instantiated
			if (fileStream)
				fileStream.close();
		}
	}
}