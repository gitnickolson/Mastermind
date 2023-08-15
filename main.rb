class Board
  attr_accessor :turns, :board_visual, :pin_board, :has_walls

  def initialize
    @board_visual = Array.new(26) # 12 Turns (12) + Actual code hatch (1) + 12 Correction-pin-boxes + Empty array
    @turns = 12
    @has_walls = false
    @current_row = 2
  end

  def set_up
    board_visual.map! { |a, b, c, d| a = "", b = "", c = "", d = ""}
    board_visual.each_with_index do |row, row_index|
      row.each_with_index do |field, column_index|
        if row_index.even?
          row[column_index] = "🔘"
        else
          row[column_index] = "◼️"
        end

        if row_index == 0
          row[column_index] = "🔳"
        elsif row_index == 1
          row[column_index] = ""
        end
      end
    end
  end

  def print_board(player_combination = 0)
    board_visual.each_with_index do |row, index|
      if index.even?
        if player_combination != 0 && index != 0
          board_visual[@current_row] = update_board(player_combination, row)
          player_combination = 0
          @current_row += 2
        end
        print row.join("")
      else
        puts row.join("")
      end
    end
  end

  def update_board(player_combination, array)
    for i in 0..3
      array[i] = player_combination[i]
    end
    array
  end
end

class Pins
  attr_reader :colors

  def initialize
    @colors = ["🔴", "🔵", "🟡", "🟢", "🟣", "🟠"]



    @small_color1 = "🟩"
    @small_color2 = "🟪"
  end
end

class Game
  attr_accessor = :turn_counter
  def initialize
    @turn_counter = 0
  end

  def game_turn(randomized_pins, player_input, board)
    p player_input
    player_input_new = transform_player_input(player_input)
    p player_input_new
    board.print_board(player_input_new)

    if @turn_counter < 12
      if randomized_pins == player_input
        puts "You won the game after #{@turn_counter} turns!"
      end
    else
      puts "You couldn't guess the correct color pattern within 12 turns. You lose!"
    end
  end


  def transform_player_input(player_input)
    for i in 0..4
      case player_input[i]
      when "r"
        player_input[i] = "🔴"

      when "g"
        player_input[i] = "🟢"

      when "b"
        player_input[i] = "🔵"

      when "y"
        player_input[i] = "🟡"

      when "p"
        player_input[i] = "🟣"

      when "o"
        player_input[i] = "🟠"
      end
    end
    player_input
  end
end


class Player
  def initialize(name)
    @name = name
  end

  def get_player_input
    puts "Please enter 4 colors. Hit the enter key after each color.
You can choose between R (Red), G (Green), B (Blue), Y (Yellow), P (Purple), O (Orange)"
    player_input_array = Array.new

    count = 1
    4.times do
      puts "Color number ##{count}:"
      player_input_array << gets.chomp.downcase[0]
      count += 1
    end

    player_input_array.each do |letter|
      if !["r", "g", "b", "y", "o", "p"].include?(letter)
        puts "#{@name}, please only enter valid letters"
        puts ""
        get_player_input
      end
    end
    player_input_array
  end
end


class Rules

end


class Computer
  def initialize
  end

  def generate_combination(colors)
    randomized_colors = colors.shuffle.pop(4)
    p randomized_colors.join("")
  end
end

#######################################################################################################################
board = Board.new
game = Game.new
pins = Pins.new
rules = Rules.new
com = Computer.new

puts "Player, what's your name?"
player = Player.new(gets.chomp)

board.set_up
board.print_board


game.game_turn(com.generate_combination(pins.colors), player.get_player_input, board)