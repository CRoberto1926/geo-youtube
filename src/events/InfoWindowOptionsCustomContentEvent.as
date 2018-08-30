package events
{
	import components.GeoTagMarker;
	import components.InfoWindowOptionsCustomContent;
	
	import flash.events.Event;
	
	public final class InfoWindowOptionsCustomContentEvent extends Event
	{
		public static const WIKIENTRY_CHANGE:String = "onWikiEntryChange";
		public static const EDIT_GEOTAG:String = "onEditGeoTag";
		public static const DELETE_GEOTAG_FROM_SAVED:String = "onDeleteGeoTagFromSaved";
		public static const DELETE_GEOTAG_FROM_EDIT:String = "onDeleteGeoTagFromEdit";
		public static const GEOTAG_SAVEEDIT:String = "onGeoTagSaveEdit";
		public static const GEOTAG_START:String = "onGeoTagStart";
		public static const GEOTAG_END:String = "onGeoTagEnd";
		public static const GEOTAG_INSERT:String = "onGeoTagInsert";
		
		private var _dataGeoTag:Object;
		private var _geoTagMarker:GeoTagMarker;
		private var _infoWindowOptionsCustomContent:InfoWindowOptionsCustomContent;
		
		public function InfoWindowOptionsCustomContentEvent(type:String, infoWindowOptionsCustomContent:InfoWindowOptionsCustomContent, geoTagMarker:GeoTagMarker, dataGeoTag:Object=null, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_geoTagMarker = geoTagMarker;
			_dataGeoTag = dataGeoTag;
			_infoWindowOptionsCustomContent = infoWindowOptionsCustomContent;
		}
		
		public function get dataGeoTag():Object
		{
			return _dataGeoTag;
		}
		
		public function get infoWindowOptionsCustomContent():InfoWindowOptionsCustomContent
		{
			return _infoWindowOptionsCustomContent;
		}
		
		public function get geoTagMarker():GeoTagMarker
		{
			return _geoTagMarker;
		}
		
		override public function clone():Event
		{
			return new InfoWindowOptionsCustomContentEvent(type, /*_lat, _lng,*/_infoWindowOptionsCustomContent, _geoTagMarker,  _dataGeoTag);
		}
	}
}