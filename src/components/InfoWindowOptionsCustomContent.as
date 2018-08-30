package components
{
	import events.InfoWindowOptionsCustomContentEvent;
	
	import flash.display.Scene;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import flashx.textLayout.elements.TextFlow;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.ScrollPolicy;
	import mx.events.DropdownEvent;
	import mx.events.FlexEvent;
	
	import skins.TextAreaSkin;
	
	import spark.components.Button;
	import spark.components.DropDownList;
	import spark.components.Group;
	import spark.components.TextArea;
	import spark.components.TextInput;
	import spark.events.DropDownEvent;
	import spark.events.IndexChangeEvent;
	import spark.events.ListEvent;
	import spark.utils.TextFlowUtil;
	
	public final class InfoWindowOptionsCustomContent extends Group
	{
		private const _TITLELIST_HEIGHT:int = 28;
		private const _TITLELIST_WIDTH:int = 180;
		private const _LINK_Y:int = -25;
		private const _LINK_HEIGHT:int = 25;
		private const _SAVEGEOTAG_WIDTH:int = 50;
		
		private var _titleList:DropDownList;
		private var _title:TextArea;
		private var _results:ArrayCollection;
		//private var _summary:TextArea;
		private var _link:Button;
		private var _startGeoTag:Button;
		private var _endGeoTag:Button;
		private var _editGeoTag:Button;
		private var _deleteGeoTag:Button;
		private var _saveEditGeoTag:Button;
		private var _dataGeoTag:Object;
		private var _isCreating:Boolean;
		private var _isEditing:Boolean;
		private var _geoTagMarker:GeoTagMarker;
		private var _url:URLRequest;
		private var _startTimeText:TextArea;
		private var _endTimeText:TextArea;
		private var _insertGeoTag:Button;
		
		public function InfoWindowOptionsCustomContent(geoTagMarker:GeoTagMarker, dataGeoTag:Object, isEditing:Boolean, isCreating:Boolean, results:ArrayCollection=null)
		{
			super();
			_results = results;
			_isEditing = isEditing;
			_isCreating = isCreating;
			_geoTagMarker = geoTagMarker;
			_dataGeoTag = dataGeoTag;
			
			if(results)
			{
				
				//_summaryInitializer();
				_linkInitializer();
				_titleListInitializer();
			}
			else if(!_isCreating && _dataGeoTag.title != "null" && _dataGeoTag.title != "undefined" && _dataGeoTag.title && _dataGeoTag.summary != "null" && _dataGeoTag.summary != "undefined" && _dataGeoTag.summary && _dataGeoTag.wikipediaUrl != "null" && _dataGeoTag.wikipediaUrl != "undefined" && _dataGeoTag.wikipediaUrl)
			{
				
				//_summaryInitializer(_dataGeoTag.summary);
				_linkInitializer(_dataGeoTag.wikipediaUrl);
				_titleInitializer(_dataGeoTag.title);
				_link.visible = false; //RIMUOVERE ASSOLUTAMENTE
				_link.enabled = false; //RIMUOVERE ASSOLUTAMENTE
			}
			else
				_titleInitializer(_dataGeoTag.name);
			
			if(_isCreating)
			{
				_insertGeoTagInitializer();
				_startGeoTagInitializer();
				_endGeoTagInitializer();
				_startTimeTextInitializer();
				_endTimeTextInitializer();
			}
			else if(_isEditing)
			{
				_startGeoTagInitializer();
				_endGeoTagInitializer();
				_saveEditGeoTagInitializer();
				//_deleteGeoTagInitializer();
				_startTimeTextInitializer();
				_endTimeTextInitializer();
			}
			else
			{
				_editGeoTagInitializer();
				_deleteGeoTagInitializer();
			}
			
			//addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelOutHandler);
		}
		
		public function closeDrop():void
		{
			if(_titleList)
				if(_titleList.dropDown)
					_titleList.closeDropDown(false);
		}
		
		public function setStartTime(startTime:Number):void
		{
			//if(startTime < _dataGeoTag.EndTime || _dataGeoTag.EndTime == null)
			//{
				_dataGeoTag.StartTime = startTime;
				var minutes:int = Math.floor(Math.round(startTime) / 60);
				var seconds:int = Math.round(startTime) % 60;
				var secondsString:String = (seconds.toString().length == 1) ? "0" + seconds.toString() : seconds.toString();
				_startTimeText.text = minutes.toString() + ":" + secondsString;
			//}
			//else
				//Alert.show("Start Time can't be bigger or equal to End Time!");
		}
		
		public function setEndTime(endTime:Number):void
		{
			//if(_dataGeoTag.StartTime < endTime || (_dataGeoTag.StartTime == null && endTime > 0))
			//{
				_dataGeoTag.EndTime = endTime;
				var minutes:int = Math.floor(Math.round(endTime) / 60);
				var seconds:int = Math.round(endTime) % 60;
				var secondsString:String = (seconds.toString().length == 1) ? "0" + seconds.toString() : seconds.toString();
				_endTimeText.text = minutes.toString() + ":" + secondsString;
			//}
			//else
				//Alert.show("End Time can't be smaller or equal to Start Time, or End Time can't be zero!");
		}
		
		private function _startTimeTextInitializer():void
		{
			_startTimeText = new TextArea();
			if(_results)
				_startTimeText.x = _titleList.width + _startGeoTag.width;
			else
				_startTimeText.x = _title.width;
			//_startTimeText.y = _startGeoTag.y + _startGeoTag.height;
			
			_startTimeText.width = 35;
			_startTimeText.height = 14;
			
			if(_dataGeoTag.StartTime != null)
			{
				var minutes:int = Math.floor(Math.round(_dataGeoTag.StartTime) / 60);
				var seconds:int = Math.round(_dataGeoTag.StartTime) % 60;
				var secondsString:String = (seconds.toString().length == 1) ? "0" + seconds.toString() : seconds.toString();
				_startTimeText.text = minutes.toString() + ":" + secondsString;
			}
			
			_startTimeText.setStyle("skinClass", TextAreaSkin);
			_startTimeText.editable = false;
			addElement(_startTimeText);
		}
		
		private function _endTimeTextInitializer():void
		{
			_endTimeText = new TextArea();
			if(_results)
				_endTimeText.x = _titleList.width + _endGeoTag.width;
			else
				_endTimeText.x = _title.width + _startTimeText.width;
			_endTimeText.y = _endGeoTag.y;
			
			_endTimeText.width = 35;
			_endTimeText.height = 14;
			
			if(_dataGeoTag.EndTime != null)
			{
				var minutes:int = Math.floor(Math.round(_dataGeoTag.EndTime) / 60);
				var seconds:int = Math.round(_dataGeoTag.EndTime) % 60;
				var secondsString:String = (seconds.toString().length == 1) ? "0" + seconds.toString() : seconds.toString();
				_endTimeText.text = minutes.toString() + ":" + secondsString;
			}
			
			_endTimeText.setStyle("skinClass", TextAreaSkin);
			_endTimeText.editable = false;
			
			addElement(_endTimeText);
		}
		
		//		private function mouseWheelOutHandler(me:MouseEvent):void
		//		{
		//			//			Alert.show(_titleList.dropDown.x.toString());
		//			//			Alert.show(_titleList.dropDown.y.toString());
		//			//_titleList.closeDropDown(false);
		//		}
		
		//		private function closeHandler(dde:DropDownEvent):void
		//		{
		//			this.closeDrop();
		//		}
		
		private function _titleListInitializer():void
		{
			_titleList = new DropDownList();
			_titleList.dataProvider = _results;
			_titleList.labelField = "title";
			_titleList.height = _TITLELIST_HEIGHT;
			_titleList.width = _TITLELIST_WIDTH;
			
			_titleList.addEventListener(IndexChangeEvent.CHANGE, changeHandler);
			_titleList.addEventListener(FlexEvent.VALUE_COMMIT, valueCommitHandler);
			//_titleList.addEventListener(MouseEvent.ROLL_OUT, mouseWheelOutHandler);
			//_titleList.addEventListener(DropDownEvent.CLOSE, closeHandler);
			
			_titleList.setStyle("horizontalScrollPolicy", ScrollPolicy.OFF);
			
			_titleList.selectedIndex = 0;
			
			addElement(_titleList);
		}
		
		private function _titleInitializer(title:String):void
		{
			_title = new TextArea();
			_title.height = 28;//_TITLELIST_HEIGHT;
			_title.width = _TITLELIST_WIDTH;
			_title.editable = false;
			if(_url != null)
			{
				_title.textFlow = TextFlowUtil.importFromString('<a href="' + _url.url + '">' + title + '</a>');
				_title.buttonMode = true;
				_title.useHandCursor = true;
				_title.addEventListener(MouseEvent.CLICK, linkClickHandler);
			}
			else
				_title.text = title;
			
			addElement(_title);
		}
		
		private function changeHandler(ice:IndexChangeEvent):void
		{
			//_summary.text = ice.target.dataProvider.getItemAt(ice.newIndex).summary;
			//_link.label = ice.target.dataProvider.getItemAt(ice.newIndex).wikipediaUrl;
			_url.url = ice.target.dataProvider.getItemAt(ice.newIndex).wikipediaUrl;
			
			//QUI AGGIUNGERE StartTime ed EndTime per mantenere
			if(!dispatchEvent(new InfoWindowOptionsCustomContentEvent(InfoWindowOptionsCustomContentEvent.WIKIENTRY_CHANGE,
				this, _geoTagMarker,
				ice.target.selectedItem)))
				Alert.show("Something went wrong");
			
			//this.closeDrop();
		}
		
		private function valueCommitHandler(fe:FlexEvent):void
		{
			//_summary.text = fe.target.selectedItem.summary;
			//_link.label = fe.target.selectedItem.wikipediaUrl;
			_url.url = fe.target.selectedItem.wikipediaUrl;
			//this.closeDrop();
		}
		
		//		private function _summaryInitializer(summary:String=null):void
		//		{
		//			_summary = new TextArea();
		//			
		//			if(summary)
		//			{
		//				_summary.y = _title.height;
		//				_summary.text = summary;
		//			}
		//			else if(_results)
		//			{
		//				_summary.y = _titleList.height;
		//			}
		//			
		//			addElement(_summary);
		//		}
		
		private function _linkInitializer(link:String=null):void
		{
			_link = new Button();
			_url = new URLRequest();
			_url.url = link;
			_link.y = _TITLELIST_HEIGHT;
			_link.x = 0;
			_link.height = 20;
			_link.width = _TITLELIST_WIDTH;
			_link.label = "Go to Wikipedia article";
			
			
			
			_link.addEventListener(MouseEvent.CLICK, linkClickHandler);
			
			addElement(_link);
		}
		
		private function linkClickHandler(me:MouseEvent):void
		{
			navigateToURL(_url);
		}
		
		private function _startGeoTagInitializer():void
		{
			_startGeoTag = new Button();
			_startGeoTag.width = 50;
			_startGeoTag.height = 14;
			_startGeoTag.label = "Start";
			
			//			if(_results)
			//				_startGeoTag.x = _titleList.width;
			//			else
			//				_startGeoTag.x = _title.width;
			_startGeoTag.x = _TITLELIST_WIDTH;
			//_startGeoTag.y = _TITLELIST_HEIGHT;
			
			_startGeoTag.addEventListener(MouseEvent.CLICK, startGeoTagClickHandler);
			
			addElement(_startGeoTag);
		}
		
		private function _saveEditGeoTagInitializer():void
		{
			_saveEditGeoTag = new Button();
			_saveEditGeoTag.width = 85;
			_saveEditGeoTag.height = 20;
			_saveEditGeoTag.label = "Save";
			
			//			if(_isEditing)
			//				_saveEditGeoTag.x = _TITLELIST_WIDTH;
			_saveEditGeoTag.y = _TITLELIST_HEIGHT;
			_saveEditGeoTag.x = _TITLELIST_WIDTH;
			
			_saveEditGeoTag.addEventListener(MouseEvent.CLICK, saveEditGeoTagClickHandler);
			
			addElement(_saveEditGeoTag);
		}
		
		private function saveEditGeoTagClickHandler(me:MouseEvent):void
		{
			if(_dataGeoTag.StartTime != null && _dataGeoTag.EndTime != null && _dataGeoTag.StartTime < _dataGeoTag.EndTime)
			{
				if(_results)
				{
					_titleList.enabled = false;
					_dataGeoTag.title = _titleList.selectedItem.title;
					_dataGeoTag.summary = _titleList.selectedItem.summary;
					_dataGeoTag.wikipediaUrl = _titleList.selectedItem.wikipediaUrl;
					_dataGeoTag.lat = _titleList.selectedItem.lat;
					_dataGeoTag.lng = _titleList.selectedItem.lng;
				}
				
				if(!dispatchEvent(new InfoWindowOptionsCustomContentEvent(InfoWindowOptionsCustomContentEvent.GEOTAG_SAVEEDIT, this, _geoTagMarker, _dataGeoTag)))
					Alert.show("Something went wrong");
			}
			else
				Alert.show("Set GeoTag times!");
		}
		
		private function _editGeoTagInitializer():void
		{
			_editGeoTag = new Button();
			_editGeoTag.width = 60;
			_editGeoTag.height = 14;
			_editGeoTag.label = "Edit";
			
			if(!_isEditing && !_isCreating)
				_editGeoTag.x = _TITLELIST_WIDTH;
			
			_editGeoTag.addEventListener(MouseEvent.CLICK, editGeoTagClickHandler);
			
			addElement(_editGeoTag);
		}
		
		
		
		private function editGeoTagClickHandler(me:MouseEvent):void
		{
			if(!dispatchEvent(new InfoWindowOptionsCustomContentEvent(InfoWindowOptionsCustomContentEvent.EDIT_GEOTAG, this, _geoTagMarker, _dataGeoTag)))
				Alert.show("Something went wrong");
		}
		
		private function _endGeoTagInitializer():void
		{
			_endGeoTag = new Button();
			//_endGeoTag.enabled = false;
			_endGeoTag.width = 50;
			_endGeoTag.height = 14;
			_endGeoTag.label = "End";
			
			//			_endGeoTag.x = _startGeoTag.width;
			//			
			//			if(_results)
			//				_endGeoTag.x += _titleList.width;
			//			else
			//				_endGeoTag.x += _title.width;
			_endGeoTag.x = _TITLELIST_WIDTH;
			_endGeoTag.y = _startGeoTag.height;
			
			_endGeoTag.addEventListener(MouseEvent.CLICK, endGeoTagClickHandler);
			
			addElement(_endGeoTag);
		}
		
		private function _insertGeoTagInitializer():void
		{
			_insertGeoTag = new Button();
			//_endGeoTag.enabled = false;
			_insertGeoTag.width = 85; 
			_insertGeoTag.height = 20;
			_insertGeoTag.label = "Insert";
			
			_insertGeoTag.x = _link.width;
			_insertGeoTag.y = _TITLELIST_HEIGHT;
			
			//			if(_results)
			//				_insertGeoTag.x += _titleList.width;
			//			else
			//				_insertGeoTag.x += _title.width;
			
			_insertGeoTag.addEventListener(MouseEvent.CLICK, insertGeoTagClickHandler);
			
			addElement(_insertGeoTag);
		}
		
		private function insertGeoTagClickHandler(me:MouseEvent):void
		{
			if(_dataGeoTag.StartTime != null && _dataGeoTag.EndTime != null && _dataGeoTag.StartTime < _dataGeoTag.EndTime)
			{
				if(_results)
				{
					_titleList.enabled = false;
					_dataGeoTag.title = _titleList.selectedItem.title;
					_dataGeoTag.summary = _titleList.selectedItem.summary;
					_dataGeoTag.wikipediaUrl = _titleList.selectedItem.wikipediaUrl;
					_dataGeoTag.lat = _titleList.selectedItem.lat;
					_dataGeoTag.lng = _titleList.selectedItem.lng;
				}
				if(!dispatchEvent(new InfoWindowOptionsCustomContentEvent(InfoWindowOptionsCustomContentEvent.GEOTAG_INSERT, this, _geoTagMarker, _dataGeoTag)))
					Alert.show("Something went wrong");
			}
			else
				Alert.show("Insert GeoTag Times Correctly!");
		}
		
		private function _deleteGeoTagInitializer():void
		{
			_deleteGeoTag = new Button();
			_deleteGeoTag.enabled = true;
			_deleteGeoTag.width = 60;
			_deleteGeoTag.height = 14;
			_deleteGeoTag.label = "Delete";
			
			//IN INSERT DARA' ERRORE
			_deleteGeoTag.x = _title.width;
			_deleteGeoTag.y = _editGeoTag.height;
			
			//			if(!_isEditing && !_isCreating)
			//				_deleteGeoTag.x += _TITLELIST_WIDTH;
			
			_deleteGeoTag.addEventListener(MouseEvent.CLICK, deleteGeoTagClickHandler);
			
			addElement(_deleteGeoTag);
		}
		
		private function deleteGeoTagClickHandler(me:MouseEvent):void
		{
			if(_isEditing)
			{
				if(!dispatchEvent(new InfoWindowOptionsCustomContentEvent(InfoWindowOptionsCustomContentEvent.DELETE_GEOTAG_FROM_EDIT, this, _geoTagMarker, _dataGeoTag)))
					Alert.show("Something went wrong");
			}
			else if(!_isCreating && !_isEditing)
			{
				if(!dispatchEvent(new InfoWindowOptionsCustomContentEvent(InfoWindowOptionsCustomContentEvent.DELETE_GEOTAG_FROM_SAVED, this, _geoTagMarker, _dataGeoTag)))
					Alert.show("Something went wrong");
			}
		}
		
		private function startGeoTagClickHandler(me:MouseEvent):void
		{
			//			_startGeoTag.enabled = false;
			//			if(_titleList)
			//				_titleList.enabled = false;
			//			_endGeoTag.enabled = true;
			if(!dispatchEvent(new InfoWindowOptionsCustomContentEvent(InfoWindowOptionsCustomContentEvent.GEOTAG_START, this, _geoTagMarker)))
				Alert.show("Something went wrong");
		}
		
		private function endGeoTagClickHandler(me:MouseEvent):void
		{
			//			if(_results)
			//			{
			//				_titleList.enabled = false;
			//				_dataGeoTag.title = _titleList.selectedItem.title;
			//				_dataGeoTag.summary = _titleList.selectedItem.summary;
			//				_dataGeoTag.wikipediaUrl = _titleList.selectedItem.wikipediaUrl;
			//				_dataGeoTag.lat = _titleList.selectedItem.lat;
			//				_dataGeoTag.lng = _titleList.selectedItem.lng;
			//			}
			
			if(!dispatchEvent(new InfoWindowOptionsCustomContentEvent(InfoWindowOptionsCustomContentEvent.GEOTAG_END, this, _geoTagMarker, _dataGeoTag)))
				Alert.show("Something went wrong");
		}
	}
}