#◆◇◆◇◆ 明かりスクリプトVXA ver 1.10 ◇◆◇◆◇
#  サポート掲示板 http://www2.ezbbs.net/21/minto-aaa/
#   by みんと

=begin

※ 導入場所の注意

すべてモジュールで管理されていますので、
マスタースクリプトより下であれば導入場所は関係ありません。

■ 更新履歴

○ ver 1.10（2012/09/12）
スイッチでプレイヤーにも
明かりが表示されるように機能を追加

○ ver 1.00（2012/01/16）
公開

■ 説明

イベントに明かりを設定出来るようにします。
明かりは画面の色調よりも全面に出るため、
明かりの範囲内は明るく表示されます。

◆ 設定方法及び仕様

設定にはイベントの内容に
「どこでもいいので」注釈を置きます。
そして、注釈の内容を

◆ 明かり設定1

といったように"明かり設定の後"に"半角の数字"を記入してください。
記入した数字が、明かりデータの管理IDとなります。

明かりはイベントの不透明度と同期して強さが変化します。
イベントが完全に透明になれば明かりも完全に消えますので、
明かりを個別に消したい場合は、
移動ルートなどで対象イベントの不透明度を0にしてください。

また、新しいページに注釈で設定されていない場合も明かりは消えます。

◆ 画像の規格

明かりに使用する画像の規格は任意です。
ただし、1コマの規格は「画像の全体の横幅を4で割った値」となります。
つまり、640*160ピクセルの画像の場合、
1コマの規格は160*160となります。

画像は全て左から順に 0→1→2→3→0 と4コマループします。

明かり用の画像はピクチャーフォルダにインポートしてください。

=end

#==============================================================================
# ☆ MINTO
#------------------------------------------------------------------------------
#   様々なフラグを扱うメインモジュールです。
#==============================================================================

module MINTO
  
  # 明かりスクリプトVXAを有効化 （ true で有効 / false で無効 ）
  RGSS["明かりスクリプトVXA"] = true
  
end

# 明かりスクリプトVXAが有効な場合に以降の処理を実行する
if MINTO::RGSS["明かりスクリプトVXA"] == true then

#==============================================================================
# ☆ カスタマイズ
#------------------------------------------------------------------------------
#   機能のカスタマイズをここで行います。
#==============================================================================

module MINTO
  #--------------------------------------------------------------------------
  # ● プレイヤーに明かりを表示させるスイッチのID
  #     このIDのスイッチが ON の場合、プレイヤーに明かりを表示させます
  #--------------------------------------------------------------------------
  def self.player_light_switch
    # IDを返す
    return 1
  end
  #--------------------------------------------------------------------------
  # ● プレイヤーの明かりIDを管理する変数のID
  #     プレイヤーに明かりを表示させる際、
  #     このIDの変数の値に依存する管理IDの明かりを表示します
  #--------------------------------------------------------------------------
  def self.player_light_variables
    # IDを返す
    return 1
  end
  #--------------------------------------------------------------------------
  # ● プレイヤーの明かりの大きさを管理する変数のID
  #     プレイヤーに明かりを表示させる際、
  #     このIDの変数の値に明かりのズームを設定します（％方式）
  #--------------------------------------------------------------------------
  def self.player_light_zoom_variables
    # IDを返す
    return 2
  end
  #--------------------------------------------------------------------------
  # ● 明かりのセット
  #    belong_id : 明かりの管理ID
  #--------------------------------------------------------------------------
  def self.light_set(belong_id)
    # 明かりの管理IDに応じて分岐
    case belong_id
    when 1 then
      # data = [画像ファイル名, Y座標修正値, 大きさ(通常2。 小数点可)]
      data = ["stove", 0, 1]
    when 2 then
      data = ["Light_Sprite02", 0, 1]
    # それ以外の名前の場合
    else
      data = ["", 0, 1]
    end
    # 設定データを返す
    return data.dup
  end
end
#==============================================================================
# ☆ Add_Light_Sprite
#------------------------------------------------------------------------------
#   Sprite_Characterクラスに機能を追加するモジュールです。
#   明かりの機能を追加します。
#==============================================================================

