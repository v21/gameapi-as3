package {
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import Playtomic.*;
	public class TestLinkTracking {
		
		private static var fakeMC:MovieClip = new MovieClip;
		public static function test():void {
			fakeMC.addEventListener(MouseEvent.CLICK, SplashClick);
			fakeMC.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		private static function SplashClick(e:MouseEvent):void
		{
			Link.Open("http://kongregate.com/?gameref=my_game&location=splash", "Splash", "Sponsor");
		}
	}
}
