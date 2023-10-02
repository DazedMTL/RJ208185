#==============================================================================
# ■ Window_MapName
#------------------------------------------------------------------------------
# 　マップ名を表示するウィンドウです。
#==============================================================================

class Window_MapName < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, window_width, fitting_height(1))
    self.opacity = 0
    self.contents_opacity = 0
    @show_count = 0
    refresh
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 240
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    if @show_count > 0 && $game_map.name_display
      update_fadein
      @show_count -= 1
    else
      update_fadeout
    end
  end
  #--------------------------------------------------------------------------
  # ● フェードインの更新
  #--------------------------------------------------------------------------
  def update_fadein
    self.contents_opacity += 16
  end
  #--------------------------------------------------------------------------
  # ● フェードアウトの更新
  #--------------------------------------------------------------------------
  def update_fadeout
    self.contents_opacity -= 16
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウを開く
  #--------------------------------------------------------------------------
  def open
    refresh
    @show_count = 150
    self.contents_opacity = 0
    self
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウを閉じる
  #--------------------------------------------------------------------------
  def close
    @show_count = 0
    self
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    unless $game_map.display_name.empty?
      draw_background(contents.rect)
      draw_text(contents.rect, $game_map.display_name, 1)
    end
  end
  #--------------------------------------------------------------------------
  # ● 背景の描画
  #--------------------------------------------------------------------------
  def draw_background(rect)
    temp_rect = rect.clone
    temp_rect.width /= 2
    contents.gradient_fill_rect(temp_rect, back_color2, back_color1)
    temp_rect.x = temp_rect.width
    contents.gradient_fill_rect(temp_rect, back_color1, back_color2)
  end
  #--------------------------------------------------------------------------
  # ● 背景色 1 の取得
  #--------------------------------------------------------------------------
  def back_color1
    Color.new(0, 0, 0, 192)
  end
  #--------------------------------------------------------------------------
  # ● 背景色 2 の取得
  #--------------------------------------------------------------------------
  def back_color2
    Color.new(0, 0, 0, 0)
  end
end