package jp_2dgames.game;

import jp_2dgames.game.token.RainCloud;
import flixel.FlxObject;
import jp_2dgames.game.token.Raindrop;
import jp_2dgames.game.token.BrickBlock;
import flixel.group.FlxGroup;
import flixel.FlxBasic;
import jp_2dgames.lib.DirUtil.Dir;
import jp_2dgames.game.token.Umbrella;
import jp_2dgames.game.token.Floor;
import jp_2dgames.game.token.Door;
import jp_2dgames.game.token.Player;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tile.FlxTilemap;

/**
 * 状態
 **/
private enum State {
  Init;       // 初期化
  Main;       // メイン
  Dead;       // 死亡
  StageClear; // ステージクリア
}

/**
 * シーケンス管理
 **/
class SeqMgr {

  public static var RET_NONE:Int    = 0;
  public static var RET_DEAD:Int    = 3; // プレイヤー死亡
  public static var RET_STAGECLEAR:Int  = 5; // ステージクリア

  var _state:State;
  var _bDead:Bool = false;
  var _bStageClear:Bool = false;

  var _terrain:FlxGroup; // 地形グループ

  var _player:Player;
  var _walls:FlxTilemap;
  var _door:Door;

  /**
   * コンストラクタ
   **/
  public function new(player:Player, walls:FlxTilemap, door:Door) {
    _state = State.Init;

    _player = player;
    _walls = walls;
    _door = door;

    // 地形グループに登録
    _terrain = new FlxGroup();
    _terrain.add(_walls);
    _terrain.add(BrickBlock.parent);
  }

  /**
   * 更新
   **/
  public function proc():Int {

    var ret = RET_NONE;

    switch(_state) {
      case State.Init:
        // 初期化
        _state = State.Main;
      case State.Main:
        // メイン
        _updateMain();
      case State.Dead:
        // プレイヤー死亡
        return RET_DEAD;
      case State.StageClear:
        // ステージクリア
        return RET_STAGECLEAR;
    }

    return RET_NONE;
  }

  /**
   * 当たり判定
   **/
  public function collide():Void {
    // プレイヤー vs Any
    FlxG.collide(_player, _terrain);
    FlxG.overlap(_player, Raindrop.parent, _PlayerVsRaindrop);

    if(_player.umbrella.isOpen()) {
      // 床と傘の当たり判定
      var xgrid = Field.toGridX(_player.umbrella.xcenter);
      var ygrid = Field.toGridY(_player.umbrella.ycenter);
      var tile = _walls.getTile(xgrid, ygrid);
      if(tile > 0) {
        _UmbrellaVsWall(_player.umbrella, xgrid, ygrid);
      }
      FlxG.overlap(_player.umbrella, BrickBlock.parent, _UmbrellaVsBrickBlock);
      FlxG.overlap(_player.umbrella, Raindrop.parent, _UmbrellaVsRain);
    }

    // 雨 vs 地形
    FlxG.collide(Raindrop.parent, _terrain, _RainVsTerrain);

    //    FlxG.collide(_player, Floor.parent, _PlayerVsFloor);
    FlxG.overlap(_player, _door.spr, _PlayerVsDoor);

  }

  /**
   * 更新・メイン
   **/
  function _updateMain():Void {

    if(_player.y < 0 || _walls.height < _player.y) {
      // 画面外で死亡
      _player.damage(9999);
    }
    if(_player.exists == false) {
      // プレイヤー死亡
      _bDead = true;
    }

    if(_bDead) {
      // 死亡
      _state = State.Dead;
    }
    else if(_bStageClear) {
      // ステージクリア
      _state = State.StageClear;
    }
  }

  // プレイヤー vs 雨
  function _PlayerVsRaindrop(player:Player, rain:Raindrop):Void {
    rain.vanish();
    player.damage(40);
  }

  // 傘 vs カベ
  function _UmbrellaVsWall(umbrella:Umbrella, xgrid:Int, ygrid:Int):Void {
    if(umbrella.dir == Dir.Down) {
      // 傘を消す
      umbrella.close();
      _player.jumpByUmbrella();
    }
  }

  // 傘 vs レンガブロック
  function _UmbrellaVsBrickBlock(umbrella:Umbrella, block:BrickBlock):Void {
    // ブロック破壊
    block.vanish();
    if(umbrella.dir == Dir.Down) {
      // 傘閉じる
      umbrella.close();
    }
    // ジャンプ
    _player.jumpByUmbrella();
  }

  // 傘 vs 雨
  function _UmbrellaVsRain(umbrella:Umbrella, rain:Raindrop):Void {
    // 雨を消す
    rain.vanish();
  }

  // 雨 vs 地形
  function _RainVsTerrain(rain:Raindrop, terrain:FlxObject):Void {
    // 雨を消す
    rain.vanish();
  }

  // プレイヤー vs 一方通行床
  function _PlayerVsFloor(player:Player, floor:Floor):Void {
  }

  // プレイヤー vs ゴール
  function _PlayerVsDoor(player:Player, door:FlxSprite):Void {
    // ステージクリア
    _bStageClear = true;
  }
}
