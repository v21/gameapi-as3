﻿//  Parse.com bridge for Playtomic Flash users// -------------------------------------------------------------------------//  Note:  This requires a Playtomic.com account AND a Parse.com account,//  you will have to register at Parse and configure the settings in your//  Playtomic dashboard.////  http://parse.com/////  If you are using Objective C or Android you should use the official//  Parse SDKs available directly through Parse.com.////// -------------------------------------------------------------------------//  This file is part of the official Playtomic API for ActionScript 3 games.  //  Playtomic is a real time analytics platform for casual games //  and services that go in casual games.  If you haven't used it //  before check it out://  http://playtomic.com/////  Created by ben at the above domain on 2/25/11.//  Copyright 2011 Playtomic LLC. All rights reserved.////  Documentation is available at://  http://playtomic.com/api/as3//// PLEASE NOTE:// You may modify this SDK if you wish but be kind to our servers.  Be// careful about modifying the analytics stuff as it may give you // borked reports.//// If you make any awesome improvements feel free to let us know!//// -------------------------------------------------------------------------// THIS SOFTWARE IS PROVIDED BY PLAYTOMIC, LLC "AS IS" AND ANY// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.package Playtomic{	import flash.utils.ByteArray;		public final class Parse 	{		private static var SECTION:String;		private static var SAVE:String;		private static var DELETE:String;		private static var LOAD:String;		private static var FIND:String;				internal static function Initialise(apikey:String):void		{			SECTION = Encode.MD5("parse-" + apikey);			SAVE = Encode.MD5("parse-save-" + apikey);			DELETE = Encode.MD5("parse-delete-" + apikey);			LOAD = Encode.MD5("parse-load-" + apikey);			FIND = Encode.MD5("parse-find-" + apikey);		}						/**		 * Creates or updates an object in your Parse.com database		 * @param	pobject		A ParseObject, if it has an objectId it will update otherwise save		 * @param	callback	Callback function to receive the data:  function(pobject:ParseObject, response:Response)		 */		public static function Save(pobject:ParseObject, callback:Function = null):void		{			Request.Load(SECTION, SAVE, SaveComplete, callback, ObjectPostData(pobject));		}				/**		 * Processes the response received from the server, returns the data and response to the user's callback		 * @param	callback	The user's callback function		 * @param	postdata	The data that was posted		 * @param	data		The XML returned from the server		 * @param	response	The response from the server		 */		private static function SaveComplete(callback:Function, postdata:Object, data:XML = null, response:Response = null):void		{			if(callback == null)				return;							var pobject:ParseObject = new ParseObject();			pobject.objectId = postdata["id"];			pobject.className = postdata["classname"];			pobject.password = postdata["password"];									for(var key:String in postdata)			{				if(key.indexOf("data") == 0)				{										pobject.data[key.substring(4)] = postdata[key];				}								if(key.indexOf("pointer") == 0 && key.indexOf("fieldname") > -1)				{					var s:String = key.substring(7);					s = s.substring(0, s.indexOf("fieldname"));										var fieldname:String = postdata["pointer" + s + "fieldname"];					var pointerobj:ParseObject = new ParseObject();					pointerobj.className = postdata["pointer" + s + "classname"];					pointerobj.objectId = postdata["pointer" + s + "id"];										pobject.pointers.push(new ParsePointer(fieldname, pointerobj));				}			}						if(response.Success)			{				var object:XMLList = data["object"];				pobject.createdAt = DateParse(object["created"]);				pobject.updatedAt = DateParse(object["updated"]);			}						callback(pobject, response);		}				/**		 * Deletes an object in your Parse.com database		 * @param	pobject		A ParseObject that must include the ObjectId		 * @param	callback	Callback function to receive the data:  function(response:Response)		 */		public static function Delete(pobject:ParseObject, callback:Function = null):void		{			Request.Load(SECTION, DELETE, DeleteComplete, callback, ObjectPostData(pobject));		}				/**		 * Processes the response received from the server, returns the data and response to the user's callback		 * @param	callback	The user's callback function		 * @param	postdata	The data that was posted		 * @param	data		The XML returned from the server		 * @param	response	The response from the server		 */		private static function DeleteComplete(callback:Function, data:XML = null, response:Response = null):void		{			if(callback == null)				return;			callback(response);			data = data; // just to hide unused var warning		}				/**		 * Loads a specific object from your Parse.com database		 * @param	pobject		A ParseObject that must include the ObjectId and className		 * @param	callback	Callback function to receive the data:  function(pobject:ParseObject, response:Response)		 */		public static function Load(pobjectid:String, classname:String, callback:Function = null):void		{			var pobject:ParseObject = new ParseObject();			pobject.objectId = pobjectid;			pobject.className = classname;						Request.Load(SECTION, LOAD, LoadComplete, callback, ObjectPostData(pobject));		}				/**		 * Processes the response received from the server, returns the data and response to the user's callback		 * @param	callback	The user's callback function		 * @param	postdata	The data that was posted		 * @param	data		The XML returned from the server		 * @param	response	The response from the server		 */		private static function LoadComplete(callback:Function, postdata:Object, data:XML = null, response:Response = null):void		{			if(callback == null)				return;							var pobject:ParseObject = new ParseObject();			pobject.objectId = postdata["objectid"];			pobject.className = postdata["classname"];							if(response.Success)			{				var object:XMLList = data["object"];				pobject.createdAt = DateParse(object["created"]);				pobject.updatedAt = DateParse(object["updated"]);								if(object.contains("fields"))				{					var fields:XMLList = object["fields"];										for each(var field:XML in fields.children())					{						pobject[field.name] = field.text();					}				}								if(object.contains("pointers"))				{					var pointers:XMLList = object["pointers"];										for each(var pointer:XML in pointers.children())					{						var pfieldname:String = pointer["fieldname"];												var pchild:ParseObject = new ParseObject();						pchild.className = pointer["classname"];						pchild.objectId = pointer["id"];												pobject.pointers.push(new ParsePointer(pfieldname, pchild));					}				}			}						callback(pobject, response);		}				/**		 * Finds objects matching the criteria in your ParseQuery		 * @param	pquery		A ParseQuery object		 * @param	callback	Callback function to receive the data:  function(objects:Array, response:Response)		 */		public static function Find(pquery:ParseQuery, callback:Function = null):void		{			var rawdata:String = "classname=" + pquery.className + "&limit=" + pquery.limit + "&order=" + (pquery.order != null ? pquery.order : "created_at");			var key:String;						for(key in pquery.wheredata)				rawdata += "&data" + key + "=" + escape(pquery.wheredata[key]);							for(var i:int=pquery.wherepointers.length-1; i>-1; i--)			{				rawdata += "&pointer" + i + "fieldname=" + escape(pquery.wherepointers[i].fieldName);				rawdata += "&pointer" + i + "classname=" + escape(pquery.wherepointers[i].pobject.className);				rawdata += "&pointer" + i + "id=" + escape(pquery.wherepointers[i].pobject.objectId);			}			var rawbytes:ByteArray = new ByteArray();			rawbytes.writeUTFBytes(rawdata);			rawbytes.position = 0;						var postdata:Object = new Object();			postdata["data"] = Encode.Base64(rawbytes);						Request.Load(SECTION, FIND, FindComplete, callback, postdata);		}				/**		 * Processes the response received from the server, returns the data and response to the user's callback		 * @param	callback	The user's callback function		 * @param	postdata	The data that was posted		 * @param	data		The XML returned from the server		 * @param	response	The response from the server		 */		private static function FindComplete(callback:Function, postdata:Object, data:XML = null, response:Response = null):void		{			if(callback == null)				return;							var objs:Array = new Array();						if(response.Success)			{				var objects:XMLList = data["objects"];								for each(var object:XML in objects.children())				{									var pobject:ParseObject = new ParseObject();					pobject.objectId = object["id"];					pobject.createdAt = DateParse(object["created"]);					pobject.updatedAt = DateParse(object["updated"]);										if(object.contains("fields"))					{						var fields:XMLList = object["fields"];												for each(var field:XML in fields.children())						{							pobject[field.name] = field.text();						}					}										if(object.contains("pointers"))					{						var pointers:XMLList = object["pointers"];												for each(var pointer:XML in pointers.children())						{							var pfieldname:String = pointer["fieldname"];														var pchild:ParseObject = new ParseObject();							pchild.className = pointer["classname"];							pchild.objectId = pointer["id"];														pobject.pointers.push(new ParsePointer(pfieldname, pchild));						}					}										objs.push(pobject);				}			}						callback(objs, response);			postdata = postdata;		}					/**		 * Turns a ParseObject into data to be POST'd for saving, finding 		 * @param	pobject		The ParseObject		 */			private static function ObjectPostData(pobject:ParseObject):Object		{			var postobject:Object = new Object();			postobject["classname"] = pobject.className;			postobject["id"] = (pobject.objectId == null ? "" : pobject.objectId);			postobject["password"] = (pobject.password == null ? "" : pobject.password);						for(var key:String in pobject.data)				postobject["data" + key] = pobject.data[key];							for(var i:int=pobject.pointers.length-1; i>-1; i--)			{				postobject["pointer" + i + "fieldname"] = pobject.pointers[i].fieldName;				postobject["pointer" + i + "classname"] = pobject.pointers[i].pobject.className;				postobject["pointer" + i + "id"] = pobject.pointers[i].pobject.objectId;			}						return postobject;		}				/**		 * Converts the server's MM/dd/yyyy hh:mm:ss into a Flash Date		 * @param	date		The date from the XML		 */			private static function DateParse(date:String):Date		{			var parts:Array = date.split(" ");			var dateparts:Array = (parts[0] as String).split("/");			var timeparts:Array = (parts[1] as String).split(":");			var day:int = int(dateparts[1]);			var month:int = int(dateparts[0]);			var year:int = int(dateparts[2]);			var hours:int = int(timeparts[0]);			var minutes:int = int(timeparts[1]);			var seconds:int = int(timeparts[2]);			return new Date(Date.UTC(year, month, day, hours, minutes, seconds));		}	}}