﻿//  This file is part of the official Playtomic API for ActionScript 3 games.  //  Playtomic is a real time analytics platform for casual games //  and services that go in casual games.  If you haven't used it //  before check it out://  http://playtomic.com/////  Created by ben at the above domain on 2/25/11.//  Copyright 2011 Playtomic LLC. All rights reserved.////  Documentation is available at://  http://playtomic.com/api/as3//// PLEASE NOTE:// You may modify this SDK if you wish but be kind to our servers.  Be// careful about modifying the analytics stuff as it may give you // borked reports.//// If you make any awesome improvements feel free to let us know!//// -------------------------------------------------------------------------// THIS SOFTWARE IS PROVIDED BY PLAYTOMIC, LLC "AS IS" AND ANY// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.package Playtomic{	import flash.events.IOErrorEvent;	import flash.events.HTTPStatusEvent;	import flash.events.SecurityErrorEvent;	import flash.events.Event;	import flash.net.URLRequest;	import flash.net.URLLoader;	public final class GameVars	{		public function GameVars() { } 		public static function Load(callback:Function):void		{			var bridge:Function = function()			{				if(callback == null)					return;				var data:XML = XML(sendaction["data"]);				var status:int = parseInt(data["status"]);				var errorcode:int = parseInt(data["errorcode"]);								if(status == 1)				{									var entries:XMLList = data["gamevar"];					var name:String;					var value:String;						for each(var item:XML in entries) 					{						name = item["name"];						value = item["value"];												result[name] = value;					}				}								callback(result, {Success: status == 1, ErrorCode: errorcode});			}			var httpstatusignore:Function = function():void			{							}						var fail:Function = function()			{				callback(result, {Success: false, ErrorCode: 1});			}			var result:Object = [];						var sendaction:URLLoader = new URLLoader();			sendaction.addEventListener(Event.COMPLETE, bridge);			sendaction.addEventListener(IOErrorEvent.IO_ERROR, fail);			sendaction.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpstatusignore);			sendaction.addEventListener(SecurityErrorEvent.SECURITY_ERROR, fail);			sendaction.load(new URLRequest("http://g" + Log.GUID + ".api.playtomic.com/gamevars/load.aspx?swfid=" + Log.SWFID + "&" + Math.random()));		}		}}