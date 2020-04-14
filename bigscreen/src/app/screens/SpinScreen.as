package app.screens
{
import app.models.AppModel;
import app.models.PrizeDatesModel;
import app.services.NavController;
import app.services.PrizeLogger;
import app.services.Utility;

import com.greensock.TweenMax;

import feathers.controls.Screen;
import feathers.events.FeathersEventType;

import treefortress.sound.SoundAS;

public class SpinScreen extends Screen
	{
		private var _targetFrame:int = 1;
		public function SpinScreen()
		{
			super();
		}

		override protected function initialize():void
		{
			super.initialize();
			SoundAS.playFx('slotLever');

			this.owner.addEventListener(FeathersEventType.TRANSITION_COMPLETE, transitionCompleteHandler);
		}

		private function transitionCompleteHandler():void
		{
			this.owner.removeEventListener(FeathersEventType.TRANSITION_COMPLETE, transitionCompleteHandler);
			AppModel.slotMachine.show();
			spin();
			SoundAS.playFx('music');
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
						_targetFrame = 5;
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

					case Utility.santiseString("A Year’s Free Neon"):
					{
						_targetFrame = 2;
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
					trace("no target frame found");
				}
				PrizeLogger.log(_currentPrize.prize);
				TweenMax.delayedCall(_spinTime, win);
			} else {
				_spinTime = AppModel.slotMachine.spin(false);
				PrizeLogger.log("NoPrize");
				TweenMax.delayedCall(_spinTime, lose);
			}
			TweenMax.delayedCall(_spinTime + 10, nextPage);
		}

		private function win():void
		{
			AppModel.slotMachine.showPrize(_targetFrame);
			SoundAS.playFx('gameWon');

		}
		private function lose():void
		{
			AppModel.slotMachine.showLose();
			SoundAS.playFx('answerWrong');
		}
		
		private function nextPage():void
		{
			AppModel.slotMachine.hide();
			NavController.showScreen(ScreenNames.START);
		}
		
		override public function dispose():void
		{
			AppModel.slotMachine.hide();
			TweenMax.killTweensOf(this);
			super.dispose();
		}
	}
}