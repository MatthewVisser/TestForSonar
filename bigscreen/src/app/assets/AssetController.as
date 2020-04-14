package app.assets
{	

	import starling.display.Button;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	import starling.utils.AssetManager;
	
	public class AssetController
	{
		public static var _assets:AssetManager;
		protected static var _canInit:Boolean = true;
		protected static var _instance:AssetController;
		protected static var _setupCompleteCallback:Function;
		protected static var _frames:Vector.<Texture>;
		protected static var _texture:Texture;
		protected static var _textureDown:Texture;
		protected static var _movieClip:MovieClip;
		private static var _image:Image;
		private static var _button:Button;
		private static var _scaleFactor:Number = 1;
		public function AssetController()
		{
			if (_canInit == false) {
				throw new Error(
					'AssetController is an singleton and cannot be instantiated.'
				);
			}
		}
		
		protected static function getInstance():AssetController {
			if (_instance == null) {
				_canInit = true;
				_instance = new AssetController();
				_canInit = false;
			}
			return _instance;
		}
		
		public static function setup(setupCompleteCallback:Function, scaleFactor:Number):void
		{
			_setupCompleteCallback = setupCompleteCallback;
			_assets = new AssetManager(scaleFactor);
			_assets.verbose = true;
		}
		
		public static function loadAsset(asset:*):void
		{
			_assets.enqueue(asset);
		}
		
		public static function startLoadingAssets():void
		{
			_assets.loadQueue(loadingProgress);
		}
		
		protected static function loadingProgress(ratio:Number):void
		{
			if(ratio == 1){
				_setupCompleteCallback.call(null);
			}
		}
		
		public static function getTexture(textureName:String):Texture {
			
			_texture = _assets.getTexture(textureName);
			return _texture;
		}
		
		public static function getTextures(textureName:String):Vector.<Texture> {
			_texture = _assets.getTexture(textureName);
			_frames = _assets.getTextures(textureName);
			return _frames;
		}
		
		
		public static function getImage(textureName:String, touchable:Boolean = false, smoothing:String = TextureSmoothing.BILINEAR):Image {
			_texture = getTexture(textureName);
			_image = new Image(_texture);
			_image.touchable = touchable;
			_image.textureSmoothing = String(smoothing);
			return _image;
		}
		
		public static function getButton(textureUp:String, buttonText:String, textureDown:String):Button {
			_texture = getTexture(textureUp);
			_textureDown = getTexture(textureDown);
			_button = new Button(_texture, buttonText, _textureDown);
			return _button;
		}
		
		public static function getMovie(textureName:String, touchable:Boolean = false,frameRate:int=25):MovieClip {
			_movieClip = new MovieClip(getTextures(textureName), frameRate);
			_movieClip.touchable = touchable;
			return _movieClip;
		}
		
		public static function playSound(soundName:String):void
		{
			_assets.playSound(soundName);
		}
		
	}
}