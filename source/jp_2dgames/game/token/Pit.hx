package jp_2dgames.game.token;

import jp_2dgames.lib.DirUtil;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * 即死のトゲ
 **/
class Pit extends Token {

  public static var parent:FlxTypedGroup<Pit> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Pit>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(dir:Dir, X:Float, Y:Float):Pit {
    var pit:Pit = parent.recycle(Pit);
    pit.init(dir, X, Y);
    return pit;
  }

  /**
   * コンストラクション
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_PIT);
  }

  /**
   * 初期化
   **/
  public function init(dir:Dir, X:Float, Y:Float):Void {
    x = X;
    y = Y;
    angle = -DirUtil.toAngle(dir);
  }

  /**
   * プレイヤーとの衝突
   **/
  public function interact(player:Player):Void {
    player.damage(9999);
  }
}
