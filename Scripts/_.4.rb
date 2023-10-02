#******************************************************************************
#
#    ＊ スタートマップ
#
#  --------------------------------------------------------------------------
#    バージョン ：  1.0.0
#    対      応 ：  RPGツクールVX Ace : RGSS3
#    制  作  者 ：  ＣＡＣＡＯ
#    配  布  元 ：  http://cacaosoft.web.fc2.com/
#  --------------------------------------------------------------------------
#   == 概    要 ==
#
#   ： タイトル画面の代わりに指定されたマップを表示します。
#
#  --------------------------------------------------------------------------
#   == 注意事項 ==
#
#    ※ 初期配置は、空パーティで (0,0) 座標となります。
#    ※ イベントコマンド「タイトル画面へ戻す」は、スタートマップへ戻ります。
#    ※ メニュー画面のタイトルへ戻る処理は、スタートマップへ戻ります。
#
#  --------------------------------------------------------------------------
#   == 使用方法 ==
#
#    ★ スタートマップでの初期位置
#     イベント名を 初期位置 として、イベントを配置してください。
#
#    ★ タイトル画面の処理
#     イベントコマンド「スクリプト」で実行してください。
#       GameManager.new_game    ニューゲーム
#       GameManager.continue    コンティニュー
#       GameManager.shutdown    シャットダウン
#
#    ★ タイトル画面の表示
#     イベントコマンド「スクリプト」で実行してください。
#       GameManager.title
#
#    ★ 判定
#     イベントコマンド「条件分岐」のスクリプトで実行してください。
#       GameManager.first?      一度目か
#       GameManager.continue?   セーブファイルがあるか
#
#
#******************************************************************************


#==============================================================================
# ◆ 設定項目
#==============================================================================
module CAO
module StartMap
  
  #--------------------------------------------------------------------------
  # ◇ 開始マップ
  #--------------------------------------------------------------------------
  #     2 .. 動作確認用
  #     3 .. イベント サンプル
  #     4 .. ピクチャ サンプル
  #     5 .. ロゴ表示 サンプル
  #--------------------------------------------------------------------------
  START_MAP_ID = 28
  #--------------------------------------------------------------------------
  # ◇ ２度目はスタートマップをスキップ
  #--------------------------------------------------------------------------
  RESET_SKIP = false
  #--------------------------------------------------------------------------
  # ◇ メニュー禁止
  #--------------------------------------------------------------------------
  MENU_DISABLED = true
  
end # module StartMap
end # module CAO


#/////////////////////////////////////////////////////////////////////////////#
#                                                                             #
#                下記のスクリプトを変更する必要はありません。                 #
#                                                                             #
#/////////////////////////////////////////////////////////////////////////////#


class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ● 初期パーティのセットアップ
  #--------------------------------------------------------------------------
  def setup_startmap_members
    @actors = []
  end
end

module DataManager
  PAT_START_MAP = /^初期配置$/
  #--------------------------------------------------------------------------
  # ● ニューゲームのセットアップ
  #--------------------------------------------------------------------------
  def self.setup_startmap
    RPG::BGM.stop
    RPG::BGS.stop
    RPG::ME.stop
    GameManager.executed = true if GameManager.executed == false
    GameManager.executed = false if GameManager.executed == nil
    create_game_objects
    $game_party.setup_startmap_members
    $game_map.setup(CAO::StartMap::START_MAP_ID)
    $game_map.autoplay
    $game_player.moveto(0, 0)
    $game_player.refresh
    $game_map.events.values do |ev|
      event = ev.instance_variable_get(:@event)
      next unless event.name[PAT_START_MAP]
      ev.erase
      $game_player.moveto(event.x, event.y)
      set_start_map_player(event.pages[1])        # ２ページ目
      break
    end
    $game_system.menu_disabled = CAO::StartMap::MENU_DISABLED
    Graphics.frame_count = 0
  end
  #--------------------------------------------------------------------------
  # ● プレイヤーグラフィックの設定
  #--------------------------------------------------------------------------
  def self.set_start_map_player(page)
    return if page == nil
    $game_player.instance_variable_set(     # タイルＩＤ
      :@tile_id, page.graphic.tile_id)
    $game_player.instance_variable_set(     # ファイル名
      :@character_name, page.graphic.character_name)
    $game_player.instance_variable_set(     # インデックス
      :@character_index, page.graphic.character_index)
    $game_player.instance_variable_set(     # 歩行アニメ
      :@walk_anime, page.walk_anime)
    $game_player.instance_variable_set(     # 足踏みアニメ
      :@walk_anime, page.step_anime)
    $game_player.instance_variable_set(     # 向き固定
      :@direction_fix, page.direction_fix)
    $game_player.instance_variable_set(     # すり抜け
      :@through, page.through)
  end
end

module SceneManager
  #--------------------------------------------------------------------------
  # ○ 実行
  #--------------------------------------------------------------------------
  def self.run
    DataManager.init
    Audio.setup_midi if use_midi?
    if $BTEST || CAO::StartMap::RESET_SKIP && !GameManager.first?
     @scene = first_scene_class.new
    else
      DataManager.setup_startmap
      @scene = Scene_Map.new
    end
    @scene.main while @scene
  end
end

module GameManager; end
class << GameManager
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  attr_accessor :executed
  #--------------------------------------------------------------------------
  # ● ニューゲーム
  #--------------------------------------------------------------------------
  def new_game
    DataManager.setup_new_game
    SceneManager.scene.fadeout_all
    $game_map.autoplay
    SceneManager.goto(Scene_Map)
  end
  #--------------------------------------------------------------------------
  # ● コンティニュー
  #--------------------------------------------------------------------------
  def continue
    SceneManager.call(Scene_Load)
  end
  #--------------------------------------------------------------------------
  # ● シャットダウン
  #--------------------------------------------------------------------------
  def shutdown
    SceneManager.scene.fadeout_all
    SceneManager.exit
  end
  #--------------------------------------------------------------------------
  # ● タイトル
  #--------------------------------------------------------------------------
  def title
    # Scene_Map#pre_title_scene の処理を消してからタイトルへ移動
    SceneManager.scene.instance_eval('def pre_title_scene; end')
    SceneManager.goto(Scene_Title)
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def first?
    return !@executed
  end
  #--------------------------------------------------------------------------
  # ● 
  #--------------------------------------------------------------------------
  def continue?
    return DataManager.save_file_exists?
  end
end

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ○ タイトル画面に戻す
  #--------------------------------------------------------------------------
  alias _cao_startmap_command_354 command_354
  def command_354
    return _cao_startmap_command_354 if CAO::StartMap::RESET_SKIP
    screen.start_fadeout(60)
    wait(60)
    DataManager.setup_startmap
    SceneManager.goto(Scene_Map)
    Fiber.yield
  end
end

class Scene_End < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ○ コマンド［タイトルへ］
  #--------------------------------------------------------------------------
  alias _cao_startmap_command_to_title command_to_title
  def command_to_title
    return _cao_startmap_command_to_title if CAO::StartMap::RESET_SKIP
    close_command_window
    fadeout_all
    DataManager.setup_startmap
    SceneManager.goto(Scene_Map)
  end
end
