package jp_2dgames.game.token;

/**
 * 傘
 **/
class Umbrella extends Token {

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    loadGraphic(AssetPaths.IMAGE_UMBRELLA);
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);
  }
}
