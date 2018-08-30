package events
{
	import flash.events.Event;
	
	public final class AS3PlayerEvent extends Event
	{
		public static const PLAYER_READY:String = "onPlayerReady";
		public static const CUEPOINT_START_REACHED:String = "onCuePointStartReached";
		public static const CUEPOINT_END_REACHED:String = "onCuePointEndReached";
		
		private var _videoId:String;
		private var _time:Number;
		private var _id:int;
		
		public function AS3PlayerEvent(type:String, id:int=-1, videoId:String=null, time:Number=-1, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_videoId = videoId;
			_time = time;
			_id = id;
		}
		
		public function get id():int
		{
			return _id;
		}
		
		override public function clone():Event
		{
			return new AS3PlayerEvent(type);
		}
	}
}