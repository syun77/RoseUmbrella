package jp_2dgames.game.token;

import jp_2dgames.game.particle.ParticleRain;
import flixel.FlxObject;
import jp_2dgames.lib.MyMath;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * 雨粒
 **/
class Raindrop extends Token {

  // 重力
  static inline var GRAVITY:Int = 200;

  public static var parent:FlxTypedGroup<Raindrop> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<Raindrop>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(X:Float, Y:Float, Angle:Float, Speed:Float):Raindrop {
    var rain:Raindrop = parent.recycle(Raindrop);
    rain.init(X, Y);
    rain.setVelocity(Angle, Speed);
    return rain;
  }

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic(AssetPaths.IMAGE_RAINDROP);
    acceleration.y = GRAVITY;
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float):Void {
    x = X - offset.x;
    y = Y - offset.y;

  }

  /**
   * プレイヤーとの衝突
   **/
  public function interact(player:Player):Void {
    if(player.umbrella.isOpenUpside() == false) {
      // ダメージ
      player.damage(40);
    }
    vanish();
  }

  /**
   * 雨粒との衝突
   **/
  public function interactUmbrella(umbrella:Umbrella):Void {
    vanish();
  }

  /**
   * 雨粒消滅
   **/
  public function vanish():Void {
    ParticleRain.add(xcenter, ycenter);
    kill();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    //angle = MyMath.atan2Ex(velocity.y, velocity.x);
  }


}
