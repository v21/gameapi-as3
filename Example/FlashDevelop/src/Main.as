package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import Playtomic.*;
	/**
	 * ...
	 * @author sbg
	 */
	public class Main extends Sprite 
	{
		private var SWFID:int = 4450;
		private var GUID:String = "6fa1ab9f2e044103";
		private var API_Key:String = "c865e220722f476e9e8e060f7fdd1a";
		
		public static var instance:Main;
		
		public function Main():void 
		{
			instance = this;
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			Log.View(SWFID, GUID, API_Key, root.loaderInfo.loaderURL);
			TestAnalytics.test();
			TestLinkTracking.test();
			TestLevelSharing.test();
		}
		
	}
	
}