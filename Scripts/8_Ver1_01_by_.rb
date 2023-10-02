
#==============================================================================
# ■ RGSS3 8方向移動スクリプト Ver1.01 by 星潟
#------------------------------------------------------------------------------
# 　プレイヤーキャラクターの8方向移動を可能にします。
#   その他、プレイヤーの移動に関する一部機能について設定できます。
#   基本的に機能拡張依頼や競合対応は受け付けておりません。ご了承ください。
#
#   更新履歴
#   Ver1.01 不要な記述一点を削除。
#           スイッチ切り替えによるダッシュ禁止機能を追加。
#==============================================================================

module MOVE_CONTROL
  
  #この番号のスイッチがONの時、8方向移動を禁止し、4方向移動のみにします。
  
  FOUR_MOVE_SWITCH = 51
  
  #この番号のスイッチがONの時、プレイヤーキャラクターの操作を禁止します。
  
  MOVE_SEAL_SWITCH = 199
  
  #この番号のスイッチがONの時、ダッシュ判定が逆転します。
  #（平常時がダッシュ、ダッシュキーを押している状態で通常歩行となります）
  
  DASH_REV = 53
  
  #この番号のスイッチがONの時、ダッシュが使用できなくなります。
  #（スイッチを切り替える事で、同一マップで
  #  ダッシュのできる場所とそうでない場所を分けることが出来ます）
  
  DASH_SEAL = 54
  
  #この番号の変数が0より大きい時、ダッシュ時の速度が更に増加します。
  
  DASH_PLUS = 19
  
end

class Game_CharacterBase
  #--------------------------------------------------------------------------
  # ● 移動速度の取得（ダッシュを考慮）
  #--------------------------------------------------------------------------
  alias real_move_speed_8direction real_move_speed
  def real_move_speed
    if $game_variables[MOVE_CONTROL::DASH_PLUS] > 0
      dash_plus = 1 + ($game_variables[MOVE_CONTROL::DASH_PLUS] * 0.1)
      @move_speed + (dash? ? dash_plus : 0)
    else
      real_move_speed_8direction
    end
  end
end

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # ● ダッシュ状態判定
  #--------------------------------------------------------------------------
  alias dash_rev? dash?
  def dash?
    return false if $game_switches[MOVE_CONTROL::DASH_SEAL] == true
    if $game_switches[MOVE_CONTROL::DASH_REV] == true
      return false if @move_route_forcing
      return false if $game_map.disable_dash?
      return false if vehicle
      return false if Input.press?(:A)
      return true
    else
      dash_rev?
    end
  end
  #--------------------------------------------------------------------------
  # ● 方向ボタン入力による移動処理
  #--------------------------------------------------------------------------
  alias move_by_input_8direction move_by_input
  def move_by_input
    return if $game_switches[MOVE_CONTROL::MOVE_SEAL_SWITCH] == true
    if $game_switches[MOVE_CONTROL::FOUR_MOVE_SWITCH] == true
      move_by_input_8direction
      return
    end
    return if !movable? || $game_map.interpreter.running?
    if Input.press?(:LEFT) && Input.press?(:DOWN)
      if passable?(@x, @y, 4) && passable?(@x, @y, 2) &&
        passable?(@x - 1, @y, 2) && passable?(@x, @y + 1, 4) &&
        passable?(@x - 1, @y + 1, 6) && passable?(@x - 1, @y + 1, 8)
        move_diagonal(4, 2)
      elsif @direction == 4
        if passable?(@x, @y, 2) && passable?(@x, @y + 1, 8)
          move_straight(2)
        elsif passable?(@x, @y, 4) && passable?(@x - 1, @y, 6)
          move_straight(4)
        end
      elsif @direction == 2
        if passable?(@x, @y, 4) && passable?(@x - 1, @y, 6)
          move_straight(4)
        elsif passable?(@x, @y, 2) && passable?(@x, @y + 1, 8)
          move_straight(2)
        else
          move_straight(Input.dir4) if Input.dir4 > 0
        end
      else
        move_straight(Input.dir4) if Input.dir4 > 0
      end
    elsif Input.press?(:RIGHT) && Input.press?(:DOWN)
      if passable?(@x, @y, 6) && passable?(@x, @y, 2) &&
        passable?(@x + 1, @y, 2) && passable?(@x, @y + 1, 6) &&
        passable?(@x + 1, @y + 1, 4) && passable?(@x + 1, @y + 1, 8)
        move_diagonal(6, 2)
      elsif @direction == 6
        if passable?(@x, @y, 2) && passable?(@x, @y + 1, 8)
          move_straight(2)
        elsif passable?(@x, @y, 6) && passable?(@x + 1, @y, 4)
          move_straight(6)
        end
      elsif @direction == 2
        if passable?(@x, @y, 6) && passable?(@x + 1, @y, 4)
          move_straight(6)
        elsif passable?(@x, @y, 2) && passable?(@x, @y + 1, 8)
          move_straight(2)
        else
          move_straight(Input.dir4) if Input.dir4 > 0
        end
      else
        move_straight(Input.dir4) if Input.dir4 > 0
      end
    elsif Input.press?(:LEFT) && Input.press?(:UP)
      if passable?(@x, @y, 4) && passable?(@x, @y, 8) &&
        passable?(@x - 1, @y, 8) && passable?(@x, @y - 1, 4) &&
        passable?(@x - 1, @y - 1, 2) && passable?(@x - 1, @y - 1, 6)
        move_diagonal(4, 8)
      elsif @direction == 4
        if passable?(@x, @y, 8) && passable?(@x, @y - 1, 2)
          move_straight(8)
        elsif passable?(@x, @y, 4) && passable?(@x - 1, @y, 6)
          move_straight(4)
        else
          move_straight(Input.dir4) if Input.dir4 > 0
        end
      elsif @direction == 8
        if passable?(@x, @y, 4) && passable?(@x - 1, @y, 6)
          move_straight(4)
        elsif passable?(@x, @y, 8) && passable?(@x, @y - 1, 2)
          move_straight(8)
        else
          move_straight(Input.dir4) if Input.dir4 > 0
        end
      else
        move_straight(Input.dir4) if Input.dir4 > 0
      end
    elsif Input.press?(:RIGHT) && Input.press?(:UP)
      if passable?(@x, @y, 6) && passable?(@x, @y, 8) &&
        passable?(@x + 1, @y, 8) && passable?(@x, @y - 1, 6) &&
        passable?(@x + 1, @y - 1, 2) && passable?(@x + 1, @y - 1, 4)
        move_diagonal(6, 8)
      elsif @direction == 6
        if passable?(@x, @y, 8) && passable?(@x, @y - 1, 2)
          move_straight(8)
        elsif passable?(@x, @y, 6) && passable?(@x + 1, @y, 4)
          move_straight(6)
        else
          move_straight(Input.dir4) if Input.dir4 > 0
        end
      elsif @direction == 8
        if passable?(@x, @y, 6) && passable?(@x + 1, @y, 4)
          move_straight(6)
        elsif passable?(@x, @y, 8) && passable?(@x, @y - 1, 2)
          move_straight(8)
        else
          move_straight(Input.dir4) if Input.dir4 > 0
        end
      else
        move_straight(Input.dir4) if Input.dir4 > 0
      end
    else
      move_straight(Input.dir4) if Input.dir4 > 0
    end
    unless moving?
      @direction = Input.dir4 unless Input.dir4 == 0
    end
  end
end