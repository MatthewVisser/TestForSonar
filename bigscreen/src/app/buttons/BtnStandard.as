package app.buttons
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;

	public class BtnStandard
	{
		private var _target:MovieClip;
		private var _callback:Function;
		private var _arguments:Array = [];
		private var _sound:String;
		public function BtnStandard(target:MovieClip, callback:Function=null, arguments:Array=null, sound:String="button_press")
		{
			_target = target;
			_callback = callback;
			_sound = sound;
			_target.mouseChildren = false;
			_target.buttonMode = true;
			_target.addEventListener(MouseEvent.CLICK, clickHandler);
			_arguments = arguments;
		}
		
		protected function clickHandler(event:MouseEvent):void
		{
			if(_callback){
				_callback.apply(this, _arguments);
			}
		}
	}
}