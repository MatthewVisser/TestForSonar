package
{
	import com.greensock.TweenMax;
	
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;
	import flash.events.UncaughtErrorEvent;
	import flash.geom.Rectangle;
	
	import app.Main;
	import app.models.AppModel;
	import app.services.Logger;
	import app.services.NativeUpdater;
	import app.services.Utility;
	
	import starling.core.Starling;
	
	[SWF(backgroundColor="#000000", width="720", height="1280", frameRate="25")]
	
	public class NeonArmageddon extends Sprite
	{
		private var _starling:Starling;

		public function NeonArmageddon()
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		protected function addedToStageHandler(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT; 
			stage.frameRate = 30;
			AppModel.stage = stage;
			this.mouseEnabled = this.mouseChildren = false;
			if(Utility.debugModeDetected()){
				continueStartup();
			} else {
				//var _nativeUpdater:NativeUpdater = new NativeUpdater(app.Main.APP_HOST_XML, continueStartup, stage);
				var _nativeUpdater:NativeUpdater = new NativeUpdater("https://apps.satelliteapps.co.nz/airappupdates/neonarmageddon.xml", continueStartup, stage);
				_nativeUpdater.start();
				stage.loaderInfo.uncaughtErrorEvents.addEventListener(
					UncaughtErrorEvent.UNCAUGHT_ERROR, function(event:UncaughtErrorEvent):void {
						Logger.log(event.error + " Error: " + event.error.message, "ERROR");
					}
				);
			}
		}
		
		protected function continueStartup(event:Event=null):void
		{
			_starling = new Starling(Main, stage, null, null, Context3DRenderMode.AUTO, "auto");
			_starling.enableErrorChecking = false;
			_starling.showStats = false;
			_starling.start();
			stage.addEventListener(Event.RESIZE, stage_resizeHandler, false, int.MAX_VALUE, true);
			stage_resizeHandler(null);
			
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, stage_activateHandler, false, 0, true);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, stage_deactivateHandler, false, 0, true);
			checkFullscreen();
		}
		
		private function stage_resizeHandler(event:Event):void
		{
			//Bug fix for issue on windows with starling being minimised
			if(stage.stageWidth < 200 || stage.stageHeight < 200) return;
			
			_starling.stage.stageWidth = stage.stageWidth;
			_starling.stage.stageHeight = stage.stageHeight;
			
			const viewPort:Rectangle = _starling.viewPort;
			
			viewPort.width = stage.stageWidth;
			viewPort.height = stage.stageHeight;
			
			try{
				_starling.viewPort = viewPort;
			}
			catch(error:Error) {}
		}
		
		private function stage_deactivateHandler(event:Event):void
		{
			_starling.stop(true);
			//TweenMax.pauseAll();
		}
		
		private function stage_activateHandler(event:Event):void
		{
			_starling.start();
			//TweenMax.resumeAll();
		}

		//Force app to return to fullscreen if a release build
		private function checkFullscreen():void
		{
			TweenMax.killDelayedCallsTo(checkFullscreen);
			TweenMax.delayedCall(10, checkFullscreen);
			if(Utility.debugModeDetected()) return;

			if(stage.displayState == StageDisplayState.NORMAL){
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			}
		}
	}
}