package app.screens
{
	import com.greensock.TweenMax;
	
	import flash.text.TextFormatAlign;
	
	import app.assets.AssetController;
	import app.constants.Colour;
	import app.constants.Locations;
	import app.constants.Settings;
	import app.factories.Factory;
	import app.factories.Fonts;
	import app.models.AppModel;
	import app.models.PrizeDatesModel;
	import app.services.NavController;
	import app.services.SharedObjectService;
	import app.services.Utility;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.Screen;
	import feathers.events.FeathersEventType;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalAlign;
	import feathers.layout.VerticalLayout;
	
	import starling.display.Image;
	import starling.events.Event;
	
	public class TestPrizeScreen extends Screen
	{

		private var _textInstruction1:Label;
		private var _targetFrame:int = 1;
		private var _prizeImageLoader:ImageLoader;
		public function TestPrizeScreen()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			var _layoutGroup:LayoutGroup = new LayoutGroup();
			var _verticalLayout:VerticalLayout = new VerticalLayout();
			_verticalLayout.paddingTop = 0;
			
			_layoutGroup.layout = _verticalLayout;
			_verticalLayout.verticalAlign = VerticalAlign.TOP;
			_verticalLayout.horizontalAlign = HorizontalAlign.CENTER;
			
			addChild(_layoutGroup);
			_layoutGroup.setSize(AppModel.stageWidth, AppModel.stageHeight);
			
			_prizeImageLoader = new ImageLoader();
			_layoutGroup.addChild(_prizeImageLoader);
			_prizeImageLoader.setSize(200, 200);
	
			Utility.addGapVert(_layoutGroup, 40);
			
			_textInstruction1 = Factory.label(Fonts.FONT_CIRCULAR_PRO_BLACK, 70, Colour.GREY, TextFormatAlign.CENTER, true);
			_textInstruction1.width = AppModel.stageWidth;
			_layoutGroup.addChild(_textInstruction1);
			
			Utility.addGapVert(_layoutGroup, 50);
			
			var _btnNext:Button = Factory.btnGeneric("NEXT");
			_layoutGroup.addChild(_btnNext);
			_btnNext.addEventListener(Event.TRIGGERED, spin);
			
			var _settingsBtn:Button = Factory.invBtn(150, 150, 0.0);
			addChild(_settingsBtn);
			_settingsBtn.isLongPressEnabled = true;
			_settingsBtn.longPressDuration = 3;
			_settingsBtn.addEventListener(FeathersEventType.LONG_PRESS, longPressHandler);
		}
		
		private function longPressHandler():void
		{
			NavController.showScreen(ScreenNames.SETTINGS);
		}
		
		private function testPrize():void
		{
			super.initialize();
			
			var _currentPrize:Object;
			var _tableName:String=PrizeDatesModel.PRIZE_TABLE_BIG_BOYS_TOYS;
			 _currentPrize = AppModel.prizeDatesModel.getPrizeStatement(_tableName);
			 if(_currentPrize){
				 
				 var _prizeDetails:Object = AppModel.prizeItemsModel.getItemById(_currentPrize.prize);
				 _textInstruction1.text = "<FONT color='"+Colour.uintToHex(Colour.RED)+"'>CONGRATULATIONS,</FONT>\nYOU'VE WON \n";
				 if(_prizeDetails){
					 _textInstruction1.text += String(_prizeDetails.name).toUpperCase();
					 _prizeImageLoader.source = _prizeDetails.image;
				 } else {
					 _textInstruction1.text = "<FONT color='"+Colour.uintToHex(Colour.RED)+"'>ALERT PRIZE DETAILS NOT FOUND\n";
					 trace("_currentPrize:"+JSON.stringify(_currentPrize));
					 trace("PRIZE NOT FOUND:"+_currentPrize.prize);
				 }
				 
				 AppModel.prizeDatesModel.markPrizeAsVended("", "", "", "02122121", _currentPrize, _tableName);
				// TweenMax.delayedCall(0.1, testPrize);
			 } else {
				trace("------------->prizes used up "+_tableName);
			 }
		}

		private function spin():void
		{
			var _currentPrize:Object;
			var _tableName:String= PrizeDatesModel.PRIZE_TABLE_BIG_BOYS_TOYS;
			_currentPrize = AppModel.prizeDatesModel.getPrizeStatement(_tableName);
			var _spinTime:Number;
			if(_currentPrize){
				AppModel.selectedPrize = _currentPrize.prize;
				AppModel.prizeDatesModel.markPrizeAsVended("","","","", _currentPrize, _tableName);
				_spinTime = AppModel.slotMachine.spin(true);

				switch(Utility.santiseString(_currentPrize.prize))
				{
					case Utility.santiseString("Handyman Voucher"):
					{
						_targetFrame = 2;
						break;
					}

					case Utility.santiseString("Deadly Class Comic"):
					{
						_targetFrame = 3;
						break;
					}

					case Utility.santiseString("$100 Gift Card"):
					{
						_targetFrame = 4;
						break;
					}

					case Utility.santiseString("Handyman Voucher"):
					{
						_targetFrame = 5;
						break;
					}

					case Utility.santiseString("Repco Voucher"):
					{
						_targetFrame = 6;
						break;
					}

					case Utility.santiseString("$50 Movie Voucher"):
					{
						_targetFrame = 7;
						break;
					}

					case Utility.santiseString("Movie Voucher"):
					{
						_targetFrame = 8;
						break;
					}
				}
				if(_targetFrame == 1){
					trace("_currentPrize:"+JSON.stringify(_currentPrize));
					trace("PRIZE NOT FOUND:"+_currentPrize.prize);
				}
			} else {
				trace("------------->prizes used up "+_tableName);
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
	}
}