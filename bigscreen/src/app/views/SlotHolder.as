package app.views
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Power1;
	
	import flash.display.Sprite;
	
	import assets.AssetSlotHolder;

	public class SlotHolder
	{
		private var _asset:AssetSlotHolder;
		private var _container:Sprite = new Sprite;
		//private var _tileHeight:Number = 142;
		private var _tileWidth:Number = 540;
		public var spinLocation:Number = 0;
		public var prevSpinLocation:Number = 0;
		public var slots:Array = [];
		public function SlotHolder(target:AssetSlotHolder)
		{
			_asset = target;
			_asset.addChild(_container);
            _asset.addChild(_asset.slotOverlay);
			//_asset.slotOverlay.y = 72;
			_container.mask = _asset.masker;
			loadTiles();
		}
		
		public function loadTiles():void {
			var _tiles:Array = ["tile1.png","tile2.png","tile3.png","tile4.png","tile5.png","tile6.png","tile7.png","tile8.png"];
			for (var i:int = 0; i < _tiles.length; i++) {
				var _tileName:String = _tiles[i];
				var _slotView:SlotView = new SlotView(_tileName, i);
				_container.addChild(_slotView);
				slots.push(_slotView);
			}
		}
		
		public function spin(duration:Number=5,targetSpins:Number=20):void
		{
			spinLocation = 0;
			prevSpinLocation = 0;
			TweenMax.to(this, duration, {spinLocation:targetSpins*_tileWidth, onUpdate:updateSlots, ease:Power1.easeOut,onComplete:clearBlur});
		}
		
		private function updateSlots():void
		{
			var _spinSpeed:Number = Math.abs((spinLocation - prevSpinLocation)*0.2);
			prevSpinLocation = spinLocation;
			for (var i:int = 0; i < slots.length; i++) {
				var _slotView:SlotView = slots[i];
				_slotView.x = (spinLocation - i * _tileWidth)% (_tileWidth * slots.length) - (_tileWidth * 1.5);
				_slotView.updateBlur(_spinSpeed);
			}
		}

		public function clearBlur():void
		{
			for (var i:int = 0; i < slots.length; i++) {
				var _slotView:SlotView = slots[i];
				_slotView.updateBlur(0);
			}
		}
	}
}