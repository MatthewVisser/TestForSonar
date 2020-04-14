package app.services
{
	import com.greensock.TweenMax;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	
	public class NetStatusMonitor extends EventDispatcher
	{
		public static const INTERNET_AVAILABLE:String = "internetAvailable";
		public static const INTERNET_NOT_AVAILABLE:String = "internetNotAvailable";
		
		public var _internetAvailable:Boolean = false;
		private var _timeOutTime:Number = 10;
		private var loader:URLLoader;
		private var request:URLRequest;
		private var _paused:Boolean = false;
		private var _checkingURL:String;
		public function NetStatusMonitor(checkingURL)
		{
			_checkingURL = checkingURL;
		}
		
		public function start():void
		{
			startRequestLoop();
		}
		
		private function startRequestLoop():void
		{
			if(_paused) return;
			if(loader){
				loader.close();
				loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				loader = null;
			}
			
			loader = new URLLoader();
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			
			TweenMax.killDelayedCallsTo(startRequestLoop);
			TweenMax.killDelayedCallsTo(timedOut);
			TweenMax.delayedCall(30, timedOut);
			
			request = new URLRequest(_checkingURL+"?rand="+Math.floor(Math.random() * 100));
			loader.load(request);
			return;
		}
		
		public function pause():void
		{
			_paused = true;
		}
		
		public function resume():void
		{
			_paused = false;
			startRequestLoop();
		}
		
		protected function ioErrorHandler(event:IOErrorEvent):void
		{	
			noInternetFound();
		}
		
		private function timedOut():void
		{
			noInternetFound();
		}
		
		private function noInternetFound():void
		{
			_internetAvailable = false;
			dispatchEvent(new Event(INTERNET_NOT_AVAILABLE));
			restartCheck();
		}
		
		private function httpStatusHandler(event:HTTPStatusEvent):void {
			if(event.status == 0){
				_internetAvailable = false;
				dispatchEvent(new Event(INTERNET_NOT_AVAILABLE, true));
			} else {
				_internetAvailable = true;
				dispatchEvent(new Event(INTERNET_AVAILABLE, true));
			}
			restartCheck();
		}
		
		private function restartCheck():void
		{
			TweenMax.killDelayedCallsTo(startRequestLoop);
			TweenMax.delayedCall(10, startRequestLoop);
		}
		
		public function internetAvailable():Boolean
		{
			return _internetAvailable;
		}
	}
}