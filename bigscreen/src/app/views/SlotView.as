package app.views
{
	import com.greensock.loading.ImageLoader;
	
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	
	public class SlotView extends Sprite
	{
		private var _slotIndex:int;
		private var _previousY:Number = 0;

		private var _blur:BlurFilter;
		private var _lineContainer:Sprite = new Sprite();
		private var _imageContainer:Sprite = new Sprite();
		public function SlotView(imageName:String,slotIndex:int)
		{
			super();
			_slotIndex = slotIndex;
			var _loader:ImageLoader = new ImageLoader("slots/"+imageName, {name:imageName, container:_imageContainer});
			_loader.load();
			addChild(_imageContainer);
			_blur = new BlurFilter();
			_blur.blurX = 0;
			_blur.blurY = 0;
			this.filters = [_blur];
			addChild(_lineContainer);
			_lineContainer.graphics.beginFill(0x000000);
			_lineContainer.graphics.drawRect(0,0,4,405);
			_lineContainer.graphics.drawRect(536,0,4,405);
			_lineContainer.graphics.endFill();
		}
		
		public function updateBlur(speed:Number):void
		{
			_blur.blurX = speed;
			this.filters = [_blur];
		}
	}
}