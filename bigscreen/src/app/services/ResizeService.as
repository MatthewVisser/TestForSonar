package app.services
{
	import starling.display.DisplayObject;
	import starling.display.Stage;
	import starling.events.Event;

	public class ResizeService
	{
		private var _stage:Stage
		private var _targetWidth:Number;
		private var _targetHeight:Number;
		private var _targets:Array;
		public var scaleFactor:Number;
		public static var MODE_CENTERED:String = "modeCentered";
		public static var MODE_LEFT:String = "modeLeft";
		public static var MODE_RIGHT:String = "modeRight";
		public static var MODE_TOP:String = "modeTop";
		private var _mode:String;

		private var _adjScale:Number = 0;
		public var adjY:Number = 0;
		public var adjX:Number = 0;
		
		public function ResizeService(stage:Stage, targetWidth:Number, targetHeight:Number, targets:Array)
		{
			_stage = stage;
			_targetWidth = targetWidth;
			_targetHeight = targetHeight;
			_targets = targets;
			_stage.addEventListener(Event.RESIZE, update);
			_mode = MODE_CENTERED
		}
		
		
		
		public function get adjScale():Number
		{
			return _adjScale;
		}

		public function set adjScale(value:Number):void
		{
			if(value < 0) value = 0;
			_adjScale = value;
		}

		public function resetTo100Percent():void
		{
			for each (var _target:DisplayObject in _targets) 
			{
				_target.x = 0;
				_target.y = 0;
				_target.scaleX = _target.scaleY = 1;
			}
		}
		
		public function setMode(mode:String):void
		{
			_mode = mode; 
			update();
		}
		
		public function setTargetSize(targetWidth:Number, targetHeight:Number, mode:String="modeCentered"):void
		{
			_targetWidth = targetWidth;
			_targetHeight = targetHeight;
			_mode = mode;
			update();
		}
		
		public function update(event:Event=null):void
		{
			var _targetRatio:Number;
			var _screenRatio:Number;
			var _calcWidth:int;
			var _calcHeight:int;
			var _calcOffsetX:int;
			var _calcOffsetY:int;
			var _target:Object;
			if(_mode == MODE_CENTERED){
				_targetRatio = _targetWidth / (_targetHeight + adjScale);
				_screenRatio = _stage.stageWidth / _stage.stageHeight;
				_calcOffsetX = 0;
				_calcOffsetY = 0;	
				if(_screenRatio < _targetRatio){
					_calcWidth = _stage.stageWidth;
					_calcHeight = _calcWidth / _targetRatio;
					_calcOffsetY = (_stage.stageHeight - _calcHeight) * 0.5;
				} else {
					_calcHeight = _stage.stageHeight;
					_calcWidth = _calcHeight * _targetRatio;
					_calcOffsetX = (_stage.stageWidth - _calcWidth) * 0.5;
				}
				scaleFactor = _calcWidth/ _targetWidth;
				for each (_target in _targets) 
				{
					_target.x = _calcOffsetX  + (adjX * scaleFactor);;
					_target.y = _calcOffsetY + (adjScale * 0.5 * scaleFactor) + (adjY * scaleFactor);
					_target.scaleX = _target.scaleY = scaleFactor;
				}
			}
			
			if(_mode == MODE_TOP){
				_targetRatio = _targetWidth / _targetHeight;
				_screenRatio = _stage.stageWidth / _stage.stageHeight;
				_calcOffsetX = 0;
				_calcOffsetY = 0;	
				if(_screenRatio < _targetRatio){
					_calcWidth = _stage.stageWidth;
					_calcHeight = _calcWidth / _targetRatio;
				} else {
					_calcHeight = _stage.stageHeight;
					_calcWidth = _calcHeight * _targetRatio;
					_calcOffsetX = (_stage.stageWidth - _calcWidth) * 0.5;
				}
				scaleFactor = _calcWidth/ _targetWidth;
				for each (_target in _targets) 
				{
					_target.x = _calcOffsetX;
					_target.y = _calcOffsetY;
					_target.scaleX = _target.scaleY = scaleFactor;
				}
			}
			
			if(_mode == MODE_LEFT){
				_targetRatio = _targetWidth / _targetHeight;
				_screenRatio = (_stage.stageWidth * 0.5) / _stage.stageHeight;
				_calcOffsetX = 0;
				_calcOffsetY = 0;	
				if(_screenRatio < _targetRatio){
					_calcWidth = _stage.stageWidth * 0.5;
					_calcHeight = _calcWidth / _targetRatio;
					_calcOffsetY = (_stage.stageHeight - _calcHeight) * 0.5;
				} else {
					_calcHeight = _stage.stageHeight;
					_calcWidth = _calcHeight * _targetRatio;
					scaleFactor = _calcWidth/ _targetWidth;
					_calcOffsetX =  _stage.stageWidth * 0.5 - _targetWidth * scaleFactor;//((_stage.stageWidth * 0.5)- _calcWidth) * 0.5;
				}
				scaleFactor = _calcWidth/ _targetWidth;
				for each (_target in _targets) 
				{
					_target.x = _calcOffsetX;
					_target.y = _calcOffsetY;
					_target.scaleX = _target.scaleY = scaleFactor;
				}
			}
			
			if(_mode == MODE_RIGHT){
				_targetRatio = _targetWidth / _targetHeight;
				_screenRatio = (_stage.stageWidth * 0.5) / _stage.stageHeight;
				_calcOffsetX = 0;
				_calcOffsetY = 0;	
				if(_screenRatio < _targetRatio){
					_calcWidth = _stage.stageWidth * 0.5;
					_calcHeight = _calcWidth / _targetRatio;
					_calcOffsetY = (_stage.stageHeight - _calcHeight) * 0.5;
					_calcOffsetX = _stage.stageWidth * 0.5;
				} else {
					_calcHeight = _stage.stageHeight;
					_calcWidth = _calcHeight * _targetRatio;
					_calcOffsetX = _stage.stageWidth * 0.5;// ((_stage.stageWidth * 0.5)- _calcWidth) * 0.5 + _stage.stageWidth * 0.5;
				}
				scaleFactor = _calcWidth/ _targetWidth;
				for each (_target in _targets) 
				{
					_target.x = _calcOffsetX;
					_target.y = _calcOffsetY;
					_target.scaleX = _target.scaleY = scaleFactor;
				}
			}
		}
	}
}