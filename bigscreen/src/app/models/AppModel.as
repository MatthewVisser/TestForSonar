package app.models
{
	import flash.display.Stage;
	
	import app.services.ResizeService;
	import app.views.SlotMachine;
	
	import starling.display.Stage;
	import app.services.ArduinoController;

	public class AppModel
	{
		public static var stage:flash.display.Stage;
		public static var stageStarling:starling.display.Stage;
		public static var stageWidth:Number;
		public static var stageHeight:Number;
		public static var scale:Number = 1;
		public static var resizeService:ResizeService;
		public static var prizeDatesModel:PrizeDatesModel;
		public static var selectedPrize:String;
		public static var prizeItemsModel:PrizeItemsModel;
		public static var slotMachine:SlotMachine = new SlotMachine;
		public static var arduinoController:ArduinoController;

		
		public function AppModel()
		{
			
		}
	}
}