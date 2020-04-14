package app.services.serverapi
{
	import flash.events.Event;
	
	//import app.services.Logger;
	
	public class APIEvent extends Event
	{
		public static const EVENT_AUTH_SUCCESS:String = "eventAuthSuccess";
		public static const EVENT_AUTH_FAIL:String = "eventAuthFail";
		public static const EVENT_GET_PHOTOS_SUCCESS:String = "eventGetPhotosSuccess";
		public static const EVENT_GET_PHOTOS_FAIL:String = "eventGetPhotosFail";
		public static const EVENT_POST_PHOTO_SUCCESS:String = "eventPostPhotoSuccess";
		public static const EVENT_POST_PHOTOS_FAIL:String = "eventPostPhotosFail";
		public static const EVENT_AUTH_INVALID:String = "eventAuthInvalid";

		public var data:Object;
		public function APIEvent(type:String, eventData:Object=null)
		{
			data = eventData;
			//Logger.log(type);
			super(type, bubbles);
		}
	}
}