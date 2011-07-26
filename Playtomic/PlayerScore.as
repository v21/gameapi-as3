﻿//  This file is part of the official Playtomic API for ActionScript 3 games.  //  Playtomic is a real time analytics platform for casual games //  and services that go in casual games.  If you haven't used it //  before check it out://  http://playtomic.com/////  Created by ben at the above domain on 2/25/11.//  Copyright 2011 Playtomic LLC. All rights reserved.////  Documentation is available at://  http://playtomic.com/api/as3//// PLEASE NOTE:// You may modify this SDK if you wish but be kind to our servers.  Be// careful about modifying the analytics stuff as it may give you // borked reports.//// If you make any awesome improvements feel free to let us know!//// -------------------------------------------------------------------------// THIS SOFTWARE IS PROVIDED BY PLAYTOMIC, LLC "AS IS" AND ANY// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.package Playtomic{	public final class PlayerScore	{		public function PlayerScore(name:String = "", points:int = 0)		{			Name = name;			Points = points;		}				public var Name:String;		public var FBUserId:String;		public var Points:Number;		public var Rank:int;		public var Website:String;		public var SDate:Date;		public var RDate:String;		public var CustomData:Object = {};				public function toString():String		{			return "Playtomic.PlayerScore:" + 					"\nRank: " + Rank +					"\nName: " + Name + 					"\nPoints: " + Points;		}				public function toStringAll():String		{			var str:String = "Playtomic.PlayerScore:" + 							"\nRank: " + Rank +							"\nName: " + Name + 							"\nFBUserId: " + FBUserId +							"\nPoints: " + Points + 							"\nWebsite: " + Website + 							"\nSDate: " + SDate + 							"\nRDate: " + RDate + 							"\nCustomData: ";								for each(var value:String in CustomData)				str += "\n  " + value + ": " + CustomData[value];			return str;		}	}}