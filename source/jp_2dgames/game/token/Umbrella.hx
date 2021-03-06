package jp_2dgames.game.token;

import jp_2dgames.lib.Snd;
import jp_2dgames.lib.MyColor;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.lib.DirUtil;

/**
 * 傘
 **/
class Umbrella extends Token {

  // ■定数
  static inline var OFFSET_DISTANCE:Float = 12.0;

  // ■プロパティ
  public var dir(get, never):Dir;

  // ■フィールド
  var _dir:Dir; // 傘の方向
  var _canOpen:Bool; // 傘を開くことができるかどうか
  var _bEffect:Bool = false;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    loadGraphic(AssetPaths.IMAGE_UMBRELLA);
    kill();
  }

  /**
   * 方向を設定
   **/
  public function setDir(dir:Dir):Void {
    _dir = dir;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);
  }

  /**
   * 傘が使えるようになる
   **/
  public function activate():Void {
    _canOpen = true;
  }

  /**
   * 傘を開く
   **/
  public function open(dir:Dir):Void {
    if(isOpen() == false) {
      if(_canOpen) {
        // 開く
        openForce(dir);
        _bEffect = true;
      }
    }
    else {
      // 閉じる
      close();
    }
  }

  /**
   * 強制的に開く
   **/
  public function openForce(dir:Dir):Void {
    revive();
    _dir = dir;
    Snd.playSe("umbrella");
  }

  /**
   * 傘を閉じる
   **/
  public function close():Void {
    kill();
    _canOpen = false;
    Snd.playSe("umbrella");
  }

  /**
   * 傘を開いているかどうか
   **/
  public function isOpen():Bool {
    return exists;
  }

  /**
   * 上方向に傘を開いているかどうか
   **/
  public function isOpenUpside():Bool {
    if(isOpen()) {
      if(_dir == Dir.Up) {
        return true;
      }
    }

    return false;
  }

  /**
   * 下方向に傘を開いているかどうか
   **/
  public function isOpenDownside():Bool {
    if(isOpen()) {
      if(_dir == Dir.Down) {
        return true;
      }
    }

    return false;
  }

  /**
   * 座標を更新
   **/
  public function proc(xroot:Float, yroot:Float, newDir:Dir):Void {
    if(exists == false) {
      return;
    }

    if(DirUtil.isHorizontal(_dir)) {
      if(DirUtil.isHorizontal(newDir)) {
        // 水平方向ならば方向を更新
        _dir = newDir;
      }
    }
    angle = -DirUtil.toAngle(_dir);

    var v = DirUtil.getVector(_dir);
    v.scale(OFFSET_DISTANCE);
    x = xroot + v.x;
    y = yroot + v.y;
    v.put();

    if(_bEffect) {
      // エフェクト再生開始
      Particle.start(PType.Ring, xcenter, ycenter, MyColor.CRIMSON);
      _bEffect = false;
    }
  }

  // アクセサ関数
  function get_dir() {
    return _dir;
  }
}
