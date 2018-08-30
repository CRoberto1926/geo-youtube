package components
{
	//import flashx.textLayout.container.ScrollPolicy;
	
	import mx.collections.ArrayList;
	import mx.core.ClassFactory;
	import mx.core.ScrollPolicy;
	
	import renderers.SavedVideoGridRenderer;
	
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.DataGrid;
	import spark.components.gridClasses.GridColumn;
	import spark.components.gridClasses.GridItemRenderer;

	//import spark.skins.spark.DefaultGridItemRenderer;
	
	public final class SavedVideoGrid extends DataGrid
	{
		public function SavedVideoGrid()
		{
			super();
			
			var columns:ArrayList = new ArrayList();
			var videoColumn:GridColumn = new GridColumn("title");
			videoColumn.headerText = "Videos";
			videoColumn.dataTipField = "description";
			videoColumn.showDataTips = true;
			columns.addItem(videoColumn);
			this.columns = columns;
			
			this.itemRenderer = new ClassFactory(SavedVideoGridRenderer);
			
			this.setStyle("horizontalScrollPolicy", ScrollPolicy.OFF);
		}
	}
}