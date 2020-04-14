package app.screens {
import app.assets.AssetController;
import app.models.AppModel;

import com.greensock.TweenMax;

import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.Screen;
import feathers.events.FeathersEventType;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import starling.display.Image;

public class StartScreen extends Screen {

    private var _heading1:Label;
    private var _heading2:Label;
    private var _heading3:Label;

    public function StartScreen() {
        super();
    }

    override protected function initialize():void {
        super.initialize();
        var _startLayout:LayoutGroup = new LayoutGroup();
        addChild(_startLayout);
        var _verticalLayout:VerticalLayout = new VerticalLayout();
        _verticalLayout.horizontalAlign = HorizontalAlign.CENTER;
        _verticalLayout.verticalAlign = VerticalAlign.MIDDLE;
        _startLayout.layout = _verticalLayout;
        _startLayout.setSize(AppModel.stageWidth, AppModel.stageHeight);

        var _startText:Image = AssetController.getImage("neon/startText");
        _startLayout.addChild(_startText);
        this.owner.addEventListener(FeathersEventType.TRANSITION_COMPLETE, transitionCompleteHandler);
    }

    private function transitionCompleteHandler():void {
        this.owner.removeEventListener(FeathersEventType.TRANSITION_COMPLETE, transitionCompleteHandler);
    }

    override public function dispose():void {
        TweenMax.killTweensOf(this);

        super.dispose();
    }
}
}