package events
{
	import com.google.maps.overlays.Polyline;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public final class DirectionsAPIHandlerEvent extends Event
	{
		public static const DIRECTIONS_OBTAINED:String = "onDirectionsObtained";
		
		private var _path:Polyline;
		
		public function DirectionsAPIHandlerEvent(type:String, path:Polyline, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			_path = path;
			
			super(type, bubbles, cancelable);
		}
		
		public function get path():Polyline
		{
			return _path;
		}
		
		override public function clone():Event
		{
			return new DirectionsAPIHandlerEvent(type, _path);
		}
	}
}