package jp_2dgames.game.token;

import flixel.util.FlxTimer;
import flixel.effects.FlxFlicker;
import jp_2dgames.game.global.Global;
import jp_2dgames.lib.DirUtil;
import flixel.addons.effects.FlxTrail;
import jp_2dgames.lib.Snd;
import jp_2dgames.lib.MyColor;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.lib.Input;
import flixel.FlxG;
import flixel.FlxObject;
import openfl.display.BlendMode;
import flixel.FlxSprite;

/**
 * アニメーション状態
 **/
private enum AnimState {
  Standby; // 待機
  Run;     // 走り
  Brake;   // ブレーキ
  Jump;    // ジャンプ中
  Damage;  // ダメージ中
}

private enum State {
  Standing; // 地面に立っている
  Jumping;  // 空中にいる
}

/**
 * プレイヤー
 **/
class Player extends Token {

  // 速度制限
  static inline var MAX_VELOCITY_X:Int = 70;
  static inline var MAX_VELOCITY_Y:Int = 330;
  // 重力
  static inline var GRAVITY:Int = 400;
  // 移動量の減衰値
  static inline var DRAG_X:Int = MAX_VELOCITY_X * 4;
  static inline var DRAG_DASH:Int = DRAG_X * 2;
  // 移動加速度
  static inline var ACCELERATION_LEFT:Int = -MAX_VELOCITY_X * 4;
  static inline var ACCELERATION_RIGHT:Int = -ACCELERATION_LEFT;
  // ジャンプの速度
  static inline var JUMP_VELOCITY:Float = -MAX_VELOCITY_Y / 2;
  // 空中ダッシュの速度
  static inline var AIRDASH_VELOCITY:Float = MAX_VELOCITY_X * 4;
  // 反動
  static inline var REACTION_SPEED:Float = 10.0;
  static inline var REACTION_DECAY:Float = 0.7;

  // ----------------------------------------
  // ■タイマー
  static inline var TIMER_JUMPDOWN:Int   = 12; // 飛び降り
  static inline var TIMER_DAMAGE:Int     = 120; // ダメージタイマー

  // ----------------------------------------

  // ======================================
  // ■プロパティ
  public var light(get, never):FlxSprite;
  public var trail(get, never):FlxSprite;
  public var umbrella(get, never):Umbrella;
  // ======================================
  // ■メンバ変数
  var _state:State; // キャラクター状態
  var _anim:AnimState; // アニメーション状態

