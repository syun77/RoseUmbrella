package jp_2dgames.game.gui;

import flixel.util.FlxColor;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxAxes;
import flixel.text.FlxText;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;

/**
 * メッセージテキスト表示
 **/
class MessageUI extends FlxSpriteGroup {

  static var _instance:MessageUI = null;
  public static function createInstance(state:FlxState):Void {
    _instance = new MessageUI();
    state.add(_instance);
  }
  public static function destroyInstance():Void {
    _instance = null;
  }
  public static function show(msg:String):Void {
    _instance._show(msg);
  }
  public static function hide():Void {
    _instance._hide();
  }

  // ==================================
  // ■フィールド
  var _txt:FlxText;
  var _bg:FlxSprite;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    _bg = new FlxSprite();
    _bg.makeGraphic(FlxG.width, 32, FlxColor.BLACK);
    _bg.alpha = 0.5;
    _bg.screenCenter(FlxAxes.Y);
    this.add(_bg);

    _txt = new FlxText(0, 0, FlxG.width);
    _txt.setFormat(AssetPaths.FONT, 10, FlxColor.WHITE, FlxTextAlign.CENTER);
    _txt.screenCenter(FlxAxes.Y);
    _txt.y -= 8;
    this.add(_txt);

    scrollFactor.set();
    visible = false;
  }

  function _show(msg:String):Void {
    _txt.text = msg;
    visible = true;
  }
  function _hide():Void {
    visible = false;
  }
}