module Add_Light_Sprite
  #--------------------------------------------------------------------------
  # ● 解放（明かり）
  #--------------------------------------------------------------------------
  def dispose_light
    # 明かりが存在する場合
    if @light_sprite != nil then
      # 明かりを解放
      @light_sprite.bitmap.dispose
      @light_sprite.dispose
      @light_sprite = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  def dispose
    # 明かりを解放
    dispose_light
    # 明かり可視フラグをクリア
    @character.light_visible = false
    # 明かり作成フラグをクリア
    @character.call_light = false
    # 最終ページ情報を解放
    @character.dispose_data
    # スーパークラスの処理に移行
    super
  end
  #--------------------------------------------------------------------------
  # ● 明かりの設定
  #    id : 明かりのID
  #--------------------------------------------------------------------------
  def light_set(id)
    # 明かりを解放
    dispose_light
    # 明かりを作成
    @light_sprite = Light_Sprite.new(self, id)
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # スーパークラスの処理に移行
    super
    # キャラクターが無効な場合
    if @character == nil then
      # メソッドを返す
      return
    end
    # 明かりデータを取得
    @character.get_light_data
    # 明かり可視フラグが無効な場合
    if @character.light_visible != true then
      # 明かりを解放
      dispose_light
      # メソッドを返す
      return
    end
    # 明かり作成フラグが有効な場合
    if @character.call_light == true then
      # 明かり作成フラグをオフにする
      @character.call_light = false
      # 明かりを作成
      light_set(@character.light_id)
    end
    # 明かりが無効な場合
    if @light_sprite == nil then
      # メソッドを返す
      return
    end
    # 明かりを更新
    @light_sprite.update
  end
end
#==============================================================================
# ☆ Add_Game_Event_Light
#------------------------------------------------------------------------------
#   Game_Eventクラスに機能を追加するモジュールです。
#   明かりの機能を追加します。
#==============================================================================

module Add_Game_Event_Light
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    # スーパークラスの処理に移行
    super
    @last_page_light = {}
  end
  #--------------------------------------------------------------------------
  # ● データのリセット
  #--------------------------------------------------------------------------
  def self.reset
    @last_page_light = {}
  end
  #--------------------------------------------------------------------------
  # ● データ解放
  #--------------------------------------------------------------------------
  def dispose_data
    # 無効なデータの場合
    if @last_page_light == nil then
      # データを初期化
      @last_page_light = {}
      # メソッドを返す
      return
    end
    # 自身のデータをクリア
    @last_page_light[self] = nil
  end
  #--------------------------------------------------------------------------
  # ● 拡張データの取得
  #--------------------------------------------------------------------------
  def get_light_data
    # プレイヤーの場合
    if self.is_a?(Game_Player)
      # 明かりが作成できる状態の場合
      if $game_switches[MINTO.player_light_switch] == true
        # 明かりが未作成の場合
        unless self.call_light
          # 明かりを作成
          self.light_id = $game_variables[MINTO.player_light_variables]
          self.light_visible = true
          self.call_light = true
        end
      # 明かりが作成できない状態の場合
      else
        # 明かりを消す
        self.light_visible = false
      end
      # メソッドを返す
      return
    end
    # 無効なデータの場合
    if @last_page_light == nil then
      # データを初期化
      @last_page_light = {}
    end
    # イベントページが更新されていない場合
    if @last_page_light[self] == @page then
      # データ未定義の場合
      if self.light_visible == nil then
        # 自身のデータをクリア
        @last_page_light[self] = nil
      end
      # メソッドを返す
      return
    end
    # 明かり可視フラグをクリア
    self.light_visible = false
    # 明かり作成フラグをクリア
    self.call_light = false
    # 最新のイベントページを記憶
    @last_page_light[self] = @page
    # イベントページが有効な場合
    if @page != nil then
      # イベントページに内容が存在する場合
      if @page.list != nil then
        # ループ処理（ページ内容）
        (0...@page.list.size).each do |i|
          # 注釈の場合
          if @page.list[i].code == 108 or @page.list[i].code == 408 then
            # 注釈内ループ処理
            (0...@page.list[i].parameters.size).each do |id|
              # 注釈のコードを取得
              code = @page.list[i].parameters[id].dup.to_s
              code.gsub!(/明かり設定/) {""}
              # 明かりのIDを取得
              light_id = code.to_i
              # 明かりのIDが有効な場合
              if light_id >= 1 then
                # 明かりIDを記憶
                self.light_id = light_id
                # 明かり可視フラグをオンにする
                self.light_visible = true
                # 明かりを作成フラグをオンにする
                self.call_light = true
                # メソッドを返す
                return
              end
            end
          end
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # スーパークラスの処理に移行
    super
  end
