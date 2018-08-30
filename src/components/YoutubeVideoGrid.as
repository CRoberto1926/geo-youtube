package components
{
	import flash.events.MouseEvent;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.core.ClassFactory;
	import mx.core.ScrollPolicy;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import renderers.YoutubeVideoGridRenderer;
	import renderers.SavedVideoGridRenderer;
	
	import spark.components.DataGrid;
	import spark.components.gridClasses.GridColumn;
	import spark.events.GridSelectionEvent;
	
	public final class YoutubeVideoGrid extends DataGrid
	{
		private const _DATAGRID_LIMIT_OFFSET:int = 15;
		private const _YOUTUBE_API_VERSION:int = 2;
		private const _YOUTUBE_FORMAT:int = 5;
		
		private var _searchString:String;
		private var _rotationCount:int;
		private var _rotationLimit:int;
		
		public function YoutubeVideoGrid(/*searchResponse:ArrayCollection, searchString:String*/)
		{
			super();
			
			var columns:ArrayList = new ArrayList();
			var videoColumn:GridColumn = new GridColumn("title");
			videoColumn.headerText = "Videos";
			videoColumn.dataTipField = "description";
			videoColumn.showDataTips = true;
			columns.addItem(videoColumn);
			this.columns = columns;
			
			this.itemRenderer = new ClassFactory(YoutubeVideoGridRenderer);
			
			this.setStyle("horizontalScrollPolicy", ScrollPolicy.OFF);
			
			//updateSearchParameters(searchResponse, searchString);
			
			//addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelRotationHandler);
			//addEventListener(GridSelectionEvent.SELECTION_CHANGING, selectionChangingHandler);
		}
		
		public function updateSearchParameters(searchResponse:ArrayCollection, searchString:String):void
		{
			this.dataProvider = parseSearchResponse(searchResponse);
			_searchString = searchString;
			_rotationCount = 0;
			_rotationLimit = -this.dataProvider.length + _DATAGRID_LIMIT_OFFSET;
			this.selectedIndex = 0;
		}
		
		private function selectionChangingHandler(gse:GridSelectionEvent):void
		{
			_rotationCount = -gse.selectionChange.rowIndex;
			
			if(gse.selectionChange.rowIndex == this.dataProviderLength - 1)
			{
				var searchRequest:HTTPService = new HTTPService('http://gdata.youtube.com/feeds/api/');
				searchRequest.url = 'videos';
				
				var parameters:Object =  new Object();
				parameters.q = _searchString;
				parameters.v = _YOUTUBE_API_VERSION;
				parameters.format = _YOUTUBE_FORMAT;
				parameters['start-index'] = this.dataProviderLength + 1;
				
				searchRequest.addEventListener(ResultEvent.RESULT, requestSucceeded);
				
				searchRequest.send(parameters);
			}
		}
		
		private function mouseWheelRotationHandler(me:MouseEvent):void
		{
			if(_rotationCount < 0)
				_rotationCount += me.delta;
			else if(me.delta < 0)
				_rotationCount += me.delta;
			
			if(_rotationCount < _rotationLimit)
			{
				var searchRequest:HTTPService = new HTTPService('http://gdata.youtube.com/feeds/api/');
				searchRequest.url = 'videos';
				
				var parameters:Object =  new Object();
				parameters.q = _searchString;
				parameters.v = _YOUTUBE_API_VERSION;
				parameters.format = _YOUTUBE_FORMAT;
				parameters['start-index'] = this.dataProviderLength + 1;
				
				searchRequest.addEventListener(ResultEvent.RESULT, requestSucceeded);
				
				searchRequest.send(parameters);
			}
		}
		
		private function requestSucceeded(re:ResultEvent):void
		{
			if(re.result.feed.entry)
			{
				var feedEntry:ArrayCollection = new ArrayCollection();
				
				if(getQualifiedClassName(re.result.feed.entry) == "mx.collections::ArrayCollection")
					feedEntry = re.result.feed.entry;
				else if(getQualifiedClassName(re.result.feed.entry) == "mx.utils::ObjectProxy")
					feedEntry.addItem(re.result.feed.entry);
				
				var videos:ArrayList = parseSearchResponse(feedEntry);
				
				for each (var video:Object in videos.source)
				{
					this.dataProvider.addItem(video);
				}
				
				_rotationLimit = -this.dataProvider.length + _DATAGRID_LIMIT_OFFSET;
			}
		}
		
		private function parseSearchResponse(searchResponse:ArrayCollection):ArrayList
		{
			var parsedSearchResponse:ArrayList = new ArrayList();
			var infoVideo:Object;
			
			for each(var videoFound:Object in searchResponse)
			{
				infoVideo = new Object();
				//Be careful, in the description section returned by YouTube there's a type section.
				infoVideo.description = videoFound.group.description.value;
				infoVideo.title = videoFound.group.title;
				infoVideo.id = videoFound.group.videoid;
				
				parsedSearchResponse.addItem(infoVideo);
			}
			
			return parsedSearchResponse;
		}
	}
}