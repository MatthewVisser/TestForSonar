package app.events
{
	import flash.events.Event;
	
	public class DataEvent extends Event
	{
		public static const DATA_EVENT:String = "dataEvent";
		public var data:Object;
		public function DataEvent(object:Object, eventType:String="")
		{
			data = object;
			if(eventType == "") eventType = DATA_EVENT;
			super(eventType, true, false);
		}
	}
}