end
#==============================================================================
# ■ Light_Sprite
#------------------------------------------------------------------------------
#    マップでの明かりを管理するスプライトクラスです。
#==============================================================================

class Light_Sprite < Sprite
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :name                     # 明かりに使う画像
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #    character  : 対象キャラクター
  #    event_name : イベントの名前
  #--------------------------------------------------------------------------
  def initialize(character, event_name)
    # スーパークラスを実行
    super()
    # 明かりのデータを取得
    @data = MINTO.light_set(event_name)
    # ファイルネームを読み込む
    @name = @data[0].dup
    # スプライトを保存
    @character = character
    # 明かり用のビットマップを作成
    self.bitmap = Cache.picture(@name).dup
    @width = self.bitmap.width / 4
    @height = self.bitmap.height
    # 基本座標をセット
    self.x = @character.x
    self.y = @character.y
    self.z = 999
    # 転移座標をセット
    self.ox = @width / 2
    self.oy = @height / 2
    # 透明でない限りは明かりを表示させる
    self.visible = (@character.opacity != 0)
    # 明かりの不透明度を設定
    self.opacity = (@character.opacity / 2) + 32
    # 明かりを加算表示にする
    self.blend_type = 1
    # 明かりをズームさせる
    self.zoom = @data[2]
    # ブリンクカウントを初期化
    @blink_count = 0
    # フレーム更新
    update
  end
  #--------------------------------------------------------------------------
  # ● データのセット
  #    name : 設定データの名前
  #--------------------------------------------------------------------------
  def set_data(name)
    # 設定データを更新
    @data = MINTO.light_set(name)
    # ビットマップを解放
    bitmap_dispose
    # 明かり用のビットマップを再作成
    self.bitmap = Cache.picture(@data[0]).dup
    self.oy = @data[1]
    self.zoom = @data[2]
  end
  #--------------------------------------------------------------------------
  # ● ズーム
  #    n : ズーム倍率
  #--------------------------------------------------------------------------
  def zoom=(n)
    self.zoom_x = n
    self.zoom_y = n
  end
  #--------------------------------------------------------------------------
  # ● ビットマップの解放
  #--------------------------------------------------------------------------
  def bitmap_dispose
    unless self.bitmap.nil?
      self.bitmap.dispose
      self.bitmap = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  def dispose
    # ビットマップを解放
    bitmap_dispose
    # スーパークラスを実行
    super
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    # 基本情報を更新
    self.x = @character.character.screen_x
    self.y = @character.character.screen_y + @data[1]
    # プレイヤーの場合
    if @character.character.is_a?(Game_Player)
      # 明かりの大きさを変動させる
      self.zoom = $game_variables[MINTO.player_light_zoom_variables] / 100.0
    end
    # 透明でない限りは明かりを表示させる
    self.visible = (@character.character.opacity != 0)
    # 明かりの不透明度を設定
    self.opacity = (@character.character.opacity / 2) + 32
    # 点滅カウントを更新
    @blink_count = (@blink_count + 1) % 48
    # 転送元の矩形を設定
    case @blink_count
    when 0...12 then
      self.src_rect.set(@width * 0, 0, @width, @height)
    when 12...24 then
      self.src_rect.set(@width * 1, 0, @width, @height)
    when 24...36 then
      self.src_rect.set(@width * 2, 0, @width, @height)
    else
      self.src_rect.set(@width * 3, 0, @width, @height)
    end
  end
