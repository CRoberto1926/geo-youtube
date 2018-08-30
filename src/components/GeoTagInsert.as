package components
{
	import com.google.maps.LatLng;
	import com.google.maps.Map;
	import com.google.maps.MapEvent;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.MapMoveEvent;
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
	
	import events.GeoTagMapEvent;
	import events.InfoWindowOptionsCustomContentEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.core.ClassFactory;
	import mx.core.ScrollPolicy;
	import mx.events.FlexEvent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import renderers.ResultsGridRenderer;
	import renderers.YoutubeVideoGridRenderer;
	
	import spark.components.Button;
	import spark.components.DataGrid;
	import spark.components.Group;
	import spark.components.TextInput;
	import spark.components.gridClasses.GridColumn;
	import spark.events.GridSelectionEvent;
	
	public final class GeoTagInsert extends Group
	{
		private var _searchButton:Button;
		private var _searchField:TextInput;
		private var _resultsGrid:DataGrid;
		private var _gMap:Map;
		private var _geoTagMarker:GeoTagMarker;
		private var _gMapReady:Boolean;
		private var _isEditing:Boolean;
		private var _isCreating:Boolean;
		private var _dataGeoTag:Object;
		private var _as3Player:AS3Player;
		
		private const _SEARCH_BUTTON_WIDTH:int = 60;
		private const _SEARCH_BUTTON_HEIGHT:int = 25;
		private const _SEARCH_FIELD_WIDTH:int = 200;
		private const _SEARCH_FIELD_HEIGHT:int = 25;
		private const _GMAP_WIDTH_OFFSET:int = 2;
		private const _GMAPOPTIONS_ZOOM:int = 14;
		private const GMAP_INITIAL_LAT:int = 43.76667;
		private const GMAP_INITIAL_LNG:int = 11.25;
		private const _RESULTSGRID_HEIGHT_OFFSET:int = 33;
		private const RADIUS_FIND_NEARBY_WIKIPEDIA:int = 2;
		private const MAXROWS_FIND_NEARBY_WIKIPEDIA:int = 500;
		private const MAXROWS_SEARCH:int = 1000;
		
		public function GeoTagInsert(width:Number, height:Number, as3Player:AS3Player)
		{
			super();
			
			this.width = width;
			this.height = height;
			_gMapReady = false;
			_isEditing = false;
			_isCreating = false;
			_as3Player = as3Player;
			
			_searchFieldInitializer();
			_searchButtonInitializer();
			_resultsGridInitializer();
			_gMapInitializer();
			
			addEventListener(InfoWindowOptionsCustomContentEvent.WIKIENTRY_CHANGE, wikiEntryChangeHandler);
			addEventListener(InfoWindowOptionsCustomContentEvent.GEOTAG_START, geoTagStartHandler);
			addEventListener(InfoWindowOptionsCustomContentEvent.GEOTAG_END, geoTagEndHandler);
			addEventListener(InfoWindowOptionsCustomContentEvent.GEOTAG_SAVEEDIT, geoTagSaveEditHandler);
			
			//addEventListener(MouseEvent.CLICK, clickHandler);
			//addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
		}
		
		private function geoTagStartHandler(iwocce:InfoWindowOptionsCustomContentEvent):void
		{
			var startTime:Number = _as3Player.getCurrentTime();
			_geoTagMarker.setStartTime(startTime);
			if(_dataGeoTag != null)
				_dataGeoTag.StartTime = startTime;
		}
		
		public function set isCreating(value:Boolean):void
		{
			_isCreating = value;
		}
		
		public function set isEditing(value:Boolean):void
		{
			_isEditing = value;
		}
		
		public function set dataGeoTag(value:Object):void
		{
			_dataGeoTag = value;
		}
		
		public function editMarker(dataGeoTag:Object):void
		{
			if(_gMapReady)
			{
				_dataGeoTag = dataGeoTag;
				
				var searchRequest:HTTPService = new HTTPService('http://api.geonames.org/');
				searchRequest.url = 'search';
				
				var parameters:Object =  new Object();
				parameters.username = escape("ziocorto");
				parameters.q = escape(dataGeoTag.name);
				parameters.maxRows = MAXROWS_SEARCH;
				
				searchRequest.addEventListener(FaultEvent.FAULT, requestFailed);
				searchRequest.addEventListener(ResultEvent.RESULT, requestEditSearchSucceeded);
				
				searchRequest.send(parameters);
				_searchField.text = dataGeoTag.name;
				
				var latLng:LatLng = new LatLng(dataGeoTag.lat, dataGeoTag.lng);
				
				var markOpt:MarkerOptions  = new MarkerOptions();
				markOpt.icon = new MarkerIcon(dataGeoTag.fcl);
				
				var results:ArrayCollection = new ArrayCollection();
				
				if(dataGeoTag.title != "undefined" && dataGeoTag.wikipediaUrl != "undefined" && dataGeoTag.summary != "undefined" && dataGeoTag.title != "null" && dataGeoTag.wikipediaUrl != "null" && dataGeoTag.summary != "null" && dataGeoTag.title && dataGeoTag.wikipediaUrl && dataGeoTag.summary)
					results.addItem(dataGeoTag);
				else
					results = null;
				
				_gMap.clearOverlays();
				_geoTagMarker = new GeoTagMarker(latLng, dataGeoTag, _isEditing, _isCreating, _as3Player, results, markOpt);
				_gMap.addOverlay(_geoTagMarker);
				_gMap.panTo(latLng);
				_geoTagMarker.openInfoWindow();
			}
			else
				Alert.show("Map is not ready!");
		}
		
		public function clean():void
		{
			_searchField.text = "";
			_resultsGrid.dataProvider = null;
			if(_gMapReady)
			{
				_gMap.clearOverlays();
				_gMap.closeInfoWindow();
			}
			_geoTagMarker = null;
			_searchField.enabled = true;
			_searchButton.enabled = true;
			_resultsGrid.enabled = true;
			_dataGeoTag = null;
		}
		
		private function geoTagEndHandler(iwocce:InfoWindowOptionsCustomContentEvent):void
		{
			var endTime:Number = _as3Player.getCurrentTime();
			_geoTagMarker.setEndTime(endTime);
			if(_dataGeoTag != null)
				_dataGeoTag.EndTime = endTime;
			//			_searchField.text = "";
			//			_resultsGrid.dataProvider = null;
			//			if(_gMapReady)
			//				_gMap.clearOverlays();
			//			_searchField.enabled = true;
			//			_searchButton.enabled = true;
			//			_resultsGrid.enabled = true;
		}
		
		//				private function clickHandler(me:MouseEvent):void
		//				{
		//					if(_geoTagMarker)
		//						_geoTagMarker.closeDrop();
		//				}
		
		//				private function mouseWheelHandler(me:MouseEvent):void
		//				{
		//					if(_geoTagMarker)
		//						_geoTagMarker.closeDrop();
		//				}
		
		private function geoTagSaveEditHandler(iwocce:InfoWindowOptionsCustomContentEvent):void
		{
			_searchField.text = "";
			//this._dataGeoTag = null;
			_resultsGrid.dataProvider = null;
			if(_gMapReady)
				_gMap.clearOverlays();
		}
		
		private function requestEditSearchSucceeded(re:ResultEvent):void
		{
			if(re.result.geonames.geoname)
			{
				var feedEntry:ArrayCollection = new ArrayCollection();
				
				if(getQualifiedClassName(re.result.geonames.geoname) == "mx.collections::ArrayCollection")
					feedEntry = re.result.geonames.geoname;
				else if(getQualifiedClassName(re.result.geonames.geoname) == "mx.utils::ObjectProxy")
					feedEntry.addItem(re.result.geonames.geoname);
				
				if(_isEditing)
				{
					for each(var result:Object in feedEntry)
					{
						result.Id = _dataGeoTag.Id;
					}
				}
				_resultsGrid.dataProvider = feedEntry;
			}
			else
			{
				Alert.show("No results.");
			}
		}
		
		//		private function mouseOverHandler(me:MouseEvent):void
		//		{
		//			//_infoOptCustCont.closeDrop();
		//		}
		
		private function wikiEntryChangeHandler(iwocce:InfoWindowOptionsCustomContentEvent):void
		{
			_geoTagMarker.setLatLng(new LatLng(iwocce.dataGeoTag.lat, iwocce.dataGeoTag.lng));
			//_geoTagMarker.closeDrop();
			_geoTagMarker.openInfoWindow();
		}
		
		private function _gMapInitializer():void
		{
			_gMap = new Map();
			_gMap.key = "ABQIAAAAZOMJ01MRIB1eqNG6Sc2d5hT2yXp_ZAY8_ufC3CFXhHIE1NvwkxQM_qn5J3ao3C5gZzUfAuNenVq6yQ";
			_gMap.url = "http://code.google.com/apis/maps/";
			_gMap.sensor = "false";
			
			_gMap.width = this.width - _SEARCH_BUTTON_WIDTH - _SEARCH_FIELD_WIDTH - _GMAP_WIDTH_OFFSET; //HEURISTIC
			_gMap.height = _resultsGrid.height + _SEARCH_BUTTON_HEIGHT;
			_gMap.x = _SEARCH_BUTTON_WIDTH + _SEARCH_FIELD_WIDTH;
			
			_gMap.addEventListener(MapEvent.MAP_PREINITIALIZE, _gMapPreInitializeHandler);
			_gMap.addEventListener(MapEvent.MAP_READY, mapReadyHandler);
			
			addElement(_gMap);
		}
		
		private function mapReadyHandler(me:MapEvent):void
		{
			_gMapReady = true;
			
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
			
			_gMap.addEventListener(MapMoveEvent.MOVE_END, mapMoveHandler);
			_gMap.addEventListener(MapEvent.MAPTYPE_CHANGED, mapTypeChangedHandler);
			//_gMap.addEventListener(MapMouseEvent.MOUSE_DOWN, mapClickHandler);
			
		}
		
		private function mapTypeChangedHandler(me:MapEvent):void
		{
			if(!dispatchEvent(new GeoTagMapEvent(GeoTagMapEvent.ON_MAP_TYPE_CHANGE, _gMap.getCurrentMapType())))
				Alert.show("Something went wrong");
		}
		
				private function mapMoveHandler(mme:MapMoveEvent):void
				{
					if(_geoTagMarker)
						_geoTagMarker.closeDrop();
				}
		
//		private function mapClickHandler(mme:MapMouseEvent):void
//		{
//			if(_geoTagMarker)
//				_geoTagMarker.closeDrop();
//		}
		
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
		
		private function _searchFieldInitializer():void
		{
			_searchField = new TextInput();
			_searchField.width = _SEARCH_FIELD_WIDTH;
			_searchField.height = _SEARCH_FIELD_HEIGHT;
			
			_searchField.addEventListener(FlexEvent.ENTER, sendSearchRequest);
			
			addElement(_searchField);
		}
		
		public function setMapType(mapType:IMapType):void
		{
			if(_gMapReady)
				_gMap.setMapType(mapType);
		}
		
		private function _searchButtonInitializer():void
		{
			_searchButton = new Button();
			_searchButton.label = "Search";
			_searchButton.x = _SEARCH_FIELD_WIDTH;
			_searchButton.width = _SEARCH_BUTTON_WIDTH;
			_searchButton.height = _SEARCH_BUTTON_HEIGHT;
			
			_searchButton.addEventListener(MouseEvent.CLICK, sendSearchRequest);
			
			addElement(_searchButton);
		}
		
		private function _resultsGridInitializer():void
		{
			_resultsGrid = new DataGrid();
			_resultsGrid.y = _SEARCH_BUTTON_HEIGHT;
			_resultsGrid.width = _SEARCH_BUTTON_WIDTH + _SEARCH_FIELD_WIDTH;
			
			var columns:ArrayList = new ArrayList();
			//var countryColumn:GridColumn = new GridColumn("countryName");
			//countryColumn.headerText = "Country";
			//countryColumn.itemRenderer = new ClassFactory(ResultsGridRenderer);
			var placeColumn:GridColumn = new GridColumn("name");
			placeColumn.headerText = "Place";
			placeColumn.dataTipField = "countryName";
			placeColumn.showDataTips = true;
			//placeColumn.itemRenderer = new ClassFactory(ResultsGridRenderer);
			//columns.addItem(countryColumn);
			columns.addItem(placeColumn);
			_resultsGrid.columns = columns;
			
			_resultsGrid.height = this.height - _SEARCH_BUTTON_HEIGHT - _RESULTSGRID_HEIGHT_OFFSET; //HEURISTIC
			
			_resultsGrid.itemRenderer = new ClassFactory(ResultsGridRenderer);
			
			_resultsGrid.setStyle("horizontalScrollPolicy", ScrollPolicy.OFF);
			
			_resultsGrid.addEventListener(GridSelectionEvent.SELECTION_CHANGE, selectionChangeHandler);
			_resultsGrid.addEventListener(FlexEvent.VALUE_COMMIT, valueCommitHandler);
			
			addElement(_resultsGrid);
		}
		
		private function valueCommitHandler(fe:FlexEvent):void
		{
			_resultsGrid.enabled = false;
			_searchButton.enabled = false;
			_searchField.enabled = false;
			_gMap.clearOverlays();
			
			var searchRequest:HTTPService = new HTTPService('http://api.geonames.org/');
			searchRequest.url = 'findNearbyWikipedia';
			
			var parameters:Object =  new Object();
			parameters.lat = _resultsGrid.selectedItem.lat;
			parameters.lng = _resultsGrid.selectedItem.lng;
			parameters.username = escape("ziocorto");
			parameters.radius = RADIUS_FIND_NEARBY_WIKIPEDIA;
			parameters.maxRows = MAXROWS_FIND_NEARBY_WIKIPEDIA;
			
			searchRequest.addEventListener(FaultEvent.FAULT, requestFailed);
			searchRequest.addEventListener(ResultEvent.RESULT, requestFindNearbyWikipediaSucceeded);
			
			searchRequest.send(parameters);
		}
		
		private function selectionChangeHandler(gse:GridSelectionEvent):void
		{
			_resultsGrid.enabled = false;
			_searchButton.enabled = false;
			_searchField.enabled = false;
			_gMap.clearOverlays();
			
			var searchRequest:HTTPService = new HTTPService('http://api.geonames.org/');
			searchRequest.url = 'findNearbyWikipedia';
			
			var parameters:Object =  new Object();
			parameters.lat = _resultsGrid.selectedItem.lat;
			parameters.lng = _resultsGrid.selectedItem.lng;
			parameters.username = escape("ziocorto");
			parameters.radius = RADIUS_FIND_NEARBY_WIKIPEDIA;
			parameters.maxRows = MAXROWS_FIND_NEARBY_WIKIPEDIA;
			
			searchRequest.addEventListener(FaultEvent.FAULT, requestFailed);
			searchRequest.addEventListener(ResultEvent.RESULT, requestFindNearbyWikipediaSucceeded);
			
			searchRequest.send(parameters);
		}
		
		private function requestFailed(fe:FaultEvent):void
		{
			Alert.show('The search failed somehow.');
			_searchButton.enabled = true;
			_searchField.enabled = true;
		}
		
		private function requestFindNearbyWikipediaSucceeded(re:ResultEvent):void
		{
			//null object reference riga 341?
			var lat:Number = _resultsGrid.selectedItem.lat;
			var lng:Number = _resultsGrid.selectedItem.lng;
			var latLng:LatLng = new LatLng(lat, lng);
			
			var markOpt:MarkerOptions  = new MarkerOptions();
			markOpt.icon = new MarkerIcon(_resultsGrid.selectedItem.fcl);
			markOpt.iconAlignment = MarkerOptions.ALIGN_HORIZONTAL_CENTER;
			markOpt.iconOffset = new Point(0, -36);
			
			var tempData:Object = _resultsGrid.selectedItem;
			if(_dataGeoTag != null)
			{
				if(_dataGeoTag.StartTime != null && _dataGeoTag.EndTime != null)
				{
					tempData.StartTime = _dataGeoTag.StartTime;
					tempData.EndTime = _dataGeoTag.EndTime;
				}
			}
			_gMap.clearOverlays();
			if(re.result.geonames)
			{
				var feedEntry:ArrayCollection = new ArrayCollection();
				
				if(getQualifiedClassName(re.result.geonames.entry) == "mx.collections::ArrayCollection")
					feedEntry = re.result.geonames.entry;
				else if(getQualifiedClassName(re.result.geonames.entry) == "mx.utils::ObjectProxy")
					feedEntry.addItem(re.result.geonames.entry);
				
				_geoTagMarker = new GeoTagMarker(latLng, tempData, _isEditing, _isCreating, _as3Player, feedEntry, markOpt);
				
				//addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			}
			else
			{
				//removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
				
				_geoTagMarker = new GeoTagMarker(latLng, tempData, _isEditing, _isCreating, _as3Player, null, markOpt);
			}			
			_gMap.addOverlay(_geoTagMarker);
			
			_gMap.panTo(latLng);
			_geoTagMarker.openInfoWindow();
			
			_resultsGrid.enabled = true;
			_searchButton.enabled = true;
			_searchField.enabled = true;
		}
		
		private function requestSearchSucceeded(re:ResultEvent):void
		{
			_resultsGrid.dataProvider = null;
			
			if(re.result.geonames.geoname)
			{
				var feedEntry:ArrayCollection = new ArrayCollection();
				
				if(getQualifiedClassName(re.result.geonames.geoname) == "mx.collections::ArrayCollection")
					feedEntry = re.result.geonames.geoname;
				else if(getQualifiedClassName(re.result.geonames.geoname) == "mx.utils::ObjectProxy")
					feedEntry.addItem(re.result.geonames.geoname);
				
				if(_isEditing)
				{
					for each(var result:Object in feedEntry)
					{
						result.Id = _dataGeoTag.Id;
					}
				}
				_resultsGrid.dataProvider = feedEntry;
				_resultsGrid.selectedIndex = 0;
			}
			else
			{
				Alert.show("No results.");
			}
			_searchButton.enabled = true;
			_searchField.enabled = true;
		}
		
		private function sendSearchRequest(e:Event):void
		{
			if(_searchField.text){
				_gMap.clearOverlays();
				_searchButton.enabled = false;
				_searchField.enabled = false;
				
				var searchRequest:HTTPService = new HTTPService('http://api.geonames.org/');
				searchRequest.url = 'search';
				
				var parameters:Object =  new Object();
				parameters.username = escape("ziocorto");
				
				//parameters.q = escape(_searchField.text);
				parameters.q = _searchField.text;
				parameters.maxRows = MAXROWS_SEARCH;
				
				searchRequest.addEventListener(FaultEvent.FAULT, requestFailed);
				searchRequest.addEventListener(ResultEvent.RESULT, requestSearchSucceeded);
				
				searchRequest.send(parameters);
			}
		}
	}
}