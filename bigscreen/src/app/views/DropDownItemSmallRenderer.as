package app.views
{
	
	import flash.text.TextFormatAlign;
	
	import app.factories.Factory;
	import app.factories.Fonts;
	
	import feathers.controls.Label;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.controls.renderers.LayoutGroupListItemRenderer;
	import feathers.display.Scale9Image;
	
	import starling.core.Starling;
	import starling.display.Quad;
	
	public class DropDownItemSmallRenderer extends LayoutGroupListItemRenderer implements IListItemRenderer
	{
		private var _base:Quad;
		private var _label:Label;
		public var labelField:*;
		private var _deselectOnUp:Boolean = false;
		
		public function DropDownItemSmallRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			this.width = 700;
			this.height = 100;
			_base = new Quad(700, 100);
			addChild(_base);
			
			var _bottomLine:Quad = new Quad(700, 1, 0x8f8f8f);
			addChild(_bottomLine);
			_bottomLine.y = 99;
			
			_label = Factory.label(Fonts.FONT_LIGHT, 38, 0x000000, TextFormatAlign.LEFT, false, 0);
			addChild(_label);

			
			_label.x = 30;
			_label.y = 26;

			this.isQuickHitAreaEnabled = true;
			var _touch:TouchController = new TouchController(Starling.current.stage, this, updateStateHandler);
		}	
		
		private function updateStateHandler(state:String):void
		{
			if(state == "down"){
				if(isSelected){
					_deselectOnUp = true;
				} else {
					_deselectOnUp = false;
				}
			} 
			
			if(state == "up" && _deselectOnUp) isSelected = false;
		}
		
		public function labelFunction():String
		{
			return _data.text;
		}
		
		override protected function commitData():void
		{
			if(!_data) return;
			_label.text = _data.text;
		}
	}
}