package jp_2dgames.game.state;

import jp_2dgames.game.token.Umbrella;
import jp_2dgames.game.token.Door;
import flixel.tile.FlxTilemap;
import jp_2dgames.game.token.Player;
import flash.system.System;
import jp_2dgames.game.gui.GameoverUI;
import flixel.FlxState;
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
class PlayState extends FlxState {

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

    // ゴール
    var door:Door;
    {
      var pt = Field.getGoalPosition();
      door = new Door(pt.x, pt.y);
      this.add(door);
      pt.put();
    }

    // パーティクル生成
    Particle.createParent(this);
    ParticleBmpFont.createParent(this);

    // シーケンス管理生成
    _seq = new SeqMgr(player, field, door);

    // ドアを有効にする
    door.setEnable();
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {

    Particle.destroyParent();
    ParticleBmpFont.destroyParent();

    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

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
  }
}
