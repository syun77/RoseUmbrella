package jp_2dgames.game.token;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxState;

/**
 * レンガブロック
 **/
class BrickBlock extends Token {

  public static var parent:FlxTypedGroup<BrickBlock>;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<BrickBlock>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(X:Float, Y:Float):BrickBlock {
    var block:BrickBlock = parent.recycle(BrickBlock);
    block.init(X, Y);
    return block;
  }

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_BLOCK, true);
    animation.add("play", [1]);
    animation.play("play");
    immovable = true; // 動かない
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float):Void {
    x = X;
    y = Y;
  }
}
