package events
{
	import com.google.maps.interfaces.IMapType;
	
	import flash.events.Event;
	
	public final class GeoTagMapEvent extends Event
	{
		public static const GEOTAGMAP_READY:String = "onGeoTagMapReady";
		public static const ON_MAP_TYPE_CHANGE:String = "onMapTypeChange";
		
		private var _iMapType:IMapType;
		
		public function GeoTagMapEvent(type:String, iMapType:IMapType=null, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			_iMapType = iMapType;
			super(type, bubbles, cancelable);
		}
		
		public function get iMapType():IMapType
		{
			return _iMapType;
		}
		
		override public function clone():Event
		{
			return new GeoTagMapEvent(type, _iMapType);
		}
	}
}