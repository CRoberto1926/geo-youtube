package components
{
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.Map;
	import com.google.maps.MapEvent;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.MapOptions;
	import com.google.maps.MapType;
	import com.google.maps.controls.ControlPosition;
	import com.google.maps.controls.MapTypeControl;
	import com.google.maps.controls.MapTypeControlOptions;
	import com.google.maps.controls.NavigationControl;
	import com.google.maps.controls.NavigationControlOptions;
	import com.google.maps.controls.ScaleControl;
	import com.google.maps.controls.ScaleControlOptions;
	import com.google.maps.interfaces.IMapType;
	import com.google.maps.overlays.MarkerOptions;
	import com.google.maps.overlays.Polyline;
	import com.google.maps.overlays.PolylineOptions;
	import com.google.maps.styles.StrokeStyle;
	
	import events.DirectionsAPIHandlerEvent;
	import events.GeoTagMapEvent;
	import events.InfoWindowOptionsCustomContentEvent;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import handlers.DirectionsAPIHandler;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import spark.components.Button;
	import spark.components.Group;
	
	public final class GeoTagMap extends Group
	{
		private var _gMap:Map;
		private var _gMapReady:Boolean;
		private var _as3Player:AS3Player;
		private var _geoTagMarkerArray:Array;
		private var _editingMarker:GeoTagMarker;
		private var _focusMarker:Array;
		private var _getPath:Button;
		private var _seeAll:Button;
		private var _path:Array;
		
		private const _GMAPOPTIONS_ZOOM:int = 14;
		private const GMAP_INITIAL_LAT:int = 43.76667;
		private const GMAP_INITIAL_LNG:int = 11.25;
		
		public function GeoTagMap(as3Player:AS3Player)
		{
			super();
			
			_gMapReady = false;
			_as3Player = as3Player;
			_geoTagMarkerArray = new Array();
			_focusMarker = new Array();
			_path = new Array();
			
			_gMap = new Map();
			_gMap.key = "ABQIAAAAZOMJ01MRIB1eqNG6Sc2d5hT2yXp_ZAY8_ufC3CFXhHIE1NvwkxQM_qn5J3ao3C5gZzUfAuNenVq6yQ";
			_gMap.url = "http://code.google.com/apis/maps/";
			_gMap.sensor = "false";
			
			_gMap.addEventListener(MapEvent.MAP_PREINITIALIZE, _gMapPreInitializeHandler);
			_gMap.addEventListener(MapEvent.MAP_READY, _gMapReadyHandler);
			
			//addEventListener(InfoWindowOptionsCustomContentEvent.DELETE_GEOTAG_FROM_SAVED, deleteGeoTagFromSavedHandler);
			addEventListener(InfoWindowOptionsCustomContentEvent.EDIT_GEOTAG, editGeoTagHandler);
			//addEventListener(DirectionsAPIHandlerEvent.DIRECTIONS_OBTAINED, directionsObtainedHandler);
			
			addElement(_gMap);			
		}
		
		public function addFocusMarker(id:int):void
		{
			var i:int = 0;
			
			for(i=0;i<_focusMarker.length;i++)
			{
				if(_focusMarker[i].dataGeoTag.Id == id)
					return;
			}
			
			for(i=0;i<_geoTagMarkerArray.length;i++)
			{
				if(_geoTagMarkerArray[i].dataGeoTag.Id == id)
				{
					_focusMarker.push(_geoTagMarkerArray[i]);
					_focusMarker[_focusMarker.length-1].openInfoWindow();
					_gMap.panTo(new LatLng(_focusMarker[_focusMarker.length-1].dataGeoTag.lat, _focusMarker[_focusMarker.length-1].dataGeoTag.lng));
					break;
				}
			}
		}
		
		public function removeFocusMarker(id:int):void
		{
			var i:int = 0;
			for(i=0;i<_focusMarker.length;i++)
			{
				if(_focusMarker[i].dataGeoTag.Id == id)
				{
					if(i == _focusMarker.length-1)
					{
						_focusMarker.pop().closeInfoWindow();
						if(_focusMarker.length > 0)
						{
							_focusMarker[_focusMarker.length-1].openInfoWindow();
							_gMap.panTo(new LatLng(_focusMarker[_focusMarker.length-1].dataGeoTag.lat, _focusMarker[_focusMarker.length-1].dataGeoTag.lng));
						}
					}
					else
					{
						_focusMarker.splice(i, 1);
					}
					break;
				}
			}
		}
		
		private function editGeoTagHandler(iwocce:InfoWindowOptionsCustomContentEvent):void
		{
			iwocce.geoTagMarker.closeInfoWindow();
		}
		
//		private function deleteGeoTagFromSavedHandler(iwocce:InfoWindowOptionsCustomContentEvent):void
//		{
//			markerRemoveHandler(iwocce.geoTagMarker);
//		}
		
		public function markerRemoveHandler(geoTagMarker:GeoTagMarker):void
		{
			geoTagMarker.closeInfoWindow();
			_gMap.removeOverlay(geoTagMarker);
			var i:int = 0;
			for(i = 0; i<_geoTagMarkerArray.length;i++)
			{
				if(_geoTagMarkerArray[i] == geoTagMarker)
				{
					_geoTagMarkerArray.splice(i, 1);
					_geoTagMarkerArray.sort(sortOnStartTime);
					break;
				}
			}
			if(_path.length > 0)
				drawPath();
		}
		
		public function removeMarkerById(Id:int):void
		{
			var i:int = 0;
			for(i = 0; i<_geoTagMarkerArray.length;i++)
			{
				if(_geoTagMarkerArray[i].dataGeoTag.Id == Id)
				{
					_geoTagMarkerArray[i].closeInfoWindow();
					_gMap.removeOverlay(_geoTagMarkerArray[i]);
					_geoTagMarkerArray.splice(i, 1);
					_geoTagMarkerArray.sort(sortOnStartTime);
					break;
				}
			}
			if(_path.length > 0)
				drawPath();
		}
		
		private function _getPathInitializer():void
		{
			_getPath = new Button();
			_getPath.x = this.width - 155; //GO CONST
			_getPath.y = 5; //GO CONST
			_getPath.width = 90;
			_getPath.height = 22;
			_getPath.label = "Get path";
			
			_getPath.addEventListener(MouseEvent.CLICK, getPathClickHandler);
			
			addElement(_getPath);
		}
		
		private function _seeAllInitializer():void
		{
			_seeAll = new Button();
			_seeAll.x = _getPath.x;
			_seeAll.y = _getPath.y + 22;
			_seeAll.width = 90;
			_seeAll.height = 22;
			_seeAll.label = "See all";
			
			_seeAll.addEventListener(MouseEvent.CLICK, seeAllClickHandler);
			
			addElement(_seeAll);
		}
		
		private function seeAllClickHandler(me:MouseEvent):void
		{
			var i:int = 0;
			var maxLat:Number = -91;
			var minLat:Number = 91;
			var maxLng:Number = -181;
			var minLng:Number = 181;
			var tempMarker:GeoTagMarker;
			if(_geoTagMarkerArray.length > 1)
			{
				for(i=0;i<_geoTagMarkerArray.length;i++)
				{
					tempMarker = _geoTagMarkerArray[i];
					
					maxLat = (maxLat < tempMarker.getLatLng().lat()) ? tempMarker.getLatLng().lat() : maxLat;
					minLat = (tempMarker.getLatLng().lat() < minLat) ? tempMarker.getLatLng().lat() : minLat;
					maxLng = (maxLng < tempMarker.getLatLng().lng()) ? tempMarker.getLatLng().lng() : maxLng;
					minLng = (tempMarker.getLatLng().lng() < minLng) ? tempMarker.getLatLng().lng() : minLng;
				}
			}
			else if(_geoTagMarkerArray.length == 1)
			{
				tempMarker = _geoTagMarkerArray[0];
				maxLat = tempMarker.getLatLng().lat();
				minLat = tempMarker.getLatLng().lat();
				maxLng = tempMarker.getLatLng().lng();
				minLng = tempMarker.getLatLng().lng();
			}
			else if(_geoTagMarkerArray.length == 0)
				return;
			
			var sw:LatLng = new LatLng(minLat, minLng);
			var ne:LatLng = new LatLng(maxLat, maxLng);
			var latLngBounds:LatLngBounds = new LatLngBounds(sw, ne);
			
			if(_gMapReady)
			{
				_gMap.panTo(latLngBounds.getCenter());
				var zoomLevel:Number = _gMap.getBoundsZoomLevel(latLngBounds);
				_gMap.setZoom(zoomLevel, true);				
			}
		}
		
		private function getPathClickHandler(me:MouseEvent):void
		{
			if(_geoTagMarkerArray.length > 1 && _path.length == 0)
			{
				drawPath();
				_getPath.label = "Clean path";
			}
			else if(_path.length > 0)
			{
				var i:int = 0;
				for(i=0;i<_path.length;i++)
				{
					_gMap.removeOverlay(_path[i]);
				}
				_path = new Array();
				_getPath.label = "Get path";
			}
		}
		
		private function drawPath():void
		{
			var latlngs:Array;
			var i:int = 0;
			for(i=0;i<_path.length;i++)
			{
				_gMap.removeOverlay(_path[i]);
			}
			_path = new Array();
			var directions:DirectionsAPIHandler;
			for(i=0;i<_geoTagMarkerArray.length-1;i++)
			{
				latlngs = new Array();
				latlngs[0] = new LatLng(_geoTagMarkerArray[i].dataGeoTag.lat, _geoTagMarkerArray[i].dataGeoTag.lng);
				latlngs[1] = new LatLng(_geoTagMarkerArray[i+1].dataGeoTag.lat, _geoTagMarkerArray[i+1].dataGeoTag.lng);
				
				directions = new DirectionsAPIHandler(latlngs[0], latlngs[1]);
				directions.addEventListener(DirectionsAPIHandlerEvent.DIRECTIONS_OBTAINED, directionsObtainedHandler);
				//_path.push(createPolyline(latlngs[0], latlngs[1]));
			}
		}
		
		private function directionsObtainedHandler(dahe:DirectionsAPIHandlerEvent):void
		{
			var latlngs:Array;
			_path.push(dahe.path);
			_gMap.addOverlay(dahe.path);
//			for each(var step:Object in dahe.steps)
//			{
//				latlngs = new Array();
//				latlngs[0] = new LatLng(step.start_location.lat, step.start_location.lng);
//				latlngs[1] = new LatLng(step.end_location.lat, step.end_location.lng);
//				
//				_path.push(createPolyline(latlngs[0], latlngs[1])); //MODIFICARE, in steps.polyline.points ci sono tutti i punti relativi al percorso di già
//			}
		}
		
		private function createPolyline(startLocation:LatLng, endLocation:LatLng):Polyline {
			var opts:PolylineOptions = new PolylineOptions();
			opts.strokeStyle = new StrokeStyle({
				color: 0xFF0000,
				thickness: 4,
				alpha: 0.7});
			opts.geodesic = true;
			
			var latlngs:Array = new Array(startLocation, endLocation);
			var polyline:Polyline = new Polyline(latlngs, opts);
			
			_gMap.addOverlay(polyline);
			return polyline;
		}
		
		override public function set width(value:Number):void
		{
			if(_gMapReady)
			{
				super.width = value;
				_gMap.width = value;
			}
			else
				Alert.show("Map is not ready!");
			
		}
		
		override public function set height(value:Number):void
		{
			if(_gMapReady)
			{
				super.height = value;
				_gMap.height = value;
			}
			else
				Alert.show("Map is not ready!");
		}
		
		public function set editingMarker(value:GeoTagMarker):void
		{
			_editingMarker = value;
		}
		
		public function addMarker(dataGeoTag:Object):void
		{
			if(_gMapReady)
			{
				var latLng:LatLng = new LatLng(dataGeoTag.lat, dataGeoTag.lng);
				
				var markOpt:MarkerOptions  = new MarkerOptions();
				markOpt.icon = new MarkerIcon(dataGeoTag.fcl);
				markOpt.iconAlignment = MarkerOptions.ALIGN_HORIZONTAL_CENTER;
				markOpt.iconOffset = new Point(0, -36);
				
				var geoTagMarker:GeoTagMarker = new GeoTagMarker(latLng, dataGeoTag, false, false, _as3Player, null, markOpt);
				_gMap.addOverlay(geoTagMarker);
				_gMap.panTo(latLng);
				_geoTagMarkerArray.push(geoTagMarker);
				_geoTagMarkerArray.sort(sortOnStartTime);
				
				if(_geoTagMarkerArray.length > 1 && _path.length > 0)
					drawPath();
			}
			else
				Alert.show("Map is not ready!");
		}
		
		private function sortOnStartTime(a:GeoTagMarker, b:GeoTagMarker):Number {
			var aStartTime:Number = a.dataGeoTag.StartTime;
			var bStartTime:Number = b.dataGeoTag.StartTime;
			
			if(aStartTime > bStartTime) {
				return 1;
			} else if(aStartTime < bStartTime) {
				return -1;
			} else  {
				return 0;
			}
		}
		
		public function removeEditingMarker():Object
		{
			if(_gMapReady)
			{
				var i:int = 0;
				for(i = 0; i<_geoTagMarkerArray.length;i++)
				{
					if(_geoTagMarkerArray[i] == _editingMarker)
					{
						_gMap.removeOverlay(_geoTagMarkerArray[i]);
						_geoTagMarkerArray.splice(i, 1);
						_geoTagMarkerArray.sort(sortOnStartTime);
						break;
					}
				}
				return _editingMarker.dataGeoTag;
			}
			else
				Alert.show("Map is not ready!");
			return null;
		}
		
		public function clean():void
		{
			if(_gMapReady)
			{
				_gMap.clearOverlays();
				_gMap.closeInfoWindow();
			}
			_geoTagMarkerArray = new Array();
			_focusMarker = new Array();
			_path = new Array();
			_editingMarker = null;
			_getPath.label = "Get path";
		}
		
		public function tagNumber():int
		{
			return _geoTagMarkerArray.length;
		}
		
		private function _gMapPreInitializeHandler(me:MapEvent):void
		{
			var _gMapOptions:MapOptions = new MapOptions();
			_gMapOptions.zoom = _GMAPOPTIONS_ZOOM;
			_gMapOptions.center = new LatLng(GMAP_INITIAL_LAT, GMAP_INITIAL_LNG);
			_gMapOptions.mapType = MapType.NORMAL_MAP_TYPE;
			_gMapOptions.scrollWheelZoom = true;
			_gMapOptions.continuousZoom = true;
			_gMapOptions.controlByKeyboard = true;
			_gMap.setInitOptions(_gMapOptions);
		}
		
		private function _gMapReadyHandler(me:MapEvent):void
		{
			_gMapReady = true;
			if(!dispatchEvent(new GeoTagMapEvent(GeoTagMapEvent.GEOTAGMAP_READY)))
				Alert.show("Something went wrong");
			
			//_gMap.addControl(new MapTypeControl());
			var navigationControlOptions:NavigationControlOptions = new NavigationControlOptions();
			navigationControlOptions.position = new ControlPosition(ControlPosition.ANCHOR_TOP_RIGHT);
			var scaleControlOptions:ScaleControlOptions = new ScaleControlOptions();
			scaleControlOptions.position = new ControlPosition(ControlPosition.ANCHOR_BOTTOM_RIGHT);
			var mapTypeControlOptions:MapTypeControlOptions = new MapTypeControlOptions();
			mapTypeControlOptions.position = new ControlPosition(ControlPosition.ANCHOR_TOP_LEFT, 5, 5);
			mapTypeControlOptions.buttonAlignment = MapTypeControlOptions.ALIGN_HORIZONTALLY;
			_gMap.addControl(new NavigationControl(navigationControlOptions));
			_gMap.addControl(new ScaleControl(scaleControlOptions));
			_gMap.addControl(new MapTypeControl(mapTypeControlOptions));
			
			//_gMap.addEventListener(MapMouseEvent.CLICK, mapClickHandler);
			
			_getPathInitializer();
			_seeAllInitializer();
			
			_gMap.addEventListener(MapEvent.MAPTYPE_CHANGED, mapTypeChangedHandler);
		}
		
		public function setMapType(mapType:IMapType):void
		{
			if(_gMapReady)
				_gMap.setMapType(mapType);
		}
		
		private function mapTypeChangedHandler(me:MapEvent):void
		{
			if(!dispatchEvent(new GeoTagMapEvent(GeoTagMapEvent.ON_MAP_TYPE_CHANGE, _gMap.getCurrentMapType())))
				Alert.show("Something went wrong");
		}
		
//		private function mapClickHandler(mme:MapMouseEvent):void
//		{
//			for each(var marker:GeoTagMarker in _geoTagMarkerArray)
//			{
//				marker.closeInfoWindow();
//			}
//		}
	}
}