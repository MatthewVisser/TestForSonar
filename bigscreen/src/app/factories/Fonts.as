package app.factories
{
	public class Fonts
	{
		public static const FONT_BOLD:String = "MyriadBold";
		[Embed(source="/fonts/MyriadPro-Bold.otf",fontName="MyriadBold",mimeType="application/x-font",embedAsCFF="false")]
		protected static const MYRIAD_BOLD:Class;
		
		public static const FONT_LIGHT:String = "MyriadLight";
		[Embed(source="/fonts/MyriadPro-Light.otf",fontName="MyriadLight",mimeType="application/x-font",embedAsCFF="false")]
		protected static const MYRIAD_LIGHT:Class;
		
		public static const FONT_NEUSA_SEMI_BOLD:String = "NeusaSemiBold";
		[Embed(source="/fonts/NeusaSemiBold.otf",fontName="NeusaSemiBold",mimeType="application/x-font",embedAsCFF="false")]
		protected static const NEUSA_SEMI_BOLD:Class;
		
		public static const FONT_GOTHAM_BOLD:String = "GothamBold";
		[Embed(source="/fonts/GothamHTF-Bold.otf",fontName="GothamBold",mimeType="application/x-font",embedAsCFF="false")]
		protected static const GOTHAM_BOLD:Class;
		
		public static const FONT_CIRCULAR_PRO_BLACK:String = "CircularProBlack";
		[Embed(source="/fonts/CircularPro-Black.otf",fontName="CircularProBlack",mimeType="application/x-font",embedAsCFF="false")]
		protected static const CIRCULAR_PRO_BLACK:Class;
		
		public static const FONT_NEON_BOLD:String = "NeonBold";
		[Embed(source="/fonts/Ty14AtBd.ttf",fontName="NeonBold",mimeType="application/x-font",embedAsCFF="false")]
		protected static const NEON_BOLD:Class;
		
		public function Fonts()
		{
		}
	}
}