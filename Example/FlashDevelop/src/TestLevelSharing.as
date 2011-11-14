package {
	import flash.display.MovieClip;
	import flash.utils.ByteArray;
	import Playtomic.*;
	public class TestLevelSharing {
		private static var levelColor0:uint = 0x000000
		private static var levelColor1:uint = 0xff0000
		private static var levelData:Array = [ [0, 0, 1, 1, 0, 1, 1, 0, 0],
										[0, 1, 1, 1, 1, 1, 1, 1, 0],
										[1, 1, 1, 1, 1, 1, 1, 1, 1],
										[1, 1, 1, 1, 1, 1, 1, 1, 1],
										[0, 1, 1, 1, 1, 1, 1, 1, 0],
										[0, 0, 1, 1, 1, 1, 1, 0, 0],
										[0, 0, 0, 1, 1, 1, 0, 0, 0],
										[0, 0, 0, 0, 1, 0, 0, 0, 0]
									  ];
									  
		public static function test():void {
			var playerLevel:PlayerLevel = new PlayerLevel();
			playerLevel.PlayerName = "BabeRuth";
			playerLevel.PlayerId = "for3rdPartyApi";
			playerLevel.PlayerSource = "alsoFor3rdPartyApi";
			playerLevel.Name = "levelName" + int(Math.random() * 1000).toString();
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject( { c0:levelColor0, c1:levelColor1, dat:levelData } );
			playerLevel.Data = b64Encode.Base64(bytes);
			PlayerLevels.Save(playerLevel, buildDisp(), SaveComplete);
		}
		private static function buildDisp():MovieClip {
			var disp:MovieClip = new MovieClip;
			disp.graphics.beginFill(levelColor0);
			disp.graphics.drawRect(0, 0, 100, 100);
			disp.graphics.beginFill(levelColor1)
			for (var c:int = 0; c < levelData.length; c++) {
				for (var r:int = 0; r < levelData[c].length; r++) {
					disp.graphics.drawRect(c * 10, r * 10, 10, 10);
				}
			}
			disp.graphics.endFill();
			return disp;
		}
		private static function SaveComplete(level:PlayerLevel, response:Object):void{
			if(response.Success){
				trace("Level saved successfully, the level parameter is ready for use!");
				PlayerLevels.List(ListLoaded, {mode: "newest"})
			}
			else{
				trace("LevelSave failed because of " + response.ErrorCode);
			}
		}
		private static function ListLoaded(levels:Array, numlevels:int, response:Object):void{
			if(response.Success){
				for(var i:int=0; i<levels.length; i++){
					trace(" - " + levels[i].LevelId + ": " + levels[i].Name);
				}
				if(levels.length > 0){
					PlayerLevels.Load(levels[0].LevelId, LoadComplete);
				}else {
					trace("no levels available yet");
				}
			}
			else{
				trace("LevelList failed because of " + response.ErrorCode);
			}
		}
		private static function LoadComplete(level:PlayerLevel, response:Object):void{
			if(response.Success){
				trace("Level has been loaded, now you can begin playing it");
				var bytes:ByteArray = b64Encode.Base64Decode(level.Data);
				var data:Object = bytes.readObject();
				levelColor0 = data.c0;
				levelColor1 = data.c1;
				levelData = data.dat;
				Main.instance.addChild(buildDisp());
				
				PlayerLevels.Rate(level.LevelId, 4, RateComplete);
			}
			else{
				trace("LevelLoad failed because of " + response.ErrorCode);
			}
		}
		private static function RateComplete(response:Object):void{
			if(response.Success){
				trace("Rating complete");
			}
			else{
				trace("LevelRating failed because of " + response.ErrorCode);
			}
		}
		
	}
}
