package components
{
	import flash.filesystem.File;
	
	import spark.components.Image;
	
	public final class MarkerIcon extends Image
	{
		public function MarkerIcon(featureClass:String)
		{
			super();
			switch(featureClass)
			{
				case "P":
					//this.source = "http://www.geonames.org/maps/markers/marker-WHITE-P-10.png";
					//this.source = "http://img64.imageshack.us/img64/2307/ppmmarkerp.gif";
					this.source = "http://img221.imageshack.us/img221/1972/markerpt.gif";
					break;
				
				case "T":
					//this.source = "http://www.geonames.org/maps/markers/marker-ORANGE-T-10.png";
					//this.source = "http://img705.imageshack.us/img705/3610/ppmmarkert.gif";
					this.source = "http://img269.imageshack.us/img269/6020/markert.gif";
					break;
				
				case "H":
					//this.source = "http://www.geonames.org/maps/markers/marker-BLUE-H-10.png";
					//this.source = "http://img823.imageshack.us/img823/3196/ppmmarkerh.gif";
					this.source = "http://img37.imageshack.us/img37/2590/markerhi.gif";
					break;
				
				case "A":
					//this.source = "http://www.geonames.org/maps/markers/marker-RED-A-10.png";
					//this.source = "http://img33.imageshack.us/img33/8276/ppmmarkera.gif";
					this.source = "http://img830.imageshack.us/img830/4184/markera.gif";
					break;
				
				case "L":
					//this.source = "http://www.geonames.org/maps/markers/marker-AQUA-L-10.png";
					//this.source = "http://img42.imageshack.us/img42/5356/ppmmarkerl.gif";
					this.source = "http://img195.imageshack.us/img195/2430/markerl.gif";
					break;
				
				case "R":
					//this.source = "http://www.geonames.org/maps/markers/marker-YELLOW-R-10.png";
					//this.source = "http://img34.imageshack.us/img34/180/ppmmarkerr.gif";
					this.source = "http://img651.imageshack.us/img651/2158/markerr.gif";
					break;
				
				case "S":
					//this.source = "http://www.geonames.org/maps/markers/marker-PURPLE-S-10.png";
					//this.source = "http://img263.imageshack.us/img263/341/ppmmarkers.gif";
					this.source = "http://img695.imageshack.us/img695/8433/markers.gif";
					break;
				
				case "V":
					//this.source = "http://www.geonames.org/maps/markers/marker-GREEN-V-10.png";
					//this.source = "http://img856.imageshack.us/img856/9270/ppmmarkerv.gif";
					this.source = "http://img21.imageshack.us/img21/9353/markerv.gif";
					break;
				
				case "U":
					//this.source = "http://www.geonames.org/maps/markers/marker-GRAY-U-10.png";
					//this.source = "http://img843.imageshack.us/img843/4109/ppmmarkeru.gif";
					this.source = "http://img683.imageshack.us/img683/8824/markeru.gif";
					break;
			}
//			this.width = 36;
//			this.height = 36;
		}
	}
}