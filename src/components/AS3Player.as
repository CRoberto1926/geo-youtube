/*
Copyright 2009 Google Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package components {
	import events.AS3PlayerEvent;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.Timer;
	
	import mx.controls.Alert;
	import mx.controls.SWFLoader;
	
	import spark.components.Group;
	
	public class AS3Player extends Group {
		
		private var _isQualityPopulated:Boolean;
		private var _isWidescreen:Boolean;
		private var _player:Object;
		private var _playerLoader:SWFLoader;
		private var _youtubeApiLoader:URLLoader;
		private var _videoId:String;
		private var _timerStart:Timer;
		private var _timerEnd:Timer;
		private var _geoTagTimes:Array;
		
		private const _PLAYER_URL_PREFIX:String = "http://www.youtube.com/v/";
		private const _PLAYER_URL_SUFFIX:String = "?version=3&rel=0";
		private const YOUTUBE_API_PREFIX:String = "http://gdata.youtube.com/feeds/api/videos/";
		private const YOUTUBE_API_VERSION:String = "2";
		private const YOUTUBE_API_FORMAT:String = "5";
		private const WIDESCREEN_ASPECT_RATIO:String = "widescreen";
		private const TIMER_DELAY:int = 50;
		
		private const UNSTARTED:int = -1;
		private const ENDED:int = 0;
		private const PLAYING:int = 1;
		private const PAUSED:int = 2;
		private const BUFFERING:int = 3;
		private const VIDEO_CUED:int = 5;
		
		public function AS3Player(videoId:String):void
		{
			super();
			
			_videoId = videoId;
			_geoTagTimes = new Array();
			_timerStart = new Timer(TIMER_DELAY);
			_timerEnd = new Timer(TIMER_DELAY);
			_timerStart.addEventListener(TimerEvent.TIMER, timerStartHandler);
			_timerEnd.addEventListener(TimerEvent.TIMER, timerEndHandler);
			setupPlayerLoader();
			setupYouTubeApiLoader();
		}
		
		public function set videoId(value:String):void
		{
			if(_player)
			{
				_videoId = value;
				_player.loadVideoById(_videoId);
				_player.pauseVideo();
				_player.seekTo(0, false);
			}
			else
				Alert.show("Player is not ready! set videoId.");
		}
		
		public function addGeoTagTime(startTime:Number, endTime:Number, id:int):void
		{
			var geoTagTime:Object = new Object();
			geoTagTime.startTime = startTime;
			geoTagTime.endTime = endTime;
			geoTagTime.id = id;
			_geoTagTimes.push(geoTagTime);
		}
		
		public function removeGeoTagTime(id:int):void
		{
			var i:int = 0;
			for(i=0;i<_geoTagTimes.length;i++)
			{
				if(_geoTagTimes[i].id == id)
				{
					_geoTagTimes.splice(i, 1);
					break;
				}
			}
		}
		
		public function clearGeoTagTimes():void
		{
			_geoTagTimes = new Array();
		}
		
		public function get videoId():String
		{
			return _videoId;
		}
		
		override public function set width(value:Number):void
		{
			super.width = value;
			if(_player)
				_player.setSize(value, this.height);
			else
				Alert.show("Player is not ready! set width");
		}
		
		override public function set height(value:Number):void
		{
			super.height = value;
			if(_player)
				_player.setSize(this.width, value);
			else
				Alert.show("Player is not ready! set height");
		}
		
		public function playVideo():void
		{
			if(_player)
				_player.playVideo();
			else
				Alert.show("Player is not ready! playVideo");
		}
		
		public function pauseVideo():void
		{
			if(_player)
				_player.pauseVideo();
			else
				Alert.show("Player is not ready! pauseVideo");
		}
		
		public function getCurrentTime():Number
		{
			if(_player)
				return _player.getCurrentTime();
			else
				return -1;
		}
		
		public function seekTo(seconds:Number, allowSeekAhead:Boolean):void
		{
			if(_player)
				_player.seekTo(seconds, allowSeekAhead);
			else
				Alert.show("Player is not ready! seekTo");
		}
		
		private function setupPlayerLoader():void
		{
			_playerLoader = new SWFLoader();
			_playerLoader.addEventListener(Event.INIT, playerLoaderInitHandler);
			_playerLoader.load(_PLAYER_URL_PREFIX + _videoId + _PLAYER_URL_SUFFIX);
		}
		
		private function playerLoaderInitHandler(event:Event):void
		{
			addElement(_playerLoader);
			_playerLoader.content.addEventListener("onReady", onPlayerReady);
			_playerLoader.content.addEventListener("onError", onPlayerError);
		}
		
		private function setupYouTubeApiLoader():void
		{
			_youtubeApiLoader = new URLLoader();
			_youtubeApiLoader.addEventListener(IOErrorEvent.IO_ERROR, youtubeApiLoaderErrorHandler);
			_youtubeApiLoader.addEventListener(Event.COMPLETE, youtubeApiLoaderCompleteHandler);
		}
		
		private function youtubeApiLoaderCompleteHandler(event:Event):void //CHECK THIS FUNCTION, MAYBE IT DOES SOMETHING USELESS
		{
			var atomData:String = _youtubeApiLoader.data;
			
			// Parse the YouTube API XML response and get the value of the
			// aspectRatio element.
			var atomXml:XML = new XML(atomData);
			var aspectRatios:XMLList = atomXml..*::aspectRatio;
			
			_isWidescreen = aspectRatios.toString() == WIDESCREEN_ASPECT_RATIO;
			
			_isQualityPopulated = false;
			// Cue up the video once we know whether it's widescreen.
			
			if(!dispatchEvent(new AS3PlayerEvent(AS3PlayerEvent.PLAYER_READY)))
				Alert.show("Something went wrong");
			
			_player.loadVideoById(_videoId);
			_player.pauseVideo();
			_player.seekTo(0, false)
		}
		
		private function youtubeApiLoaderErrorHandler(event:IOErrorEvent):void
		{
			Alert.show("Error making YouTube API request:", event.toString());
		}
		
		private function onPlayerReady(event:Event):void
		{
			_player = _playerLoader.content;
			_player.addEventListener("onStateChange", stateChangeHandler);
			
			var request:URLRequest = new URLRequest(YOUTUBE_API_PREFIX + _videoId);
			
			var urlVariables:URLVariables = new URLVariables();
			urlVariables.v = YOUTUBE_API_VERSION;
			urlVariables.format = YOUTUBE_API_FORMAT;
			request.data = urlVariables;
			
			try
			{
				_youtubeApiLoader.load(request);
			}
			catch(error:SecurityError)
			{
				Alert.show("A SecurityError occurred while loading", request.url);
			}
		}
		
		private function timerStartHandler(te:TimerEvent):void
		{
			var videoTime:Number = this.getCurrentTime();
			
			var i:int = 0;
			for(i=0;i<_geoTagTimes.length;i++)
			{
				if((_geoTagTimes[i].startTime >= videoTime-0.13) && (_geoTagTimes[i].startTime < videoTime+0.13))
				{
					if(!dispatchEvent(new AS3PlayerEvent(AS3PlayerEvent.CUEPOINT_START_REACHED, _geoTagTimes[i].id)))
						Alert.show("Something went wrong");
				}
			}
		}
		
		private function timerEndHandler(te:TimerEvent):void
		{
			var videoTime:Number = this.getCurrentTime();
			
			var i:int = 0;
			for(i=0;i<_geoTagTimes.length;i++)
			{
				if((_geoTagTimes[i].endTime >= videoTime-0.13) && (_geoTagTimes[i].endTime < videoTime+0.13))
				{
					if(!dispatchEvent(new AS3PlayerEvent(AS3PlayerEvent.CUEPOINT_END_REACHED, _geoTagTimes[i].id)))
						Alert.show("Something went wrong");
				}
			}
		}
		
		private function stateChangeHandler(event:Event):void
		{
			switch(event.target.getPlayerState())
			{
				case UNSTARTED:
					if(_timerStart.running)
						_timerStart.stop();
					
					if(_timerEnd.running)
						_timerEnd.stop();
					break;
				
				case ENDED:
					if(_timerStart.running)
						_timerStart.stop();
					
					if(_timerEnd.running)
						_timerEnd.stop();
					break;
				
				case PLAYING:
					if(!_timerStart.running)
						_timerStart.start();
					
					if(!_timerEnd.running)
						_timerEnd.start();
					break;
				
				case PAUSED:
					if(_timerStart.running)
						_timerStart.stop();
					
					if(_timerEnd.running)
						_timerEnd.stop();
					break;
				
				case BUFFERING:
					if(!_timerStart.running)
						_timerStart.start();
					
					if(!_timerEnd.running)
						_timerEnd.start();
					break;
				
				case VIDEO_CUED:
					if(_timerStart.running)
						_timerStart.stop();
					
					if(_timerEnd.running)
						_timerEnd.stop();
					break;
			}
		}
		
		private function onPlayerError(event:Event):void
		{
			Alert.show("Player error:", Object(event).data);
		}
	}
}