package app
{

import app.services.Utility;

import com.greensock.TweenMax;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.ui.Keyboard;
	
	import app.assets.AssetController;
	import app.constants.Settings;
	import app.factories.Factory;
	import app.models.AppModel;
	import app.models.PrizeDatesModel;
	import app.models.PrizeItemsModel;
	import app.screens.ScreenNames;
	import app.screens.SettingsScreen;
	import app.screens.SpinScreen;
	import app.screens.StartScreen;
	import app.screens.TestPrizeScreen;
	import app.services.ArduinoController;
	import app.services.NavController;
	import app.services.ResizeService;
	import app.services.SharedObjectService;
	
	import feathers.controls.ScreenNavigatorItem;

	import flash.utils.getTimer;

	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.TouchEvent;
	
	import treefortress.sound.SoundAS;
	
	public class Main extends Sprite
	{	
		private var _timeOut:Number = 40;
		private var _bgCover:Quad;
		private var _lastArdiunoTriggerTime:int  = 0;
		public function Main()
		{
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		private function addedToStageHandler(event:starling.events.Event):void
		{
			this.removeEventListener(starling.events.Event.ADDED_TO_STAGE, addedToStageHandler);
			SharedObjectService.setup();
			AppModel.stageStarling = stage;
			AppModel.stageWidth = 1080;
			AppModel.stageHeight = 1920;
			
			AssetController.setup(setupStage1, 1);
			AssetController.loadAsset(File.applicationDirectory.resolvePath("images"));
			_lastArdiunoTriggerTime = getTimer();
			AssetController.startLoadingAssets();
		}

		private function setupStage1():void
		{
			SharedObjectService.setup();

			var _bg:Image = AssetController.getImage("neon/bg");
			//addChild(_bg);

			Factory.init();
			Factory.scale = AppModel.scale = 1;
			AppModel.prizeDatesModel = new PrizeDatesModel();
			AppModel.prizeItemsModel = new PrizeItemsModel("app:/items/items.json");
			AppModel.arduinoController = new ArduinoController();

			var _port:String  = SharedObjectService.getString(Settings.ARDUINO_PORT, "");
			if(_port){
				AppModel.arduinoController.connectToPort(_port);
			}

			SoundAS.loadSound("app:/sounds/Answer_Wrong.mp3", "answerWrong");
			SoundAS.loadSound("app:/sounds/gameWon.mp3", "gameWon");
			SoundAS.loadSound("app:/sounds/slotLever.mp3", "slotLever");
			SoundAS.loadSound("app:/sounds/musicShort.mp3", "music");

			NavController.setup(this);

			NavController.addScreen(ScreenNames.SETTINGS, new ScreenNavigatorItem(SettingsScreen));
			NavController.addScreen(ScreenNames.START, new ScreenNavigatorItem(StartScreen));
			NavController.addScreen(ScreenNames.SPIN, new ScreenNavigatorItem(SpinScreen));
			NavController.addScreen(ScreenNames.TEST_PRIZES, new ScreenNavigatorItem(TestPrizeScreen));

			AppModel.stage.addChild(AppModel.slotMachine);
			AppModel.slotMachine.hide();
			
			AppModel.resizeService = new ResizeService(stage, AppModel.stageWidth, AppModel.stageHeight, [this, AppModel.slotMachine]);
			AppModel.resizeService.adjScale = SharedObjectService.getNumber(Settings.ADJUST_SCALE, 0);
			AppModel.resizeService.adjX = SharedObjectService.getNumber(Settings.ADJUST_X, 0);
			AppModel.resizeService.adjY = SharedObjectService.getNumber(Settings.ADJUST_Y, 0);
			AppModel.resizeService.update();
	
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			NavController.showScreen(ScreenNames.START);

			TweenMax.delayedCall(5, start);
		}

		private function start():void
		{
			AppModel.arduinoController.addEventListener(ArduinoController.EVENT_SERIAL_DATA, serialDataHandler);
			NavController.showScreen(ScreenNames.START);
		}
		
		private function serialDataHandler(event:starling.events.Event):void
		{
			var _text:String = event.data.data;
			if(_text.indexOf('p') > -1){
				buttonTrigger();
			}
		}

		private function buttonTrigger():void
		{
			var _timeDiff:Number = getTimer() - _lastArdiunoTriggerTime;
			if(NavController.activeScreenID == ScreenNames.START && _timeDiff > 1000){
				NavController.showScreen(ScreenNames.SPIN);
				_lastArdiunoTriggerTime = getTimer();
			}
		}

		private function keyDownHandler(event:KeyboardEvent):void
		{
			switch(event.keyCode)
			{
				case Keyboard.F:
				{
					AppModel.resizeService.adjScale =0;
					AppModel.resizeService.adjX =0;
					AppModel.resizeService.adjY =0;
					AppModel.resizeService.update();
					SharedObjectService.saveNumber(Settings.ADJUST_SCALE,AppModel.resizeService.adjScale);
					SharedObjectService.saveNumber(Settings.ADJUST_X,AppModel.resizeService.adjY);
					SharedObjectService.saveNumber(Settings.ADJUST_Y,AppModel.resizeService.adjX);
					break;
				}
					
				case Keyboard.NUMPAD_ADD:
				case Keyboard.A:
				{
					AppModel.resizeService.adjScale -=2;
					AppModel.resizeService.update();
					SharedObjectService.saveNumber(Settings.ADJUST_SCALE,AppModel.resizeService.adjScale);
					break;
				}
					
				case Keyboard.NUMPAD_SUBTRACT:
				case Keyboard.Z:
				{
					AppModel.resizeService.adjScale +=2;
					AppModel.resizeService.update();
					SharedObjectService.saveNumber(Settings.ADJUST_SCALE,AppModel.resizeService.adjScale);
					break;
				}
					
				case Keyboard.UP:
				{
					AppModel.resizeService.adjY -=2;
					AppModel.resizeService.update();
					SharedObjectService.saveNumber(Settings.ADJUST_Y,AppModel.resizeService.adjY);
					break;
				}
					
				case Keyboard.DOWN:
				{
					AppModel.resizeService.adjY +=2;
					AppModel.resizeService.update();
					SharedObjectService.saveNumber(Settings.ADJUST_Y,AppModel.resizeService.adjY);
					break;
				}
					
				case Keyboard.LEFT:
				{
					AppModel.resizeService.adjX -=2;
					AppModel.resizeService.update();
					SharedObjectService.saveNumber(Settings.ADJUST_X,AppModel.resizeService.adjX);
					break;
				}
					
				case Keyboard.RIGHT:
				{
					AppModel.resizeService.adjX +=2;
					AppModel.resizeService.update();
					SharedObjectService.saveNumber(Settings.ADJUST_X,AppModel.resizeService.adjX);
					break;
				}
					
				case Keyboard.S:
				{
					NavController.showScreen(ScreenNames.SETTINGS);
					break;
				}
					
				case Keyboard.SPACE:
				{
					if(Utility.debugModeDetected()){
						buttonTrigger();
					}
					break;
				}	
			}
		}
	}
}