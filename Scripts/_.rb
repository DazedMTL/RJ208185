#◆◇◆◇◆  マスタースクリプトVXA ver 1.00  ◇◆◇◆◇
#  サポート掲示板 http://www2.ezbbs.net/21/minto-aaa/
#   by みんと

=begin

■ 更新履歴

○ Ver 1.00（2012/01/16）
公開

■ 説明

全てのみんとRGSSより上に導入してください。
(基本的にシステム上部に導入してください)

これがないと全てのみんとRGSS3は動作いたしません。

=end

#==============================================================================
# ☆ MINTO
#------------------------------------------------------------------------------
#   様々なフラグを扱うメインモジュールです。
#==============================================================================

module MINTO
  
  # VXRGSSの導入環境ハッシュを初期化
  RGSS = {}
  
end

#==============================================================================
# ☆ MINTO_System
#------------------------------------------------------------------------------
#   様々な機能を扱うシステムモジュールです。
#==============================================================================

module MINTO_System
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    @tone_rate = 0
    # シーンスプライトを作成
    @scene_sprite = Sprite_Base.new
    # スーパークラスを実行
    super
  end
  #--------------------------------------------------------------------------
  # ● トランジション実行
  #--------------------------------------------------------------------------
  def perform_transition
    # スーパークラスを実行
    super
  end
  #--------------------------------------------------------------------------
  # ● 開始後処理
  #--------------------------------------------------------------------------
  def post_start
    # スーパークラスを実行
    super
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # シーンスプライトを更新
    @scene_sprite.update
    # スーパークラスを実行
    super
  end
  #--------------------------------------------------------------------------
  # ● 終了前処理
  #--------------------------------------------------------------------------
  def pre_terminate
    # スーパークラスを実行
    super
  end
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  def terminate
    # シーンスプライトを解放
    @scene_sprite.bitmap.dispose if @scene_sprite.bitmap
    @scene_sprite.dispose
    @scene_sprite = nil
    # スーパークラスを実行
    super
  end
end

# ☆ 開発用メソッド追加 ☆

#==============================================================================
# ■ Scene_Base
#------------------------------------------------------------------------------
# 　ゲーム中のすべてのシーンのスーパークラスです。
#==============================================================================

class Scene_Base
  #--------------------------------------------------------------------------
  # ● 暗転モード処理
  #--------------------------------------------------------------------------
  def blackout(type = 0, power = 10, max = 100, sprite = nil)
    @tone_power = power
    @tone_type = type
    @tone_max = max
    update_blackout(sprite)
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (暗転処理)
  #--------------------------------------------------------------------------
  def update_blackout(sprite)
    case @tone_type
    when 0
      if @tone_rate != -@tone_max
        @tone_rate = [@tone_rate - @tone_power, -@tone_max].max
        sprite.tone.red = @tone_rate
        sprite.tone.green = @tone_rate
        sprite.tone.blue = @tone_rate
      end
    when 1
      if @tone_rate != 0
        @tone_rate = [@tone_rate + @tone_power, 0].min
        sprite.tone.red = @tone_rate
        sprite.tone.green = @tone_rate
        sprite.tone.blue = @tone_rate
      end
    end
  end
end
#==============================================================================
# ■ Object
#------------------------------------------------------------------------------
# 　全てのクラスのスーパークラス。オブジェクトの一般的な振舞いを定義します。
#==============================================================================

class Object
  #--------------------------------------------------------------------------
  # ● 深い複製の作成
  #--------------------------------------------------------------------------
  def dec
    # Marshalもモジュールを経由して、完全な複製を作成
    return Marshal.load(Marshal.dump(self))
  end
end
#==============================================================================
# ■ NilClass
#------------------------------------------------------------------------------
# 　nil のクラス。nil は NilClass クラスの唯一のインスタンスです。
#==============================================================================

class NilClass
  #--------------------------------------------------------------------------
  # ● デバイスの取得
  #--------------------------------------------------------------------------
  def to_d
    return "BGM"
  end
end
#==============================================================================
# ■ String
#------------------------------------------------------------------------------
# 　文字列クラス。任意の長さのバイト列を扱うことができます。
#==============================================================================

class String
  #--------------------------------------------------------------------------
  # ● デバイスの取得
  #--------------------------------------------------------------------------
  def to_d
    return self
  end
end
#==============================================================================
# ■ Audio
#------------------------------------------------------------------------------
# 　ミュージック、サウンドにかかわる処理を行うモジュールです。
#==============================================================================