  var _tAnim:Int = 0;
  var _timer:Int = 0;
  var _tDamage:Int = 0; // ダメージタイマー
  var _canControl:Bool = true; // 操作可能かどうか
  var _animPrev:AnimState;
  var _light:FlxSprite;
  var _trail:FlxTrail;
  var _umbrella:Umbrella;
  var _dir:Dir; // 向いている方向
  var _lastdir:Dir; // 最後に押した方向
  var _bSlow:Bool = false;

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float, umbrella:Umbrella) {
    super(X, Y);
    loadGraphic(AssetPaths.IMAGE_PLAYER, true);
    // アニメーション登録
    _registerAnim();
    _playAnim(AnimState.Standby);

    // 傘
    _umbrella = umbrella;

    // トレイル
    _trail = new FlxTrail(this, null, 5);

    // 明かり
    _light = new FlxSprite();
    _light.loadGraphic(AssetPaths.IMAGE_LIGHT);
    _light.blend = BlendMode.ADD;
    _light.alpha = 0.2;
    _light.offset.set(_light.width/2, _light.height/2);

    // 変数初期化
    _state = State.Jumping;
    _timer = 0;
    _anim = AnimState.Standby;
    _animPrev = AnimState.Standby;
    _dir = Dir.Right;
    _lastdir = Dir.Right;

    // ■移動パラメータ設定
    // 重力を更新
    _updateGravity();
    // 移動量の減衰値を設定
    drag.x = DRAG_X;

    // 当たり判定を小さくする
    width = 8;
    height = 12;
    offset.x = 4;
    offset.y = 2;

    // デバッグ
    FlxG.watch.add(this, "_state", "Player.state");
    FlxG.watch.add(this, "_anim", "Player.anim");
    FlxG.watch.add(this, "_bSlow");
  }

  /**
   * 重力を設定
   **/
  function _updateGravity():Void {
    var gravity:Float = GRAVITY;
    var maxVelocityY:Float = MAX_VELOCITY_Y;

    _bSlow = false;
    if(_umbrella.isOpen()) {
      if(_umbrella.dir == Dir.Up) {
        if(velocity.y > 0 && _state == State.Jumping) {
          // 傘を上向きに開いていたら速度低下
          gravity *= 0.2;
          maxVelocityY *= 0.2;
          _bSlow = true;
        }
      }
    }

    // 重力加速度を設定
    acceleration.y = gravity;
    // 速度制限を設定
    maxVelocity.set(MAX_VELOCITY_X, maxVelocityY);

  }

  public function isActive():Bool {
    return moves;
  }

  /**
   * 更新
   **/
  public override function update(elapsed:Float):Void {

    if(isActive() == false) {
      // 動けない
      super.update(elapsed);
      return;
    }

    // 入力方向を更新
    var dir = DirUtil.getInputDirection();
    if(dir != Dir.None) {
      _dir = dir;
      if(dir != Dir.Down) {
        _lastdir = dir;
      }
    }

    // 入力更新
    _input();

    // アニメーション更新
    if(_anim != _animPrev) {
      // アニメーション変更
      _playAnim(_anim);
      _animPrev = _anim;
    }

    // タイマー更新
    _updateTimer();

    // 速度設定後に更新しないとめり込む
    super.update(elapsed);

    // 傘の座標を更新
    _updateUmbrella();

    // 重力を更新
    _updateGravity();

    // ライト更新
    _updateLight();

  }

  /**
   * キー入力
   **/
  function _input():Void {

    // キャラクター状態
    switch(_state) {
      case State.Standing:
        _inputStanding();

      case State.Jumping:
        _inputJumping();
    }

    if(_canControl == false) {
      // ダメージ中
      _anim = AnimState.Damage;
    }

    // 傘の出し入れ
    _openUmbrella();
  }

  /**
   * 入力・立ち状態
   **/
  function _inputStanding():Void {
    // 傘が使えるようになる
    _umbrella.activate();

    // 左右に移動
    _moveLR();
    if(isTouching(FlxObject.FLOOR)){
      // 着地
      velocity.y = 0;
      if(_umbrella.isOpenDownside()) {
        // 下側に傘を開いていたら閉じる
        _umbrella.close();
      }
    }
    if(Input.on.DOWN) {
      // 飛び降りる
      Floor.setAllowCollisionsAll(false);
      new FlxTimer().start(0.2, function(_) {
        // コリジョンを有効化
        Floor.setAllowCollisionsAll(true);
      });
    }
    else if(Input.press.A) {
      // ジャンプ
      _jump();
    }

    if(isTouching(FlxObject.FLOOR) == false) {
      // ジャンプした
      _state = State.Jumping;
    }
  }

  /**
   * 入力・ジャンプ状態
   **/
  function _inputJumping():Void {
    // 左右に移動
    _moveLR();

    _anim = AnimState.Jump;

    if(Input.press.A) {
      if(_umbrella.isOpenUpside()) {
        // 上方向に傘を開いていたら空中ジャンプできる
        // 傘は閉じる
        _umbrella.close();
        // 空中重力無効
        _updateGravity();
        _jump();
      }
    }

    if(isTouching(FlxObject.FLOOR)) {
      // 着地した
      _state = State.Standing;
    }
  }

  /**
   * 傘の出し入れ
   **/
  function _openUmbrella():Void {
    if(Input.press.B) {
      _umbrella.open(_lastdir);
    }
    else {
      if(Input.on.DOWN) {
        if(_state == State.Jumping) {
          // 下方向に出す
          _umbrella.openForce(Dir.Down);
        }
      }
    }
  }

  /**
   * 各種タイマーの更新
   **/
  function _updateTimer():Void {

    // アニメタイマー更新
    _tAnim++;

    // ダメージタイマー更新
    if(_tDamage > 0) {
      if(_tDamage < TIMER_DAMAGE*0.75) {
        _canControl = true;
      }
      _tDamage--;
    }
  }

  /**
   * ジャンプする
   **/
  function _jump():Void {
    velocity.y = JUMP_VELOCITY;
    Snd.playSe("jump");
    Particle.start(PType.Ring4, xcenter, bottom, FlxColor.WHITE);
  }

  /**
   * 踏みつけ傘ジャンプ
   **/
  public function jumpByUmbrella():Void {
    velocity.y = JUMP_VELOCITY * 0.5;
    Snd.playSe("jump");
  }

  /**
   * 傘の座標を更新
   **/
  function _updateUmbrella():Void {
    _umbrella.proc(x-offset.x, y-offset.y, _lastdir);
  }

  /**
   * 光源の更新
   **/
  function _updateLight():Void {
    var sc = FlxG.random.float(0.7, 1);
    _light.scale.set(sc, sc);
    _light.alpha = FlxG.random.float(0.2, 0.3);
    _light.x = xcenter;
    _light.y = ycenter;
  }

  /**
   * 左右に移動する
   **/
  function _moveLR():Void {

    acceleration.x = 0;
    if(Input.on.LEFT) {
      // 左に移動
      acceleration.x = ACCELERATION_LEFT;
      _anim = AnimState.Run;
      flipX = true;
    }
    else if(Input.on.RIGHT) {
      // 右に移動
      acceleration.x = ACCELERATION_RIGHT;
      _anim = AnimState.Run;
      flipX = false;
    }
    else {
      if(Math.abs(velocity.x) > 0.001) {
        // ブレーキ
        _anim = AnimState.Brake;
      }
      else {
        // 待機状態
        _anim = AnimState.Standby;
      }
    }

    // flipXをFlxTrailに反映
    for(spr in _trail.members) {
      spr.flipX = flipX;
    }
  }

  /**
   * 消滅
   **/
  public function vanish():Void {
    Particle.start(PType.Ball, xcenter, ycenter, MyColor.CRIMSON);
    Particle.start(PType.Ring2, xcenter, ycenter, MyColor.CRIMSON);
    kill();
    // トレイルも消す
    _trail.kill();
    // ライトも消す
    _light.kill();

  }

  /**
   * ダメージ処理
   **/
  public function damage(v:Int):Void {

    if(_tDamage > 0) {
      // ダメージ中はダメージを受けない
      return;
    }

    Global.addLife(-v);
    // 傘を閉じる
    _umbrella.close();

    if(Global.life <= 0) {
      // 死亡
      vanish();
      FlxG.camera.shake(0.05, 0.4);
      FlxG.camera.flash(FlxColor.WHITE, 0.5);
      Snd.playSe("kya");
      Snd.playSe("break");
    }
    else {
      // ダメージ開始
      _tDamage = TIMER_DAMAGE;
      // 操作不能
      _canControl = false;
      // 少しの間停止
      velocity.set();
      // 点滅開始
      FlxFlicker.flicker(this, TIMER_DAMAGE/FlxG.updateFramerate);
      Snd.playSe("hit");
    }
  }

  /**
   * ワープする
   **/
  public function warp(X:Float, Y:Float):Void {
    Particle.start(PType.Ball, xcenter, ycenter, MyColor.CRIMSON);
    Particle.start(PType.Ring2, xcenter, ycenter, MyColor.CRIMSON);
    x = X;
    y = Y;
  }

  /**
   * アニメーション登録
   **/
  function _registerAnim():Void {
    animation.add('${AnimState.Standby}', [0, 0, 1, 0, 0], 4);
    animation.add('${AnimState.Run}', [2, 2, 3, 3], 12);
    animation.add('${AnimState.Brake}', [4], 1);
    animation.add('${AnimState.Jump}', [2], 1);
    animation.add('${AnimState.Damage}', [5, 6], 12);
  }

  /**
   * アニメ再生
   **/
  function _playAnim(anim:AnimState):Void {
    animation.play('${anim}');
  }


  // -----------------------------------------------------------
  // ■アクセサ
  override public function get_radius():Float {
    return 6;
  }
  function get_light():FlxSprite {
    return _light;
  }
  function get_trail():FlxTrail {
    return _trail;
  }
  function get_umbrella():Umbrella {
    return _umbrella;
  }
}
