package components
{
	import com.google.maps.InfoWindowOptions;
	import com.google.maps.LatLng;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.interfaces.IInfoWindow;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	
	public final class GeoTagMarker extends Marker
	{
		private var _dataGeoTag:Object;
		private var _results:ArrayCollection;
		private var _infoOpt:InfoWindowOptions;
		private var _infoOptCustCont:InfoWindowOptionsCustomContent;
		private var _infoWindowOpened:Boolean;
		private var _isEditing:Boolean;
		private var _isCreating:Boolean;
		private var _as3Player:AS3Player;
		
		private const CUSTOMOFFSET_X:int = -22;
		private const CUSTOMOFFSET_Y:int = 36;
		
		public function GeoTagMarker(arg0:LatLng, dataGeoTag:Object, isEditing:Boolean, isCreating:Boolean, as3Player:AS3Player, results:ArrayCollection=null, arg1:MarkerOptions=null)
		{
			super(arg0, arg1);
			
			_dataGeoTag = dataGeoTag;
			_results = results;
			_isEditing = isEditing;
			_isCreating = isCreating;
			_as3Player = as3Player;
			_infoOpt = new InfoWindowOptions();
			
			_infoOptCustCont = new InfoWindowOptionsCustomContent(this, _dataGeoTag, _isEditing, _isCreating, _results);
			_infoOpt.customContent = _infoOptCustCont;
			if(_isCreating || _isEditing)
				_infoOpt.customOffset = new Point(CUSTOMOFFSET_X, CUSTOMOFFSET_Y + 20);
			else
				_infoOpt.customOffset = new Point(CUSTOMOFFSET_X, CUSTOMOFFSET_Y);
			
			addEventListener(MapMouseEvent.CLICK, clickHandler);
		}
		
		private function clickHandler(mme:MapMouseEvent):void
		{
			if(!_isCreating && !_infoWindowOpened)
			{
				_as3Player.seekTo(_dataGeoTag.StartTime, true);				
				_as3Player.pauseVideo();
			}
			
			if(_infoWindowOpened)
			{
				this.closeInfoWindow();
				_infoWindowOpened = false;
			}
			else
			{
				this.openInfoWindow(_infoOpt);
				_infoWindowOpened = true;
			}
		}
		
		public function setStartTime(startTime:Number):void
		{
			_infoOptCustCont.setStartTime(startTime);
			_dataGeoTag.StartTime = startTime;
		}
		
		public function setEndTime(endTime:Number):void
		{
			_infoOptCustCont.setEndTime(endTime);
			_dataGeoTag.EndTime = endTime;
		}
		
		public function get dataGeoTag():Object
		{
			return _dataGeoTag;
		}
		
		public function closeDrop():void
		{
			_infoOptCustCont.closeDrop();
		}
		
		override public function openInfoWindow(arg0:InfoWindowOptions=null, arg1:Boolean=false):IInfoWindow
		{
			_infoWindowOpened = true;
			if(arg0)
				return super.openInfoWindow(arg0, arg1);
			else
				return super.openInfoWindow(_infoOpt, arg1);
		}
		
		override public function closeInfoWindow():void
		{
			if(_infoWindowOpened)
			{
				super.closeInfoWindow();
				_infoWindowOpened = false;
			}
		}
	}
}