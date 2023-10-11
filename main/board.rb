require_relative 'pins'


class Board
  attr_accessor :turns, :board_visual, :pin_board, :has_walls, :current_pin_slot, :current_row
  def initialize
    @board_visual = Array.new(26)
    @current_row = 2
    @current_pin_slot = 0
  end

  def set_up
    board_visual.map! { |_a, _b, _c, _d| a = '', b = '', c = '', d = '' }
    board_visual.each_with_index do |row, row_index|
      row.each_with_index do |_field, column_index|
        row[column_index] = if row_index.even?
                              '🔘'
                            else
                              '◼️'
                            end

        if row_index.zero?
          row[column_index] = '🔳'
        elsif row_index == 1
          row[column_index] = ''
        end
      end
    end
  end

  def print_board
    board_visual.each_with_index do |row, index|
      if index.even?
        print row.join('')
      else
        puts row.join('')
      end
    end
  end

  def board_row_update(combination)
    board_visual.each_with_index do |_row, index|
      next unless index.even? && (combination != 0 && index != 0)

      update_board(combination, board_visual[current_row])
      combination = 0
      board_visual[current_row + 1].sort!.reverse!
      @current_row += 2
    end
    @current_pin_slot = 0
  end

  def update_board(player_combination, array)
    for i in 0..3
      array[i] = player_combination[i]
    end
    array
  end

  def update_small_pins(key_peg, board_rewrite)
    return unless board_rewrite == true

    board_visual[current_row + 1][current_pin_slot] = key_peg
    @current_pin_slot += 1
  end
end
