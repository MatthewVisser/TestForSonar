package app.views
{
	import flash.geom.Point;
	
	import feathers.controls.renderers.LayoutGroupListItemRenderer;
	
	import starling.display.Stage;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class TouchController
	{
		private var _target:LayoutGroupListItemRenderer;
		private var _touchID:int = -1;
		private var _stage:Stage;
		private static const HELPER_POINT:Point = new Point();
		public static const STATE_UP:String = "up";
		public static const STATE_DOWN:String = "down";
		private var _updateState:Function;
		
		public function TouchController(stage:Stage, target:LayoutGroupListItemRenderer, updateState:Function=null)
		{
			_target = target;
			_stage = stage;
			_updateState = updateState;
			_target.addEventListener(TouchEvent.TOUCH, touchHandler);
		}
		
		public function dispose():void
		{
			_stage = null;
			if(_target) _target.removeEventListener(TouchEvent.TOUCH, touchHandler);
			_target = null;
		}
		
		private function touchHandler(event:TouchEvent):void
		{
			if( _touchID >= 0 ){
	
				var touch:Touch = event.getTouch( _target, null, _touchID );
				if( !touch ) return;

				if( touch.phase == TouchPhase.ENDED )
				{
					touch.getLocation( _stage, HELPER_POINT );
					var isInBounds:Boolean = _target.contains( _stage.hitTest( HELPER_POINT ) );
					if( isInBounds) _target.isSelected = true;
					if(_updateState) _updateState.call(null, STATE_UP);
	
					_touchID = -1;
				}
				return;
			} else {
				touch = event.getTouch( _target, TouchPhase.BEGAN );
				if( !touch )return;
				if(_updateState) _updateState.call(null, STATE_DOWN);
				_touchID = touch.id;
			}
		}
	}
}