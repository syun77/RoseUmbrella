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
#if debug
    makeGraphic(16, 16, FlxColor.GRAY);
#end
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

    if(_canEmit) {
      Raindrop.add(x, y, 270, 100);
      _canEmit = false;
      new FlxTimer().start(0.1, function(_) {
        _canEmit = true;
      });
    }
  }
}
