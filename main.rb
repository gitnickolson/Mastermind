class Board
  attr_accessor :turns, :board_visual, :pin_board, :has_walls

  def initialize
    @board_visual = Array.new(26)
    @current_row = 2
    @pin_slot = 0
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

  def print_board
    board_visual.each_with_index do |row, index|
      if index.even?
        print row.join("")
      else
        puts row.join("")
      end
    end
  end

  def board_row_update(player_combination)
    board_visual.each_with_index do |row, index|
      if index.even?
        if player_combination != 0 && index != 0
          update_board(player_combination, board_visual[@current_row])
          player_combination = 0

          board_visual[index + 1].sort!
          @current_row += 2
        end
      end
    end
    @pin_slot = 0
  end

  def update_board(player_combination, array)
    for i in 0..3
      array[i] = player_combination[i]
    end
    array
  end

  def update_small_pins(small_pins, indicator)
    board_visual[@current_row + 1][@pin_slot] = small_pins[indicator]
    @pin_slot += 1
  end
end

class Pins
  attr_reader :colors, :small_colors

  def initialize
    @colors = ["🔴", "🔵", "🟡", "🟢", "🟣", "🟠"]
    @small_colors = ["🟩", "🟪"]
  end
end

class Game
  def initialize
    @turn_counter = 0
  end

  def game_state(randomized_pins, small_colors, player_input, board, name)
    p player_input
    player_input_new = transform_player_input(player_input)
    p player_input_new

    player_input_new.each_with_index do |player_pin, index|
      if player_pin == randomized_pins[index] &&
        board.update_small_pins(small_colors, 0) # Green

      elsif randomized_pins.include?(player_pin)
        board.update_small_pins(small_colors, 1) # Purple
      end
    end

    board.board_row_update(player_input_new)
    board.print_board

    @turn_counter += 1

    if @turn_counter <= 12
      comparable_player_input_new = player_input_new.join("")

      if randomized_pins == comparable_player_input_new
          puts "Congratulations #{name}! You won the game after #{@turn_counter} turn(s)!"
          exit
      end
    else
      puts "You couldn't guess the correct color pattern within 12 turns. You lose!"
      exit
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
  attr_reader :player_input_array, :name

  def initialize(name)
    @name = name
    @player_input_array = Array.new
  end

  def get_player_input
    puts "Please enter 4 colors. Hit the enter key after each color.
You can choose between R (Red), G (Green), B (Blue), Y (Yellow), P (Purple) and O (Orange)."
    player_input_array.clear

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
  def generate_combination(colors)
    for i in 0..94
      colors << colors[i]
    end
    randomized_colors = colors.shuffle.pop(4)
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

random_colors = com.generate_combination(pins.colors)

12.times do
game.game_state(random_colors, pins.small_colors, player.get_player_input, board, player.name)
end