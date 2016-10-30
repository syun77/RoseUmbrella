package jp_2dgames.game.token;

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
    if(exists == false) {
      if(_canOpen) {
        // 開く
        revive();
        _dir = dir;
      }
    }
    else {
      // 閉じる
      close();
    }
  }

  /**
   * 傘を閉じる
   **/
  public function close():Void {
    kill();
    _canOpen = false;
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
  }

  // アクセサ関数
  function get_dir() {
    return _dir;
  }
}
