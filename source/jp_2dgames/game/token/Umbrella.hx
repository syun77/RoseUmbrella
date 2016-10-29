package jp_2dgames.game.token;

import jp_2dgames.lib.DirUtil;

/**
 * 傘
 **/
class Umbrella extends Token {

  // ■プロパティ
  public var dir(get, never):Dir;

  // ■フィールド
  var _dir:Dir;

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
   * 傘を開く
   **/
  public function open(dir:Dir):Void {
    if(exists == false) {
      // 開く
      revive();
      _dir = dir;
    }
    else {
      // 閉じる
      kill();
    }
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
    v.scale(12);
    x = xroot + v.x;
    y = yroot + v.y;
    v.put();
  }

  // アクセサ関数
  function get_dir() {
    return _dir;
  }
}
