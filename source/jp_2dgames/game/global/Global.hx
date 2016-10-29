package jp_2dgames.game.global;

/**
 * グローバル変数
 **/
class Global {

  static var _level:Int = 0;

  public static function initGame():Void {
    _level = 0;
  }

  public static function initLevel():Void {
    _level = 0;
  }

  public static function addLevel():Bool {
    _level++;
    return true; // TODO:
  }
}
