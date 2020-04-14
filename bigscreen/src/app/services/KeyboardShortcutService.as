package app.services
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;

	public class KeyboardShortcutService
	{
		private var _stage:Stage;
		private var _keyboardDictionary:Dictionary = new Dictionary();
		
		public function KeyboardShortcutService(stage:Stage)
		{
			_stage = stage;
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		
		public function addKeyboardShortcut(keyCode:uint, callbackFunction:Function, targetArgument:Object=null):void
		{
			_keyboardDictionary[keyCode] = {callback:callbackFunction, argument:targetArgument};
		}
		
		protected function keyDownHandler(event:KeyboardEvent):void
		{
			triggerKey(event.keyCode);
		}
		
		public function triggerKey(keyCode:int):void
		{
			var _result:Object = _keyboardDictionary[keyCode];
			if(_result){
				var _targetFunction:Function = _result.callback;
				if(_result.argument){
					_targetFunction.call(null, _result.argument);
				} else {
					_targetFunction.call(null);
				}	
			}
			_stage.focus = _stage;
		}
		
	}
}