module Audio
  #--------------------------------------------------------------------------
  # ● 音楽の解放
  #--------------------------------------------------------------------------
  def self.dispose
    #self.bgs_stop
    self.me_stop
    self.bgm_stop
  end
end
#==============================================================================
# ■ Sprite
#------------------------------------------------------------------------------
# 　スプライト表示を扱う組み込みクラスです。
#==============================================================================

class Sprite
  #--------------------------------------------------------------------------
  # ● 座標の設定
  #--------------------------------------------------------------------------
  def rect_set(x, y, z = 100)
    self.x = x if x
    self.y = y if y
    self.z = z if z
  end
  #--------------------------------------------------------------------------
  # ● データの取得
  #--------------------------------------------------------------------------
  def data_copy(data)
    return if data.disposed? or self.disposed?
    # 各データをコピー
    self.x = data.x
    self.y = data.y
    self.z = data.z-1
    self.visible = data.visible
    self.ox = data.ox
    self.oy = data.oy
    self.angle = data.angle
    self.mirror = data.mirror
    self.src_rect = data.src_rect.dup
    self.zoom_x = data.zoom_x
    self.zoom_y = data.zoom_y
  end
  #--------------------------------------------------------------------------
  # ● 残像用の複製の作成
  #--------------------------------------------------------------------------
  def blink
    # 各データをコピー
    sprite = Sprite.new(self.viewport)
    sprite.bitmap = self.bitmap.dup if self.bitmap
    sprite.x = self.x
    sprite.y = self.y
    sprite.z = self.z-1
    sprite.visible = false
    sprite.ox = self.ox
    sprite.oy = self.oy
    sprite.angle = self.angle
    sprite.mirror = self.mirror
    sprite.opacity = self.opacity - 95
    sprite.blend_type = 1
    sprite.color = self.color.dup
    sprite.src_rect = self.src_rect.dup
    sprite.zoom_x = self.zoom_x
    sprite.zoom_y = self.zoom_y
    return sprite
  end
  #--------------------------------------------------------------------------
  # ● 複製の作成
  #--------------------------------------------------------------------------
  def dup
    # 各データをコピー
    sprite = Sprite.new(self.viewport)
    sprite.bitmap = self.bitmap.dup if self.bitmap
    sprite.x = self.x
    sprite.y = self.y
    sprite.z = self.z
    sprite.visible = self.visible
    sprite.ox = self.ox
    sprite.oy = self.oy
    sprite.angle = self.angle
    sprite.mirror = self.mirror
    sprite.opacity = self.opacity
    sprite.blend_type = self.blend_type
    sprite.color = self.color.dup
    sprite.src_rect = self.src_rect.dup
    sprite.zoom_x = self.zoom_x
    sprite.zoom_y = self.zoom_y
    return sprite
  end
  #--------------------------------------------------------------------------
  # ● センタリング
  #--------------------------------------------------------------------------
  def centering
    return if self.bitmap == nil
    self.x = (640 - (self.bitmap.width * self.zoom_x)) / 2
    self.y = (480 - (self.bitmap.height * self.zoom_y)) / 2
  end
  #--------------------------------------------------------------------------
  # ● ズーム
  #--------------------------------------------------------------------------
  def zoom=(n)
    zoom_x = n
    zoom_y = n
  end
  #--------------------------------------------------------------------------
  # ● エフェクト表示中判定
  #--------------------------------------------------------------------------
  def effect?
    return false
  end
end
#==============================================================================
# ■ Array
#------------------------------------------------------------------------------
# 　配列全般を扱う組み込みクラスです。
#==============================================================================

class Array
  #--------------------------------------------------------------------------
  # ● 要素の一次元化
  #--------------------------------------------------------------------------
  def divide
    array = []
    # データを複製
    data = self.dup
    # 要素の一次元化
    data.each do |i|
      if i.is_a?(Array)
        for a in i
          array.push(a)
        end
      else
        array.push(i)
      end
    end
    return array
  end
  #--------------------------------------------------------------------------
  # ● 要素のシャッフル
  #--------------------------------------------------------------------------
  def shuffle
    # データを複製
    data = self.dup
    # 要素をランダムに並び替える
    data.each_index do |i|
      j = rand(i+1)
      data[i], data[j] = data[j], data[i]
    end
    return data
  end
  #--------------------------------------------------------------------------
  # ● 要素のシャッフル（破壊的）
  #--------------------------------------------------------------------------
  def shuffle!
    # 要素をランダムに並び替える
    self.each_index do |i|
      j = rand(i+1)
      self[i], self[j] = self[j], self[i]
    end
  end
  #--------------------------------------------------------------------------
  # ● 要素をランダムに返す
  #--------------------------------------------------------------------------
  def get_rand
    return self[rand(self.size)]
  end
  #--------------------------------------------------------------------------
  # ● 要素の交換
  #    a : 要素1
  #    b : 要素2
  #--------------------------------------------------------------------------
  def change(a, b)
    # データを複製
    data = self.dup
    # 要素を交換する（self自体には変化がない）
    data[a] = self[b]
    data[b] = self[a]
    return data
  end
  #--------------------------------------------------------------------------
  # ● 要素の交換（破壊的）
  #    a : 要素1
  #    b : 要素2
  #--------------------------------------------------------------------------
  def change!(a, b)
    # 要素を交換する（selfを直接書き換える）
    self[a], self[b] = self[b], self[a]
  end
