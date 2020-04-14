package app.factories
{
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	
	import app.assets.AssetController;
	import app.constants.Colour;
	import app.views.DropDownItemSmallRenderer;
	import app.views.DropDownItemSmallRendererSmall;
	
	import feathers.controls.Button;
	import feathers.controls.Check;
	import feathers.controls.IScrollBar;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.PickerList;
	import feathers.controls.ScrollBar;
	import feathers.controls.Scroller;
	import feathers.controls.TextInput;
	import feathers.controls.popups.VerticalCenteredPopUpContentManager;
	import feathers.controls.text.TextFieldTextEditor;
	import feathers.controls.text.TextFieldTextRenderer;
	import feathers.core.FeathersControl;
	import feathers.core.ITextEditor;
	import feathers.core.ITextRenderer;
	import feathers.core.PopUpManager;
	import feathers.data.ListCollection;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	
	import starling.display.DisplayObject;
	import starling.display.Quad;

	public class Factory
	{
		public static var scale:Number = 1;
		protected static var _formats:Dictionary;

		public function Factory(){
	
		}
		
		public static function init():void
		{
			_formats = new Dictionary();
			FeathersControl.defaultTextEditorFactory = textEditorFactory;
			FeathersControl.defaultTextRendererFactory = textRendererFactory;

			PopUpManager.overlayFactory = function():DisplayObject
			{
				var quad:Quad = new Quad(100, 100, 0x000000);
				quad.alpha = 0.5;
				return quad;
			};
		}
		
		public static function label(font:String, size:int, color:uint, align:String=TextFormatAlign.LEFT, wordWrap:Boolean=false, leading:Number=0, letterSpacing:Number=0):Label
		{
			var _key:String = font+size+color+align+leading+letterSpacing;
			if(!_formats[_key]){
				var _newTextFormat:TextFormat = new TextFormat(font, size, color, null, null,null,null,null,align, null, null, null,leading);
				_newTextFormat.letterSpacing = letterSpacing;
				_newTextFormat.leading = leading;
				_formats[_key] = _newTextFormat;
			}
			var _label:Label = new Label();
			_label.textRendererProperties.textFormat = _formats[_key];
			if(wordWrap) _label.textRendererProperties.wordWrap = true;
			
			return _label;
		}
		
		public static function textFormat(font:String, size:int, color:uint, align:String=TextFormatAlign.LEFT, leading:Number=0, letterSpacing:Number=0):TextFormat
		{
			var _key:String = font+size+color+align+leading+letterSpacing;
			if(!_formats[_key]){

				var _newTextFormat:TextFormat = new TextFormat(font, size, color, null, null,null,null,null,align, null, null, null,leading);
				_newTextFormat.letterSpacing = letterSpacing;
				_newTextFormat.leading = leading;
				_formats[_key] = _newTextFormat;
			}
			return TextFormat(_formats[_key]);
		}

		public static function btnTerms():Button
		{
			var _button:Button = new Button();
			var _btnSkin:Quad = new Quad(10, 10, 0xe2e2e1);
			_btnSkin.alpha = 0;
			_button.defaultSkin = _btnSkin;
			_button.defaultLabelProperties.textFormat = textFormat(Fonts.FONT_NEUSA_SEMI_BOLD, 50, Colour.GREY, TextFormatAlign.LEFT);
			_button.horizontalAlign = HorizontalAlign.LEFT;
			_button.label = "Agree to <u>terms & conditions</u>";
			_button.width = 650;
			return _button;
		}

		public static function invBtn(targetWidth:Number, targetHeight:Number, targetAlpha:Number=0):Button
		{
			var _button:Button = new Button();
			var _skin:Quad = new Quad(targetWidth, targetHeight);
			_skin.alpha = targetAlpha;
			_button.defaultSkin = _skin;
			_button.hasLabelTextRenderer = false;
			return _button;
		}
		
		public static function btnGeneric(text:String="",targetWidth:Number = 500, targetHeight = 116, fontSize:Number=42):Button
		{
			var _button:Button = new Button();
			var _btnSkin:Quad = new Quad(targetWidth, targetHeight, Colour.RED);
			//_btnSkin.scale9Grid = new Rectangle(20, 20, 30, 30);
			_button.defaultSkin = _btnSkin;
			_button.defaultLabelProperties.textFormat = textFormat(Fonts.FONT_CIRCULAR_PRO_BLACK, 42, 0xFFFFFF, TextFormatAlign.CENTER);
			_button.width = targetWidth;
			_button.height = targetHeight;
			_button.label = text;
			return _button;
		}

		public static function btnPhoneEntry(text:String="",targetWidth:Number = 220, targetHeight = 120):Button
		{
			var _button:Button = new Button();
			var _btnSkin:Quad = new Quad(targetWidth, targetHeight, Colour.RED);
			_button.defaultSkin = _btnSkin;
			_button.defaultLabelProperties.textFormat = textFormat(Fonts.FONT_CIRCULAR_PRO_BLACK, 48, Colour.WHITE, TextFormatAlign.CENTER);
			_button.width = targetWidth;
			_button.height = targetHeight;
			_button.label = text;
			return _button;
		}
		
		public static function textInput(prompt:String, width:Number = 900, height:Number = 70, promptColor:uint=Colour.GREY,textAlign:String=TextFormatAlign.LEFT, fontSize:Number=25, paddingTop:Number=10):TextInput
		{
			var _input:TextInput = new TextInput();
			_input.backgroundSkin = new Quad(100, 100, 0xcccccc);
			_input.paddingTop = paddingTop;
			_input.textEditorProperties.textFormat = textFormat(Fonts.FONT_GOTHAM_BOLD, fontSize, Colour.BLACK, textAlign);
			_input.promptProperties.textFormat = textFormat(Fonts.FONT_GOTHAM_BOLD, fontSize, promptColor, textAlign);
			_input.prompt = prompt;
			_input.width = width;
			_input.height = height;
			return _input;
		}
		

		public static function textInput2(targetWidth:Number=660, targetHeight:Number=100, prompt:String=""):TextInput
		{
			var _input:TextInput = new TextInput();
			_input.paddingLeft = _input.paddingRight = 14;
			_input.paddingBottom = 10;
			_input.width = targetWidth;
			_input.height = targetHeight;
			var _bg:Quad = new Quad(targetWidth, targetHeight, 0xe2e2e2);
			_input.backgroundSkin = _bg;
			_input.verticalAlign = TextInput.VERTICAL_ALIGN_MIDDLE;
			return _input;
		}

		public static function check():Check
		{
			var _button:Check = new Check();	
			_button.defaultSkin = new Quad(75, 64, 0x000000);
			
			_button.defaultSelectedIcon = AssetController.getImage("tick");
			
			return _button;
		}
		
		protected static function textEditorFactory():ITextEditor
		{
			var _editor:TextFieldTextEditor = new TextFieldTextEditor();
			_editor.textFormat =  textFormat(Fonts.FONT_LIGHT, 48, 0xFFFFFF, TextFormatAlign.CENTER, 0, 10);
			_editor.embedFonts = true;
			//_editor.useSnapshotDelayWorkaround = true;
			return _editor;
		}
		
		public static function textEditorFactory2():ITextEditor
		{
			var _editor:TextFieldTextEditor = new TextFieldTextEditor();
			_editor.textFormat =  textFormat(Fonts.FONT_NEUSA_SEMI_BOLD, 48, Colour.BLACK, TextFormatAlign.CENTER, 0, 10);
			_editor.embedFonts = true;
			//_editor.useSnapshotDelayWorkaround = true;
			return _editor;
		}
		
		protected static function textRendererFactory():ITextRenderer
		{
			const renderer:TextFieldTextRenderer = new TextFieldTextRenderer();
			renderer.embedFonts = true;
			renderer.isHTML = true;
			renderer.useGutter = true;
			return renderer;
		}
		
		public static function dropDown(prompt:String, data:ListCollection, width:Number = 660, height:Number = 60):PickerList
		{
			var _pickerList:PickerList = new PickerList();
			_pickerList.dataProvider = data;
			_pickerList.labelField = "text";
			_pickerList.prompt = prompt;
			_pickerList.selectedIndex = -1;
			_pickerList.buttonFactory = Factory.dropDownButton;
			_pickerList.height = height;
			_pickerList.width = width;
			_pickerList.listFactory = Factory.dropDownList;
			
			var popUpContentManager:VerticalCenteredPopUpContentManager = new VerticalCenteredPopUpContentManager();
			popUpContentManager.marginTop = 20;
			popUpContentManager.marginRight = 25;
			popUpContentManager.marginBottom = 20;
			popUpContentManager.marginLeft = 25;
			
			
			_pickerList.popUpContentManager = popUpContentManager;
			_pickerList.labelFunction = function (item:Object):String{
				//return "<FONT COLOR='#0E9D57' >"+item.text+" </FONT>";
				return item.text;
			};
			
			return _pickerList;
		}
		
		public static function dropDownButton():Button
		{
			var _button:Button = new Button();
			
			_button.defaultSkin = new Quad(100, 60, 0xe2e2e2);
			_button.defaultIcon = AssetController.getImage("dropDownArrow");
			
			_button.defaultLabelProperties.textFormat = textFormat(Fonts.FONT_LIGHT, 40, 0x000000, TextFormatAlign.LEFT);
			_button.isQuickHitAreaEnabled = true;
			_button.iconPosition = Button.ICON_POSITION_LEFT;
			_button.gap = 15;
			_button.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_LEFT;
			_button.width = 660;
			_button.height = 60;
			_button.paddingLeft = 20;
			return _button;
		}
		
		public static function dropDownList():List
		{
			var _list:List = new List();
			_list.itemRendererType = DropDownItemSmallRenderer;
			_list.verticalScrollBarFactory = function():IScrollBar
			{
				var _scrollBar:ScrollBar = new ScrollBar();
				_list.addChild(_scrollBar);
				_scrollBar.direction = ScrollBar.DIRECTION_VERTICAL;
				_scrollBar.height = 500;
				_scrollBar.width = 20;
				_scrollBar.trackLayoutMode = ScrollBar.TRACK_LAYOUT_MODE_MIN_MAX;
				_scrollBar.isEnabled = true;
				_scrollBar.thumbFactory = function():Button
				{
					var button:Button = new Button();
					button.defaultSkin = new Quad(20, 100, 0x4285f4);
					return button;
				}
				
				_scrollBar.minimumTrackFactory = function():Button
				{
					var button:Button = new Button();
					var _minSkin:Quad = new Quad(20, 100, 0xd1d1d1);
					button.defaultSkin = _minSkin;
					return button;
				}
				
				_scrollBar.maximumTrackFactory = function():Button
				{
					var button:Button = new Button();
					var _minSkin:Quad = new Quad(20, 100, 0xbababa);
					button.defaultSkin = _minSkin;
					return button;
				}
				return _scrollBar;
			}
			_list.width = 700;
			_list.verticalScrollBarPosition = Scroller.VERTICAL_SCROLL_BAR_POSITION_RIGHT;
			_list.interactionMode = List.INTERACTION_MODE_TOUCH_AND_SCROLL_BARS;
			_list.scrollBarDisplayMode = List.SCROLL_BAR_DISPLAY_MODE_FIXED;
			_list.horizontalScrollPolicy = List.SCROLL_POLICY_OFF;
			var _layout:VerticalLayout = new VerticalLayout();
			_layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_LEFT;
			_list.layout = _layout;
			return _list;
		}
		
		public static function dropDownSmall(prompt:String, data:ListCollection, width:Number = 190, height:Number = 60):PickerList
		{
			var _pickerList:PickerList = new PickerList();
			_pickerList.dataProvider = data;
			_pickerList.labelField = "text";
			_pickerList.prompt = prompt;
			_pickerList.selectedIndex = -1;
			_pickerList.buttonFactory = Factory.dropDownButtonSmall;
			_pickerList.height = height;
			_pickerList.width = width;
			_pickerList.listFactory = Factory.dropDownListSmall;
			
			var popUpContentManager:VerticalCenteredPopUpContentManager = new VerticalCenteredPopUpContentManager();
			//popUpContentManager.marginTop = 20;
			popUpContentManager.marginRight = 25;
			//popUpContentManager.marginBottom = 20;
			popUpContentManager.marginLeft = 25;
			
			_pickerList.popUpContentManager = popUpContentManager;
			_pickerList.labelFunction = function (item:Object):String{
				//return "<FONT COLOR='#0E9D57' >"+item.text+" </FONT>";
				return item.text;
			};
			
			return _pickerList;
		}
		
		public static function dropDownButtonSmall():Button
		{
			var _button:Button = new Button();
			
			_button.defaultSkin = new Quad(190, 60, 0x444444);
			_button.defaultIcon = AssetController.getImage("dropDownArrow");
			_button.defaultLabelProperties.textFormat = textFormat(Fonts.FONT_LIGHT, 15, 0xFFFFFF, TextFormatAlign.LEFT);
			_button.isQuickHitAreaEnabled = true;
			_button.iconPosition = Button.ICON_POSITION_LEFT;
			_button.gap = 10;
			_button.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_LEFT;
			_button.width = 190;
			_button.height = 60;
			_button.paddingLeft = 20;
			_button.wordWrap = true;
			return _button;
		}
		
		public static function dropDownListSmall():List
		{
			var _list:List = new List();
			_list.itemRendererType = DropDownItemSmallRendererSmall;
			_list.verticalScrollBarFactory = function():IScrollBar
			{
				var _scrollBar:ScrollBar = new ScrollBar();
				_list.addChild(_scrollBar);
				_scrollBar.direction = ScrollBar.DIRECTION_VERTICAL;
				_scrollBar.height = 500;
				_scrollBar.width = 20;
				_scrollBar.trackLayoutMode = ScrollBar.TRACK_LAYOUT_MODE_MIN_MAX;
				_scrollBar.isEnabled = true;
				_scrollBar.thumbFactory = function():Button
				{
					var button:Button = new Button();
					button.defaultSkin = new Quad(20, 100, 0x4285f4);
					return button;
				}
				
				_scrollBar.minimumTrackFactory = function():Button
				{
					var button:Button = new Button();
					var _minSkin:Quad = new Quad(20, 100, 0xd1d1d1);
					button.defaultSkin = _minSkin;
					return button;
				}
				
				_scrollBar.maximumTrackFactory = function():Button
				{
					var button:Button = new Button();
					var _minSkin:Quad = new Quad(20, 100, 0xbababa);
					button.defaultSkin = _minSkin;
					return button;
				}
				return _scrollBar;
			}
			_list.width = 700;
			_list.verticalScrollBarPosition = Scroller.VERTICAL_SCROLL_BAR_POSITION_RIGHT;
			_list.interactionMode = List.INTERACTION_MODE_TOUCH_AND_SCROLL_BARS;
			_list.scrollBarDisplayMode = List.SCROLL_BAR_DISPLAY_MODE_FIXED;
			_list.horizontalScrollPolicy = List.SCROLL_POLICY_OFF;
			var _layout:VerticalLayout = new VerticalLayout();
			_layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_LEFT;
			_list.layout = _layout;
			return _list;
		}
	}
}