end
#==============================================================================
# ■ Game_Event
#------------------------------------------------------------------------------
# 　イベントを扱うクラスです。条件判定によるイベントページ切り替えや、並列処理
# イベント実行などの機能を持っており、Game_Map クラスの内部で使用されます。
#==============================================================================

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # ● システムインクルード
  #--------------------------------------------------------------------------
  include(Add_Game_Event_Light)           # 明かり管理モジュール
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :event                    # イベント
  attr_accessor :light_id                 # 明かりのID
  attr_accessor :light_visible            # 明かり可視フラグ
  attr_accessor :call_light               # 明かり実行フラグ
end
#==============================================================================
# ■ Game_Vehicle
#------------------------------------------------------------------------------
# 　乗り物を扱うクラスです。このクラスは Game_Map クラスの内部で使用されます。
# 現在のマップに乗り物がないときは、マップ座標 (-1,-1) に設定されます。
#==============================================================================

class Game_Vehicle < Game_Character
  #--------------------------------------------------------------------------
  # ● システムインクルード
  #--------------------------------------------------------------------------
  include(Add_Game_Event_Light)           # 明かり管理モジュール
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :event                    # イベント
  attr_accessor :light_id                 # 明かりのID
  attr_accessor :light_visible            # 明かり可視フラグ
  attr_accessor :call_light               # 明かり実行フラグ
end
#==============================================================================
# ■ Game_Player
#------------------------------------------------------------------------------
# 　プレイヤーを扱うクラスです。イベントの起動判定や、マップのスクロールなどの
# 機能を持っています。このクラスのインスタンスは $game_player で参照されます。
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # ● システムインクルード
  #--------------------------------------------------------------------------
  include(Add_Game_Event_Light)           # 明かり管理モジュール
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :event                    # イベント
  attr_accessor :light_id                 # 明かりのID
  attr_accessor :light_visible            # 明かり可視フラグ
  attr_accessor :call_light               # 明かり実行フラグ
end
#==============================================================================
# ■ Game_Follower
#------------------------------------------------------------------------------
# 　フォロワーを扱うクラスです。フォロワーとは、隊列歩行で表示する、先頭以外の
# 仲間キャラクターのことです。Game_Followers クラスの内部で参照されます。
#==============================================================================

class Game_Follower < Game_Character
  #--------------------------------------------------------------------------
  # ● システムインクルード
  #--------------------------------------------------------------------------
  include(Add_Game_Event_Light)           # 明かり管理モジュール
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :event                    # イベント
  attr_accessor :light_id                 # 明かりのID
  attr_accessor :light_visible            # 明かり可視フラグ
  attr_accessor :call_light               # 明かり実行フラグ
end
#==============================================================================
# ■ Game_Subplayer
#------------------------------------------------------------------------------
# 　サブプレイヤーを扱うクラスです。
# このクラスのインスタンスは $game_subplayer1～3で参照されます。
# Game_Playerクラスを元に作っています
#==============================================================================

class Game_Subplayer < Game_Character
  #--------------------------------------------------------------------------
  # ● システムインクルード
  #--------------------------------------------------------------------------
  include(Add_Game_Event_Light)           # 明かり管理モジュール
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :event                    # イベント
  attr_accessor :light_id                 # 明かりのID
  attr_accessor :light_visible            # 明かり可視フラグ
  attr_accessor :call_light               # 明かり実行フラグ
end
#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　イベントコマンドを実行するインタプリタです。このクラスは Game_Map クラス、
# Game_Troop クラス、Game_Event クラスの内部で使用されます。
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 場所移動
  #--------------------------------------------------------------------------
  alias :command_201_Light_Sprite :command_201
  def command_201
    # 元の処理を実行
    bool = command_201_Light_Sprite
    # 明かりのデータを初期化
    Add_Game_Event_Light.reset
    # フラグを返す
    return bool
  end
end
#==============================================================================
# ■ Sprite_Character
#------------------------------------------------------------------------------
# 　キャラクター表示用のスプライトです。Game_Character クラスのインスタンスを
# 監視し、スプライトの状態を自動的に変化させます。
#==============================================================================

class Sprite_Character < Sprite_Base
  #--------------------------------------------------------------------------
  # ● システムインクルード
  #--------------------------------------------------------------------------
  include(Add_Light_Sprite)               # 明かりモジュール
end

end
