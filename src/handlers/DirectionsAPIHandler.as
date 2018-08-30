package handlers
{
	import com.google.maps.LatLng;
	import com.google.maps.overlays.EncodedPolylineData;
	import com.google.maps.overlays.Polyline;
	
	import events.DirectionsAPIHandlerEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	public final class DirectionsAPIHandler extends EventDispatcher
	{
		private var _origin:LatLng;
		private var _destination:LatLng;
		
		public function DirectionsAPIHandler(origin:LatLng, destination:LatLng)
		{
			super();
			
			_origin = origin;
			_destination = destination;
			
			var searchRequest:HTTPService = new HTTPService('http://maps.googleapis.com/maps/api/directions/');
			searchRequest.url = 'xml';
			
			var parameters:Object =  new Object();
			parameters.sensor = "false";
			parameters.alternatives = "false";
			parameters.origin = origin.lat().toString() + "," + origin.lng().toString();
			parameters.destination = destination.lat().toString() + "," + destination.lng().toString();
			
			searchRequest.addEventListener(FaultEvent.FAULT, requestFailed);
			searchRequest.addEventListener(ResultEvent.RESULT, requestSucceeded);
			
			searchRequest.send(parameters);
		}
		
		private function requestFailed(fe:FaultEvent):void
		{
			
		}
		
		private function requestSucceeded(re:ResultEvent):void
		{
			var encodedData:EncodedPolylineData;
			var path:Polyline = new Polyline(null);
			
			if(re.result.DirectionsResponse.status == "OK")
			{
				encodedData = new EncodedPolylineData(re.result.DirectionsResponse.route.overview_polyline.points, 1, re.result.DirectionsResponse.route.overview_polyline.levels, 1);
				path = Polyline.fromEncoded(encodedData);
				//points = re.result.DirectionsResponse.route.overview_polyline.points;
//				if(getQualifiedClassName(re.result.DirectionsResponse.route.leg.step) == "mx.collections::ArrayCollection")
//					feedEntry = re.result.DirectionsResponse.route.leg.step;
//				else if(getQualifiedClassName(re.result.DirectionsResponse.route.leg.step) == "mx.utils::ObjectProxy")
//					feedEntry.addItem(re.result.DirectionsResponse.route.leg.step);
			}
			else
			{
				path = new Polyline(new Array(_origin, _destination));
				//points[0] = _origin;
				//points[1] = _destination;
			}
			
			if(!dispatchEvent(new DirectionsAPIHandlerEvent(DirectionsAPIHandlerEvent.DIRECTIONS_OBTAINED, path)))
				Alert.show("Something went wrong");
		}
	}
}