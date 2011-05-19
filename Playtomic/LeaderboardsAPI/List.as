﻿package LeaderBoardsAPI{
	public class List extends main{
		
		public var global:Boolean = true;
		public var mode:String = "alltime";
		public var customfilters:Object = {};
		public var page:int = 1;
		public var perpage:int = 20;
		public var highest:Boolean = true;
		
		override public function start():void{
			_global = global;
			_mode = mode;
			_customfilters = customfilters;
			_page = page;
			_perpage = perpage;
			_highest = highest;
			
			super.start();
		}
		
		
		override protected function setURLRequest():void{
			request = new URLRequest("http://g" + Log.GUID +".api.playtomic.com/leaderboards/list.aspx?swfid=" + Log.SWFID + "&url=" + (global || Log.SourceUrl == null ? "global" : Log.SourceUrl) + "&r=" + Math.random());
		}
		override protected function updatePostData():void{
			updateListPostData();
		}
		override protected function failCallback():void{
			callback([], 0, {Success: false, ErrorCode: 1});
		}
		override protected function successCallback(){
			//callback signature: callback(scores:Array, numscores:int, response:Object):void
			callback(rData.results, rData.numscores, {Success: rData.status == 1, ErrorCode: rData.errorcode})
		}
		
	}
}