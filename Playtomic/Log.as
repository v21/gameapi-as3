﻿//  This file is part of the official Playtomic API for ActionScript 3 games.  //  Playtomic is a real time analytics platform for casual games //  and services that go in casual games.  If you haven't used it //  before check it out://  http://playtomic.com/////  Created by ben at the above domain on 2/25/11.//  Copyright 2011 Playtomic LLC. All rights reserved.////  Documentation is available at://  http://playtomic.com/api/as3//// PLEASE NOTE:// You may modify this SDK if you wish but be kind to our servers.  Be// careful about modifying the analytics stuff as it may give you // borked reports.//// If you make any awesome improvements feel free to let us know!//// -------------------------------------------------------------------------// THIS SOFTWARE IS PROVIDED BY PLAYTOMIC, LLC "AS IS" AND ANY// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.package Playtomic{	import flash.events.TimerEvent;	import flash.external.ExternalInterface;	import flash.net.SharedObject;	import flash.system.Capabilities;	import flash.system.Security;	import flash.utils.Timer;	public final class Log	{		// API settings		private static var Enabled:Boolean = false;		private static var Queue:Boolean = true;				// SWF settings		internal static var SWFID:int = 0;		internal static var GUID:String = "";		internal static var SourceUrl:String;		internal static var BaseUrl:String;			// play timer, goal tracking etc		private static var Cookie:SharedObject;		internal static var LogQueue:LogRequest;		private static const PingF:Timer = new Timer(1000);		private static var Pings:int = 0;		private static var Plays:int = 0;					private static var Frozen:Boolean = false;		private static var FrozenQueue:Array = new Array();		// unique, logged metrics		private static var Customs:Array = new Array();		private static var LevelCounters:Array = new Array();		private static var LevelAverages:Array = new Array();		private static var LevelRangeds:Array = new Array();				// parameterized events		public static var PEventsEnabled:Boolean = false;		private static var PData:Object;		public static var PersistantParams:Object;		private static var PTime:int = 0;		/**		 * Logs a view and initializes the API.  You must do this first before anything else!		 * @param	swfid		Your game id from the Playtomic dashboard		 * @param	guid		Your game guid from the Playtomic dashboard		 * @param	apikey		Your secret API key from the Playtomic dashboard		 * @param	defaulturl	Should be root.loaderInfo.loaderURL or some other default url value to be used if we can't detect the page		 */		public static function View(swfid:int = 0, guid:String = "", apikey:String = "", defaulturl:String = ""):void		{			if(SWFID > 0)				return;			SWFID = swfid;			GUID = guid;			Enabled = true;			if((SWFID == 0 || GUID == ""))			{				Enabled = false;				return;			}			SourceUrl = GetUrl(defaulturl);			if(SourceUrl == null || SourceUrl == "")			{				Enabled = false;				return;			}						BaseUrl = SourceUrl.split("://")[1];			BaseUrl = BaseUrl.substring(0, BaseUrl.indexOf("/"));			Parse.Initialise(apikey);			GeoIP.Initialise(apikey);			Data.Initialise(apikey);			Leaderboards.Initialise(apikey);			GameVars.Initialise(apikey);			PlayerLevels.Initialise(apikey);			Request.Initialise();							LogQueue = LogRequest.Create();			Cookie = SharedObject.getLocal("playtomic");						// Load the security context			Security.loadPolicyFile("http://g" + guid + ".api.playtomic.com/crossdomain.xml");									// Check the URL is http					if(defaulturl.indexOf("http://") != 0 && Security.sandboxType != "localWithNetwork" && Security.sandboxType != "localTrusted")			{				Enabled = false;				return;			}						// Log the view (first or repeat visitor)			var views:int = GetCookie("views");			Send("v/" + (views + 1), true);			// Start the play timer			PingF.addEventListener(TimerEvent.TIMER, PingServer);			PingF.start();						// PEvents			if(!PEventsEnabled)				return;			PData = {};			PData.session = GetSession();			PData.source = BaseUrl;			PData.views = views + 1;			PData.time = 0;			PData.eventnum = 0;			PData.location = "initialize";			PData.api = "flash";			PData.apiversion = "3.5";			PData.params = {};			PData.params.cpu = Capabilities.cpuArchitecture;			PData.params.language = Capabilities.language;			PData.params.os = Capabilities.os;			PData.params.osversion = Capabilities.version;			PData.params.manufacturer = Capabilities.manufacturer;			PData.params.touchscreentype = Capabilities.touchscreenType			PData.params.screenresolution = Capabilities.screenResolutionX + "x" + Capabilities.screenResolutionY;			PData.params.screendpi = Capabilities.screenDPI;						PersistantParams = {};						SendPEvent();		}				/**		 * Gets or generates the player's session id		 */		private static function GetSession():String		{			if(Cookie.data["session"] != undefined)			{				return Cookie.data["session"];			}						return Encode.MD5(SessionID.Create() + SessionID.Create());					}				/**		 * Logs an event with parameters		 * @param	location	The player's current location (eg main menu, level 1)		 * @param	params		Any parameters you wish to include with the event such as gender, how they found your game, etc		 */		public static function PEvent(location:String, params:Object):void		{			PData.timebefore = PData.time;			PData.locationbefore = PData.location;			PData.time = PTime;			PData.location = location;			PData.eventnum++;			PData.params = params;			SendPEvent();		}				/**		 * Merges persistant parameters with event parameters and sends		 */		private static function SendPEvent():void		{			for(var x:String in PersistantParams)				PData.params[x] = PersistantParams[x];						var empty:Boolean = true;			for (var n:String in PData.params) 			{ 				empty = false; 				break; 			}						if(empty)			{				PData.params = null;			}						Request.SendPEvent(PData);		}				/**		 * Increases the number of views successfully logged 		 */		internal static function IncreaseViews():void		{			var views:int = GetCookie("views");			views++;			SaveCookie("views", views);		}				/**		 * Increases the number of plays successfully logged 		 */		internal static function IncreasePlays():void		{			Plays++;		}		/**		 * Logs a play.  Call this when the user begins an actual game (eg clicks play button)		 */		public static function Play():void		{									if(!Enabled)				return;			LevelCounters = new Array();			LevelAverages = new Array();			LevelRangeds = new Array();							Send("p/" + (Plays + 1), true);		}		/**		 * Increases the play time and triggers events being sent		 */		private static function PingServer(e:TimerEvent):void		{								if(!Enabled)				return;						PTime++;						if(PTime == 60)			{				Pings = 1;				Send("t/" + (PTime == 60 ? "y" : "n") + "/" + Pings, true);			}			else if(PTime > 60 && PTime % 30 == 0)			{				Pings++;				Send("t/n/" + Pings, true);							}		}				/**		 * Logs a custom metric which can be used to track how many times something happens in your game.		 * @param	name		The metric name		 * @param	group		Optional group used in reports		 * @param	unique		Only count a metric one single time per view		 */		public static function CustomMetric(name:String, group:String = null, unique:Boolean = false):void		{					if(!Enabled)				return;			if(group == null)				group = "";			if(unique)			{				if(Customs.indexOf(name) > -1)					return;				Customs.push(name);			}						Send("c/" + Clean(name) + "/" + Clean(group));		}		/**		 * Logs a level counter metric which can be used to track how many times something occurs in levels in your game.		 * @param	name		The metric name		 * @param	level		The level number as an integer or name as a string		 * @param	unique		Only count a metric one single time per play		 */		public static function LevelCounterMetric(name:String, level:*, unique:Boolean = false):void		{					if(!Enabled)				return;			if(unique)			{				var key:String = name + "." + String(level);								if(LevelCounters.indexOf(key) > -1)					return;				LevelCounters.push(key);			}						Send("lc/" + Clean(name) + "/" + Clean(level));		}				/**		 * Logs a level ranged metric which can be used to track how many times a certain value is achieved in levels in your game.		 * @param	name		The metric name		 * @param	level		The level number as an integer or name as a string		 * @param	value		The value being tracked		 * @param	unique		Only count a metric one single time per play		 */		public static function LevelRangedMetric(name:String, level:*, value:int, unique:Boolean = false):void		{						if(!Enabled)				return;			if(unique)			{				var key:String = name + "." + String(level);								if(LevelRangeds.indexOf(key) > -1)					return;				LevelRangeds.push(key);			}						Send("lr/" + Clean(name) + "/" + Clean(level) + "/" + value);		}		/**		 * Logs a level average metric which can be used to track the min, max, average and total values for an event.		 * @param	name		The metric name		 * @param	level		The level number as an integer or name as a string		 * @param	value		The value being added		 * @param	unique		Only count a metric one single time per play		 */		public static function LevelAverageMetric(name:String, level:*, value:int, unique:Boolean = false):void		{			if(!Enabled)				return;			if(unique)			{				var key:String = name + "." + String(level);								if(LevelAverages.indexOf(key) > -1)					return;				LevelAverages.push(key);			}						Send("la/" + Clean(name) + "/" + Clean(level) + "/" + value);		}		/**		 * Logs the link results, internal use only.  The correct use is Link.Open(...)		 * @param	url		The url that was opened		 * @param	name	The name for the url		 * @param	group	The group for the url 		 * @param	unique	Increase uniques by this value		 * @param	total	Increase totals by this value		 * @param	fail	Increase fails by this value		 */		internal static function Link(url:String, name:String, group:String, unique:int, total:int, fail:int):void		{			if(!Enabled)				return;						Send("l/" + Clean(name) + "/" + Clean(group) + "/" + Clean(url) + "/" + unique + "/" + total + "/" + fail);		}		/**		 * Logs a heatmap which allows you to visualize where some event occurs.		 * @param	metric		The metric you are tracking (eg clicks)		 * @param	heatmap		The heatmap (the one you upload images for)		 * @param	x			The x coordinate		 * @param	y			The y coordinate		 */		public static function Heatmap(metric:String, heatmap:String, x:int, y:int):void		{			if(!Enabled)				return;						Send("h/" + Clean(metric) + "/" + Clean(heatmap) + "/" + x + "/" + y);		}		/**		 * Not yet implemented :(		 */		internal static function Funnel(name:String, step:String, stepnum:int):void		{			if(!Enabled)				return;						Send("f/" + Clean(name) + "/" + Clean(step) + "/" + stepnum);		}		/**		 * Logs a start of a player level, internal use only.  The correct use is PlayerLevels.LogStart(...);		 * @param	levelid		The player level id		 */		internal static function PlayerLevelStart(levelid:String):void		{			if(!Enabled)				return;						Send("pls/" + levelid);		}		/**		 * Logs a win on a player level, internal use only.  The correct use is PlayerLevels.LogWin(...);		 * @param	levelid		The player level id		 */		internal static function PlayerLevelWin(levelid:String):void		{			if(!Enabled)				return;						Send("plw/" + levelid);		}		/**		 * Logs a quit on a player level, internal use only.  The correct use is PlayerLevels.LogQuit(...);		 * @param	levelid		The player level id		 */		internal static function PlayerLevelQuit(levelid:String):void		{			if(!Enabled)				return;						Send("plq/" + levelid);		}				/**		 * Logs a flag on a player level, internal use only.  The correct use is PlayerLevels.Flag(...);		 * @param	levelid		The player level id		 */		internal static function PlayerLevelFlag(levelid:String):void		{			if(!Enabled)				return;						Send("plf/" + levelid);		}				/**		 * Logs a retry on a player level, internal use only.  The correct use is PlayerLevels.LogRetry(...);		 * @param	levelid		The player level id		 */		internal static function PlayerLevelRetry(levelid:String):void		{			if(!Enabled)				return;						Send("plr/" + levelid);		}				/**		 * Freezes the API so analytics events are queued but not sent		 */		public static function Freeze():void		{			Frozen = true;		}		/**		 * Unfreezes the API and sends any queued events		 */		public static function UnFreeze():void		{			if(!Enabled)				return;						Frozen = false;			LogQueue.MassQueue(FrozenQueue);		}		/**		 * Forces the API to send any unsent data now		 */		public static function ForceSend():void		{			if(!Enabled)			  	return;						if(LogQueue == null)			  	LogQueue = LogRequest.Create();			LogQueue.Send();			LogQueue = LogRequest.Create();						if(FrozenQueue.length > 0)				LogQueue.MassQueue(FrozenQueue);		}				/**		 * Adds an event and if ready or a view or not queuing, sends it		 * @param	s	The event as an ev/xx string		 * @param	view	If it's a view or not		 */		private static function Send(s:String, view:Boolean = false):void		{			if(Frozen)			{				FrozenQueue.push(s);				return;			}						LogQueue.Queue(s);			if(LogQueue.ready || view || !Queue)			{				LogQueue.Send();				LogQueue = LogRequest.Create();			}		}				/**		 * Cleans a piece of text of reserved characters		 * @param	s	The string to be cleaned		 */		private static function Clean(s:String):String		{			while(s.indexOf("/") > -1)				s = s.replace("/", "\\");							while(s.indexOf("~") > -1)				s = s.replace("~", "-");											return escape(s);		}			/**		 * Gets a cookie value		 * @param	n	The key (views, plays)		 */		private static function GetCookie(n:String):int		{			if(Cookie.data[n] == undefined)			{				return 0;			}			else			{				return int(Cookie.data[n]);			}		}				/**		 * Saves a cookie value		 * @param	n	The key (views, plays)		 * @param	v	The value		 */		private static function SaveCookie(n:String, v:int):void		{			Cookie.data[n] = v.toString();						try			{				Cookie.flush();			}			catch(s:Error)			{						}		}			/**		 * Attempts to detect the page url		 * @param	defaulturl		The fallback url if page cannot be detected		 */		private static function GetUrl(defaulturl:String):String		{			var url:String;						if(ExternalInterface.available)			{				try				{					url = String(ExternalInterface.call("window.location.href.toString"));				}				catch(s:Error)				{					url = defaulturl;				}			}			else if(defaulturl.indexOf("http://") == 0 || defaulturl.indexOf("https://") == 0)			{				url = defaulturl;			}			if(url == null  || url == "" || url == "null")			{				url = "http://localhost/";			}						if(url.indexOf("http://") != 0)				url = "http://localhost/";			return url;		}	}}