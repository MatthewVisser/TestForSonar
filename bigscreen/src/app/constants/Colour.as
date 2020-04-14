package app.constants
{
	public class Colour
	{
		public static const WHITE:uint = 0xffffff;
		public static const RED:uint = 0xed1c24;
		public static const GREY:uint = 0xe0e0e0;
		public static const GREY_LIGHT:uint = 0xe0e0e0;
		public static var BLACK:uint = 0x000000;
		public function Colour()
		{
		}
		
		public static function uintToHex(color:uint):String
		{
			return "#"+color.toString(16);
		}
			
	}
}