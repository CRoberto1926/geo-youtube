package events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public final class YoutubeSearchEvent extends Event
	{
		public static const VIDEOS_FOUND:String = "onVideosFound";
		public static const VIDEOS_NOT_FOUND:String = "onVideosNotFound";
		public static const SEARCH_BEGINNING:String = "onSearchBeginning";
		
		private var _searchResponse:ArrayCollection;
		private var _searchString:String;
		
		public function YoutubeSearchEvent(type:String, searchResponse:ArrayCollection=null, searchString:String=null, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_searchResponse = searchResponse;
			_searchString = searchString;
		}
		
		public function get searchResponse():ArrayCollection
		{
			return _searchResponse;
		}
		
		public function get searchString():String
		{
			return _searchString;
		}
		
		override public function clone():Event
		{
			return new YoutubeSearchEvent(type, _searchResponse);
		}			
	}
}