package jp_2dgames.game.token;

import flixel.FlxObject;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * 一方通行床
 **/
class Floor extends Token {

  public static var parent:FlxTypedGroup<Floor> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Floor>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(X:Float, Y:Float):Floor {
    var floor:Floor = parent.recycle(Floor);
    floor.init(X, Y);
    return floor;
  }
  /**
   * すべての床の衝突フラグを立てる
   **/
  public static function setAllowCollisionsAll(b:Bool):Void {

    var allowCollisions = FlxObject.UP;
    if(b == false) {
      // コリジョンを無効化
      allowCollisions = FlxObject.NONE;
    }

    parent.forEachAlive(function(floor:Floor) {
      floor.allowCollisions = allowCollisions;
    });
  }

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_FLOOR);
    immovable = true; // 動かない
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float):Void {
    x = X;
    y = Y;
    allowCollisions = FlxObject.UP;
  }
}
