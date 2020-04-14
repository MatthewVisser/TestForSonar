package app.screens
{
	import flash.text.TextFormatAlign;
	
	import app.constants.Settings;
	import app.factories.Factory;
	import app.factories.Fonts;
	import app.models.AppModel;
	import app.models.PrizeDatesModel;
	import app.services.ArduinoController;
	import app.services.NavController;
	import app.services.SharedObjectService;
	import app.services.Utility;
	
	import benkuper.nativeExtensions.NativeSerial;
	import benkuper.nativeExtensions.SerialPort;
	
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.PickerList;
	import feathers.controls.Screen;
	import feathers.data.ListCollection;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalAlign;
	import feathers.layout.VerticalLayout;
	
	import starling.display.Quad;
	import starling.events.Event;
	
	public class SettingsScreen extends Screen
	{
		private var _labelPrizesVended:Label;
		private var _pickerListArduino:PickerList;
		private var _labelArduinoResult:Label;

		public function SettingsScreen()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			var _bg:Quad = new Quad(AppModel.stageWidth, AppModel.stageHeight);
			addChild(_bg);
			
			var _layoutGroup:LayoutGroup = new LayoutGroup();
			var _verticalLayout:VerticalLayout = new VerticalLayout();
			_verticalLayout.gap = 3;
			_layoutGroup.layout = _verticalLayout;
			_verticalLayout.verticalAlign = VerticalAlign.TOP;
			_verticalLayout.horizontalAlign = HorizontalAlign.CENTER;
			_verticalLayout.paddingTop = 10;
			addChild(_layoutGroup);
			_layoutGroup.setSize(AppModel.stageWidth, AppModel.stageHeight);
	
			var _labelHeading:Label = Factory.label(Fonts.FONT_LIGHT, 72, 0x000000, TextFormatAlign.CENTER, true);
			_labelHeading.text = "Settings";
			_labelHeading.width = AppModel.stageWidth;
			_layoutGroup.addChild(_labelHeading);
			
			var _labelVersion:Label = Factory.label(Fonts.FONT_LIGHT, 32, 0x000000, TextFormatAlign.LEFT, true);
			_labelVersion.text = "Ver: "+Utility.getAppVersion();
			_labelVersion.width = 200;
			addChild(_labelVersion);
			_labelVersion.x = 10;
			_labelVersion.y = 20;
	
			addGapVert(_layoutGroup, 10);
			
			var _labelArduino:Label = Factory.label(Fonts.FONT_BOLD, 24, 0x000000, TextFormatAlign.CENTER, true);
			_labelArduino.text = "Arduino port";
			_labelArduino.width = AppModel.stageWidth;
			_layoutGroup.addChild(_labelArduino);
			_pickerListArduino = Factory.dropDown("Select Arduino port", new ListCollection([]));
			_pickerListArduino.addEventListener(Event.CHANGE, listSelectedHandler);
			_layoutGroup.addChild(_pickerListArduino);
			
			addGapVert(_layoutGroup, 10);
			
			_labelArduinoResult = Factory.label(Fonts.FONT_BOLD, 32, 0x000000, TextFormatAlign.LEFT, true);
			_labelArduinoResult.text = " ";
			_labelArduinoResult.width = 660;
			_layoutGroup.addChild(_labelArduinoResult);
			
			addGapVert(_layoutGroup, 20);

			
			var _labelMoveInstruction:Label = Factory.label(Fonts.FONT_LIGHT, 22, 0x000000, TextFormatAlign.CENTER, true);
			_labelMoveInstruction.text = "Use A or Z on the keyboard to adjust app scale and arrow keys for x and y adjustment, F to reset";
			_labelMoveInstruction.width = AppModel.stageWidth;
			_layoutGroup.addChild(_labelMoveInstruction);

			addGapVert(_layoutGroup, 5);

			var _btnSave:Button = Factory.btnGeneric("SAVE", 250);
			addChild(_btnSave);
			_btnSave.addEventListener(Event.TRIGGERED, saveHandler);
			_btnSave.x = 408;
			_btnSave.y = 879;

			if(Utility.debugModeDetected()){
				var _btnTestPrizes:Button = Factory.btnGeneric("TEST PRIZES", 600);
				addChild(_btnTestPrizes);
				_btnTestPrizes.addEventListener(Event.TRIGGERED, testPrizesHandler);
				_btnTestPrizes.x = 50;
				_btnTestPrizes.y = AppModel.stageHeight - 340;
				_btnTestPrizes.scale = 0.75;
			}
			
			
			var _arduino:String = SharedObjectService.getString(Settings.ARDUINO_NAME,"");
			for (var j:int = 0; j < _pickerListArduino.dataProvider.length; j++) {
				var _itemData:Object = _pickerListArduino.dataProvider.getItemAt(j);
				if(_itemData.value === _arduino){
					_pickerListArduino.selectedIndex = j;
				}
			}	
			
			_labelPrizesVended = Factory.label(Fonts.FONT_LIGHT, 22, 0x000000, TextFormatAlign.CENTER, true);
			_labelPrizesVended.width = 600;
			_layoutGroup.addChild(_labelPrizesVended);
			addGapVert(_layoutGroup, 10);
			
			
			
			var _prizeVendedStats:Array = [];
			
			showPrizesVended(PrizeDatesModel.PRIZE_TABLE_BIG_BOYS_TOYS);

			addGapVert(_layoutGroup, 20);
			
			updateFilters();
			
			AppModel.arduinoController.addEventListener(ArduinoController.EVENT_SERIAL_DATA, serialDataHandler);
		}
		
		private function showPrizesVended(tableName:String):void
		{
			var _prizes:Array = AppModel.prizeDatesModel.getPrizesVendedCount(tableName);
			_labelPrizesVended.text = "Prizes Given:\n";
			for (var i:int = 0; i < _prizes.length; i++) 
			{
				var _prize:Object = _prizes[i];
				_labelPrizesVended.text += _prize.prize + ": "+_prize.count+", ";
			}
		}
		
		private function serialDataHandler(event:Event):void
		{
			var _text:String = event.data.data;
			trace("_text:"+_text);
			_labelArduinoResult.text = Utility.timeString()+" "+_text;
		}
		
		private function updateFilters():void
		{
			var _ports:Vector.<SerialPort> = NativeSerial.instance.listPortsFilter("");
			var _portsList:Array = [];
			for each (var _port:SerialPort in _ports) 
			{
				_portsList.push({text:_port.fullName, value:_port.COMID});
			}
			_pickerListArduino.dataProvider = new ListCollection(_portsList);
		}
		
		private function testPrizesHandler():void
		{
			saveSelections();
			NavController.showScreen(ScreenNames.TEST_PRIZES);
		}
		
		override public function dispose():void
		{
			AppModel.arduinoController.removeEventListener(ArduinoController.EVENT_SERIAL_DATA, serialDataHandler);
			super.dispose();	
		}

		private function listSelectedHandler(event:Event):void
		{
			var _target:PickerList = PickerList(event.target);
			_target.closeList();
			if(_target == _pickerListArduino){
				if(_pickerListArduino.selectedIndex != -1){
					var _port:String  = _pickerListArduino.dataProvider.getItemAt(_pickerListArduino.selectedIndex).value;
					SharedObjectService.saveString(Settings.ARDUINO_PORT, _port);
					AppModel.arduinoController.connectToPort(_port);
				}
			}
		}

		private function saveHandler():void
		{
			saveSelections();
			NavController.showScreen(ScreenNames.START);
		}
		
		private function saveSelections():void
		{
			if(_pickerListArduino.selectedIndex != -1) SharedObjectService.saveString(Settings.ARDUINO_NAME,_pickerListArduino.dataProvider.getItemAt(_pickerListArduino.selectedIndex).value);
			
		}
		
		private function addGapVert(target:LayoutGroup, gapHeight:Number=1):void{
			var _gap:Quad = new Quad(1,gapHeight);
			_gap.alpha = 0;
			target.addChild(_gap);
		}
	}
}