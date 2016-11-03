package jp_2dgames.game.token;

import jp_2dgames.game.global.Global;
import jp_2dgames.game.gui.MessageUI;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * ヒントオブジェクト
 **/
class Hint extends Token {

  public static var parent:FlxTypedGroup<Hint> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Hint>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(X:Float, Y:Float):Hint {
    var hint:Hint = parent.recycle(Hint);
    hint.init(X, Y);
    return hint;
  }

  // ==================================================
  // ■フィールド
  var _timer:Int = 0;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_HINT, true);
    animation.add("play", [0, 1], 3);
    animation.play("play");
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float):Void {
    x = X;
    y = Y;
    _timer = 0;
  }

  /**
   * プレイヤーとの衝突
   **/
  public function interact(player:Player):Void {
    var tbl = [
      "↑＋Xで傘を上に出します",
      "傘を出すと空中でジャンプできます",
      "ジャンプ中に↓で下方向に傘を出します",
      ""
    ];

    var msg = tbl[Global.level-1];
    MessageUI.show(msg);
    _timer = 120;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    if(_timer > 0) {
      _timer--;
      if(_timer == 0) {
        MessageUI.hide();
      }
    }
  }
}
