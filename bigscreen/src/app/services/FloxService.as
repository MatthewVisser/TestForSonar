package app.services
{
	import com.gamua.flox.Flox;
	import com.greensock.TweenMax;
	
	import flash.desktop.NativeApplication;
	import flash.display.Stage;
	import flash.events.UncaughtErrorEvent;

	public class FloxService
	{
		private static var _id:String;
		private static var _key:String;
		public function FloxService(id:String, key:String, stage:Stage)
		{
			_id = id;
			_key = key;
			restartFlox();
			if(!debugModeDetected()){
				stage.loaderInfo.uncaughtErrorEvents.addEventListener(
					UncaughtErrorEvent.UNCAUGHT_ERROR, function(event:UncaughtErrorEvent):void {
						Flox.logError(event.error, "Error: " + event.error.message);
					}
				);
			}
		}
		
		public static function restartFlox():void
		{
			Flox.shutdown();
			Flox.init(_id, _key, getAppVersion());
			TweenMax.killDelayedCallsTo(restartFlox);
			TweenMax.delayedCall(60*60*2, restartFlox);
		}
		
		private static function debugModeDetected():Boolean
		{
			var _debugModeDetected:Boolean = (new Error().getStackTrace().search(/:[0-9]+]$/m) > -1);
			return _debugModeDetected;
		}
		
		private static function getAppVersion():String
		{
			var appXML:XML =  NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXML.namespace();
			var _appVersion:String = appXML.ns::versionNumber;
			return _appVersion;
		}
	}
}