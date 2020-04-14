package app.services
{
	import com.greensock.TimelineMax;
	import com.greensock.TweenMax;
	import com.greensock.easing.Power4;
	
	import app.models.AppModel;
	import app.screens.ScreenNames;
	
	import feathers.controls.ScreenNavigator;
	import feathers.controls.ScreenNavigatorItem;
	import feathers.motion.Fade;
	import feathers.motion.Slide;
	
	import starling.animation.Transitions;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	
	public class NavController
	{
		protected static var _screenNavigator:ScreenNavigator;
		protected static var _history:Vector.<String>;
		private static var _parent:Sprite;
		private static var _previousScreenIDs:Array = [];
		
		public function NavController()
		{
			
		}
		
		public static function get activeScreenID():String
		{
			if(_screenNavigator){
				return _screenNavigator.activeScreenID;
			}
			return "";
		}

		public static function setup(parentSprite:Sprite):void
		{
			_parent = parentSprite;
			_screenNavigator =  new ScreenNavigator();
			_parent.addChild(_screenNavigator);
			_history = new Vector.<String>;
			
			/*_screenNavigator.transition = function(oldScreen:DisplayObject, newScreen:DisplayObject, completeCallback:Function):void
			{
				if(!newScreen)
				{
					completeCallback();
					return;
				}
				newScreen.x = AppModel.stageWidth;
				var _tweenTL:TimelineMax = new TimelineMax();
				//if(oldScreen){
				//	_tweenTL.add(TweenMax.to(oldScreen, 0.3, {alpha:0}));
				//}
				_tweenTL.add(TweenMax.to(newScreen, 0.6, {x:0,onComplete:completeCallback,ease:Power4.easeOut}));
				_tweenTL.play();
			}*/
			
			_screenNavigator.transition = Fade.createFadeInTransition();

		}
		
		public static function addScreen(screenName:String,screenNavigatorItem:ScreenNavigatorItem):void
		{
			_screenNavigator.addScreen(screenName, screenNavigatorItem);
		}
		
		public static function showScreen(id:String, transition:Function = null, storeInHistory:Boolean=true):DisplayObject
		{
			trace("showScreen:"+id);
			if(storeInHistory){
				if(_history.length == 0){
					_history.push(id);
				} else if(_history[_history.length-1] != id){
					_history.push(id);
				}
			}
			_previousScreenIDs.push(id);
			return _screenNavigator.showScreen(id, transition);
		}
		
		public static function goBack(num:int=1):void
		{
			trace("_history:"+_history);
			for (var i:int = 0; i < num; i++) 
			{
				if (_history.length > 1) {
					_history.pop();
				}
			}
			var _index:Number = _history.length - 1;
			if(_history.length == 0) return;
			showScreen(_history[_index])
		}
		
		public static function clearHistory():void
		{
			_history = new Vector.<String>;
		}
		
		public static function previousScreenName():String
		{
			if(_previousScreenIDs.length > 1){
				return _previousScreenIDs[_previousScreenIDs.length-2];
			}
			return "";
		}
	}
}