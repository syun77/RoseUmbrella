package jp_2dgames.game.global;

/**
 * グローバル変数
 **/
import flixel.math.FlxMath;
class Global {

  public static inline var MAX_LIFE:Int = 100;

  static var _level:Int = 1;
  static var _life:Int = MAX_LIFE;

  public static function initGame():Void {
    _level = 1;
  }

  public static function initLevel():Void {
    _level = 1;
  }

  public static function addLevel():Bool {
    _level++;
    return true; // TODO:
  }

  public static function addLife(v:Int):Void {
    _life = FlxMath.maxAdd(_life, v, MAX_LIFE);
  }

  public static var level(get, never):Int;
  public static var life(get, never):Int;
  static function get_level() {
    return _level;
  }
  static function get_life() {
    return _life;
  }
}
