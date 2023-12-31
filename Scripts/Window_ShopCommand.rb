#==============================================================================
# ■ Window_ShopCommand
#------------------------------------------------------------------------------
# 　ショップ画面で、購入／売却を選択するウィンドウです。
#==============================================================================

class Window_ShopCommand < Window_HorzCommand
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(window_width, purchase_only)
    @window_width = window_width
    @purchase_only = purchase_only
    super(0, 0)
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    @window_width = 210
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::ShopBuy,    :buy)
    add_command(Vocab::ShopCancel, :cancel)
  end
end
