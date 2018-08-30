package components
{
	import events.YoutubeSearchEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.FlexEvent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.TextInput;
	
//	import theme.AquaGlassButtonSkin;
//	import theme.AquaSearchTextInputSkin;
	
//	import theme.AquaGlassButtonSkin;
//	import theme.AquaSearchTextInputSkin;

//	import theme.AquaSearchTextInputSkin;
	
	public final class YoutubeSearch extends Group
	{
		private const _YOUTUBE_API_VERSION:int = 2;
		private const _YOUTUBE_FORMAT:int = 5;
		private const _SEARCH_BUTTON_WIDTH:int = 60;
		private const _SEARCH_BUTTON_HEIGHT:int = 25;
		private const _SEARCH_FIELD_WIDTH:int = 200;
		private const _SEARCH_FIELD_HEIGHT:int = 25;
		
		private var _searchField:TextInput;
		private var _searchButton:Button;
		
		public function YoutubeSearch()
		{
			super();			
			_searchFieldInitializer();
			_searchButtonInitializer();
			this.width = _SEARCH_BUTTON_WIDTH + _SEARCH_FIELD_WIDTH;
			this.height = _SEARCH_BUTTON_HEIGHT;
		}
		
		private function _searchFieldInitializer():void
		{
			_searchField = new TextInput();
			_searchField.width = _SEARCH_FIELD_WIDTH;
			_searchField.height = _SEARCH_FIELD_HEIGHT;
			
			_searchField.addEventListener(FlexEvent.ENTER, sendSearchRequest);
			//_searchField.setStyle("skinClass", AquaSearchTextInputSkin);
			//
			addElement(_searchField);
		}
		
		private function _searchButtonInitializer():void
		{
			_searchButton = new Button();
			_searchButton.label = "Search";
			_searchButton.x = _SEARCH_FIELD_WIDTH;
			_searchButton.width = _SEARCH_BUTTON_WIDTH;
			_searchButton.height = _SEARCH_BUTTON_HEIGHT;
			
			_searchButton.addEventListener(MouseEvent.CLICK, sendSearchRequest);
			//_searchButton.setStyle("skinClass", AquaGlassButtonSkin);
			
			addElement(_searchButton);
		}
		
		private function sendSearchRequest(e:Event):void
		{
			if(_searchField.text)
			{
				_searchButton.enabled = false;
				_searchField.enabled = false;
				var searchRequest:HTTPService = new HTTPService('http://gdata.youtube.com/feeds/api/');
				searchRequest.url = 'videos';
				
				var parameters:Object =  new Object();
				parameters.q = _searchField.text;
				parameters.v = _YOUTUBE_API_VERSION;
				parameters.format = _YOUTUBE_FORMAT;
				
				searchRequest.addEventListener(FaultEvent.FAULT, requestFailed);
				searchRequest.addEventListener(ResultEvent.RESULT, requestSucceeded);
				
				searchRequest.send(parameters);
				
				if(!dispatchEvent(new YoutubeSearchEvent(YoutubeSearchEvent.SEARCH_BEGINNING)))
					Alert.show("Something went wrong");
			}
			else
				Alert.show("Write something to search for!");
		}
		
		private function requestFailed(fe:FaultEvent):void
		{
			Alert.show('The search failed somehow.');
			_searchButton.enabled = true;
			_searchField.enabled = true;
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
				
				if(!dispatchEvent(new YoutubeSearchEvent(YoutubeSearchEvent.VIDEOS_FOUND, feedEntry, _searchField.text)))
					Alert.show("The search failed somehow.");
			}
			else
			{
				if(!dispatchEvent(new YoutubeSearchEvent(YoutubeSearchEvent.VIDEOS_NOT_FOUND)))
					Alert.show("The search failed somehow.");
			}
			
			_searchButton.enabled = true;
			_searchField.enabled = true;
		}
	}
}