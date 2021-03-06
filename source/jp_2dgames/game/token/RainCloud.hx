package jp_2dgames.game.token;

import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * 雨雲
 **/
class RainCloud extends Token {

  public static var parent:FlxTypedGroup<RainCloud> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<RainCloud>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(X:Float, Y:Float):RainCloud {
    var cloud:RainCloud = parent.recycle(RainCloud);
    cloud.init(X, Y);
    return cloud;
  }

  // ================================================
  // ■フィールド
  var _canEmit:Bool = true;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    makeGraphic(16, 16, FlxColor.GRAY);
    visible = false;
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float):Void {
    x = X;
    y = Y;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    if(isOnScreen() == false) {
      // 画面外では何もしない
      return;
    }

    if(_canEmit) {
      Raindrop.add(xcenter, ycenter, 270, 50);
      _canEmit = false;
      new FlxTimer().start(0.2, function(_) {
        _canEmit = true;
      });
    }
  }
}
