package jp_2dgames.game.state;

import jp_2dgames.game.token.Floor;
import jp_2dgames.game.token.Pit;
import flixel.addons.transition.FlxTransitionableState;
import jp_2dgames.game.particle.ParticleStartLevel;
import jp_2dgames.game.token.Spike;
import jp_2dgames.game.gui.GameUI;
import jp_2dgames.game.token.RainCloud;
import jp_2dgames.game.token.Raindrop;
import jp_2dgames.lib.Input;
import jp_2dgames.game.token.BrickBlock;
import flixel.FlxCamera.FlxCameraFollowStyle;
import jp_2dgames.game.token.Umbrella;
import jp_2dgames.game.token.Door;
import flixel.tile.FlxTilemap;
import jp_2dgames.game.token.Player;
import flash.system.System;
import jp_2dgames.game.gui.GameoverUI;
import jp_2dgames.game.gui.StageClearUI;
import jp_2dgames.game.particle.ParticleBmpFont;
import jp_2dgames.game.particle.Particle;
import flixel.FlxG;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.global.Global;

/**
 * 状態
 **/
private enum State {
  Init;
  Main;
  DeadWait;
  Gameover;
  Stageclear;
}

/**
 * メインゲーム画面
 **/
class PlayState extends FlxTransitionableState {

  // ---------------------------------------
  // ■フィールド
  var _state:State = State.Init;

  var _seq:SeqMgr;

  /**
   * 生成
   **/
  override public function create():Void {

    // 初期化
    Global.initLevel();

    // マップ読み込み
    Field.loadLevel(Global.level);

    // マップ作成
    var field = Field.createWallTile();
    this.add(field);

    // 一方通行床の作成
    Floor.createParent(this);

    // ブロック作成
    BrickBlock.createParent(this);

    // プレイヤー生成
    var player:Player;
    {
      var umbrella = new Umbrella();
      var pt = Field.getStartPosition();
      player = new Player(pt.x, pt.y, umbrella);
      this.add(player.light);
      this.add(player);
      this.add(umbrella);
      pt.put();
    }

    // 雨雲生成
    RainCloud.createParent(this);

    // 雨生成
    Raindrop.createParent(this);

    // 鉄球生成
    Spike.createParent(this);

    // ピット生成
    Pit.createParent(this);

    // ゴール
    var door:Door;
    {
      var pt = Field.getGoalPosition();
      door = new Door(pt.x, pt.y);
      this.add(door);
      pt.put();
    }

    // 各種オブジェクト生成
    Field.createObjects();

    // パーティクル生成
    Particle.createParent(this);
    ParticleBmpFont.createParent(this);

    // GUI生成
    this.add(new GameUI());

    // シーケンス管理生成
    _seq = new SeqMgr(player, field, door);

    // フォローカメラを設定
    FlxG.camera.follow(player, FlxCameraFollowStyle.PLATFORMER);
    // スクロールの有効範囲を設定
    FlxG.camera.setScrollBoundsRect(0, 0, field.width, field.height, true);

    // ドアを有効にする
    door.setEnable();

#if mobile
    // 仮想ゲームパッド有効
    Input.createVirtualPad(this, FULL, A_B);
#end
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    Floor.destroyParent();
    BrickBlock.destroyParent();
    RainCloud.destroyParent();
    Raindrop.destroyParent();
    Spike.destroyParent();
    Pit.destroyParent();
    Particle.destroyParent();
    ParticleBmpFont.destroyParent();
    Input.destroyVirtualPad();

    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    // 当たり判定は常に行う
    _seq.collide();

    switch(_state) {
      case State.Init:
        // ゲーム開始
        _updateInit();
        _state = State.Main;

      case State.Main:
        _updateMain();

      case State.DeadWait:
        // 死亡演出終了待ち

      case State.Gameover:
        // ゲームオーバー

      case State.Stageclear:
        // 次のレベルに進む
        StageClearUI.nextLevel();
    }

    #if debug
    _updateDebug();
    #end
  }

  /**
   * 更新・初期化
   **/
  function _updateInit():Void {
    // 開始演出
    ParticleStartLevel.start(this);
  }

  /**
   * 更新・メイン
   **/
  function _updateMain():Void {

    switch(_seq.proc()) {
      case SeqMgr.RET_DEAD:
        // ゲームオーバー
        _startGameover();
        return;
      case SeqMgr.RET_STAGECLEAR:
        // ステージクリア
        _state = State.Stageclear;
        Snd.stopMusic();
    }
  }

  /**
   * ゲームオーバー開始
   **/
  function _startGameover():Void {
    _state = State.Gameover;
    this.add(new GameoverUI(true));
  }

  // -----------------------------------------------
  // ■アクセサ

  /**
   * デバッグ
   **/
  function _updateDebug():Void {

#if debug
#if desktop
    if(FlxG.keys.justPressed.ESCAPE) {
      // 強制終了
      System.exit(0);
    }
    if(FlxG.keys.justPressed.R) {
      // リスタート
      FlxG.resetState();
//      FlxG.switchState(new PlayInitState());
    }
#end
#end
  }
}
