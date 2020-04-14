package app.views
{
	import com.greensock.TweenMax;
	import com.greensock.easing.BounceOut;
	import com.greensock.easing.Power4;
	
	import flash.display.Sprite;
	
	import app.models.AppModel;
	
	import assets.AssetLoseMessage;
	import assets.AssetLoseMessageContainer;
	import assets.AssetSlotsMachine;
	import assets.AssetWinMessage;
	import assets.AssetWinMessageContainer;
	
	public class SlotMachine extends Sprite
	{
		private var _asset:AssetSlotsMachine;
		private var _slotHolder1:SlotHolder;
		private var _slotHolder2:SlotHolder;
		private var _slotHolder3:SlotHolder;
		private var _winMessage:AssetWinMessageContainer;
		private var _loseMessage:AssetLoseMessageContainer;
		private var _winOutcomes:Array = [
			[40,40,40],
			[41,41,41],
			[42,42,42],
			[43,43,43],
			[44,44,44],
			[45,45,45],
			[46,46,46],
			[47,47,47],
			[48,48,48],
			[49,49,49]
		];
		
		private var _loseOutcomes:Array = [
			[40,41,42],
			[46,42,41],
			[48,46,42],
			[40,40,42],
			[41,41,42],
			[42,42,40],
			[48,49,49],
			[43,43,48],
			[45,45,49],
			[46,46,47],
			[48,48,49],
			[49,49,45]
		];
		public function SlotMachine()
		{
			super();
			_asset = new AssetSlotsMachine();
			addChild(_asset);
			_winMessage = _asset.winMessageContainer;
			_loseMessage = _asset.loseMessageContainer;
			_slotHolder1 = new SlotHolder(_asset.slot1);
			_slotHolder2 = new SlotHolder(_asset.slot2);
			_slotHolder3 = new SlotHolder(_asset.slot3);
		}
		
		public function hide():void
		{
			this.visible = false;
		}
		
		public function show():void
		{
			this.visible = true;
			_winMessage.visible = false;
			_loseMessage.visible = false;
		}
		
		public function spin(win:Boolean=false): Number
		{
			var _spins:Array = [];
			if(win){
				_spins = _winOutcomes[Math.floor(Math.random() * _winOutcomes.length)];	
			} else {
				_spins = _loseOutcomes[Math.floor(Math.random() * _loseOutcomes.length)];	
			}
			_slotHolder1.spin(2,_spins[0]);
			_slotHolder2.spin(4,_spins[1]);
			_slotHolder3.spin(6,_spins[2]);
			return 6;//Spin time
		}
		
		public function showPrize(prizeNumber:int):void
		{
			_winMessage.visible = true;
			_winMessage.gotoAndPlay(2);
			_winMessage.winMessage.gotoAndStop(prizeNumber);
		}
		
		public function showLose():void
		{
			_loseMessage.visible = true;
			_loseMessage.gotoAndPlay(2);
		}
		
	}
}