end
#==============================================================================
# ■ Numeric
#------------------------------------------------------------------------------
# 　数値全般を扱う組み込みクラスです。
#==============================================================================

class Numeric
  #--------------------------------------------------------------------------
  # ● 乱数の設定
  #    n : 乱数値
  #--------------------------------------------------------------------------
  def amp(n)
    amp = (self.abs * n / 100).to_min(1)
    return self + rand(amp+1) + rand(amp+1) - amp
  end
  #--------------------------------------------------------------------------
  # ● 値の調整
  #    order : 求められた値
  #    size  : 最大サイズ
  #--------------------------------------------------------------------------
  def select(order, size)
    if self - order <= -1
      return size
    elsif self + order >= size
      return 0
    else
      return self + order
    end
  end
  #--------------------------------------------------------------------------
  # ● 最大値の設定
  #    max : 求められた最大の数値
  #--------------------------------------------------------------------------
  def to_max(min, max)
    if self > max
      return max
    elsif self < min
      return min
    else
      return self
    end
  end
  #--------------------------------------------------------------------------
  # ● 最大値の設定
  #    max : 求められた最大の数値
  #--------------------------------------------------------------------------
  def to_m(max)
    if self > max
      return max
    else
      return self
    end
  end
  #--------------------------------------------------------------------------
  # ● 最小値の設定
  #    min : 求められた最小の数値
  #--------------------------------------------------------------------------
  def to_min(min)
    if self < min
      return min
    else
      return self
    end
  end
  #--------------------------------------------------------------------------
  # ● 範囲内から乱数を得る
  #    min : 求められた最小の数値
  #--------------------------------------------------------------------------
  def mm_rand(min)
    return rand(self - min + 1) + min
  end
  #--------------------------------------------------------------------------
  # ● 求めた数値に対するパーセンテージを返す
  #    order : 求められた数値
  #--------------------------------------------------------------------------
  def rate(order)
    return 100 if order == 0
    return (self * 100) / order
  end
end
#==============================================================================
# ■ Window
#------------------------------------------------------------------------------
# 　ゲーム内の全てのウィンドウのスーパークラスです。
#   内部的には複数のスプライトで構成されています。
#==============================================================================

class Window
  #--------------------------------------------------------------------------
  # ● 暗転モード処理
  #--------------------------------------------------------------------------
  def blackout(type = 0, power = 10, max = 100, sprite = @win_viewport)
    @tone_power = power
    @tone_type = type
    @tone_max = max
    update_blackout(sprite)
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新 (暗転処理)
  #--------------------------------------------------------------------------
  def update_blackout(sprite = @win_viewport)
    case @tone_type
    when 0
      if @tone_rate != -@tone_max
        @tone_rate = [@tone_rate - @tone_power, -@tone_max].max
        sprite.tone.red = @tone_rate
        sprite.tone.green = @tone_rate
        sprite.tone.blue = @tone_rate
      end
    when 1
      if @tone_rate != 0
        @tone_rate = [@tone_rate + @tone_power, 0].min
        sprite.tone.red = @tone_rate
        sprite.tone.green = @tone_rate
        sprite.tone.blue = @tone_rate
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウの右寄せ
  #--------------------------------------------------------------------------
  def right(x)
    # ウィンドウを画面の右に配置する
    self.x = (x - self.width)
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウの下寄せ
  #--------------------------------------------------------------------------
  def down(y)
    # ウィンドウを画面の右に配置する
    self.y = (480 - self.height - y)
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウのセンタリング
  #--------------------------------------------------------------------------
  def centering
    # ウィンドウを画面の中央に配置する
    self.x = (640 - self.width)  / 2
    self.y = (480 - self.height) / 2
  end
end