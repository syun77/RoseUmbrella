package jp_2dgames.game.particle;

import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import jp_2dgames.game.token.Token;

/**
 * 雨の消滅エフェクト
 **/
class ParticleRain extends Token {

  public static var parent:FlxTypedGroup<ParticleRain> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<ParticleRain>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function add(X:Float, Y:Float):ParticleRain {
    var p:ParticleRain = parent.recycle(ParticleRain);
    p.init(X, Y);
    return p;
  }

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    makeGraphic(1, 1, FlxColor.CYAN);
  }

  public function init(X:Float, Y:Float):Void {
    x = X;
    y = Y;
    acceleration.y = 200;
    var Angle = FlxG.random.float(45, 135);
    setVelocity(Angle, 50);

    alpha = 1;
    FlxTween.tween(this, {alpha:0}, 1);
    new FlxTimer().start(1, function(_) {
      kill();
    });
  }
}
