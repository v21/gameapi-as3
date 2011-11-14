package {
	import Playtomic.*;
	public class TestAnalytics {
		
		private static var level_number:int = 1;
		private static var seconds:int = 60;
		private static var retries:int = 3;
		private static var shots:int = 5;
		private static var coins:int = 18;
		private static var coinstotal:int = 20;
		private static var x:int = 100;
		private static var y:int = 125;
		public static function test():void {
			Log.Play();
			Log.Freeze();
			Log.Play();
			Log.UnFreeze();
			Log.ForceSend();
			
			Log.CustomMetric("ViewedCredits"); // metric, names must be alphanumeric
			Log.CustomMetric("Credits", "Screens"); // metric with group, groups must be alphanumeric
			Log.CustomMetric("ClickedSponsorsLinks", "Links", true); // unique metric with group
			Log.LevelCounterMetric("Deaths", level_number); // names must be alphanumeric
			Log.LevelCounterMetric("Restarts", "LevelName"); // level names must be alphanumeric
			Log.LevelCounterMetric("Restarts", "LevelName", true); // unique only
			Log.LevelAverageMetric("Time", level_number, seconds);
			Log.LevelAverageMetric("Retries", level_number, retries);
			Log.LevelAverageMetric("Retries", level_number, retries, true); // unique only
			Log.LevelRangedMetric("Shots", level_number, shots);
			Log.LevelRangedMetric("PercentCoinsCollected", level_number, int(coins / coinstotal * 100));
			Log.LevelRangedMetric("Shots", level_number, shots, true); // unique only
			Log.Heatmap("Metric", "Heatmap", x, y);
		}
	}
}
