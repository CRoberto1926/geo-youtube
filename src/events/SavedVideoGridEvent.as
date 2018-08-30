package events
{
	import flash.events.Event;
	
	public final class SavedVideoGridEvent extends Event
	{
		public static const DELETE_ALL_TAGS:String = "onDeleteAllTags";
		
		private var _id:String;
		private var _rowIndex:int;
		
		public function SavedVideoGridEvent(type:String, id:String, rowIndex:int, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			_id = id;
			_rowIndex = rowIndex;
			super(type, bubbles, cancelable);
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function get rowIndex():int
		{
			return _rowIndex;
		}
		
		override public function clone():Event
		{
			return new SavedVideoGridEvent(type, id, _rowIndex);
		}
	}
}