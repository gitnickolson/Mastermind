class Board
  attr_accessor :turns, :board_visual, :pin_board

  def initialize
    @board_visual = Array.new(26) # 12 Turns (12) + Actual code hatch (1) + 12 Correction-pin-boxes + Empty array
    @turns = 12
  end

  def set_up
    board_visual.map! { |a, b, c, d| a = "", b = "", c = "", d = ""}
    board_visual.each_with_index do |row, row_index|
      row.each_with_index do |field, column_index|
        if row_index.even?
          row[column_index] = "o"
        else
          row[column_index] = "•"
        end
        if row_index == 0
          row[column_index] = "■"
        end
        if row_index == 1
          row[column_index] = ""
        end
      end
    end
  end

  def print_board
    board_visual.each_with_index do |array, index|
      if index != 1
        array.append("|")
        array.prepend("|")
      end

      if index.even?
        print array.join("")
      else
        puts array.join("")
      end
    end
  end
end

class Pins
  def initialize
    @color1 = "🔴"
    @color2 = "🔵"
    @color3 = "🟡"
    @color4 = "🟢"
    @color5 = "🟣"
    @color6 = "🟠"
    @number_of_big_pins = 72

    @small_color1 = "🟩"
    @small_color2 = "🟪"
  end
end

class Game
  attr_accessor = :turn_counter
  def initialize
    @turn_counter = 12
  end

  def game_turn(pins, player)

  end

end


class Player
  def initialize(name)
    @name = name
  end

  def get_player_input

  end
end

class Rules

end

class Computer
  def initialize

  end

  def generate_combination(color1, color2, color3, color4, color5, color6)

  end
end

#######################################################################################################################
board = Board.new
game = Game.new
pins = Pins.new
rules = Rules.new

puts "Player, what's your name?"

player = Player.new(gets.chomp)

board.set_up
board.print_board
