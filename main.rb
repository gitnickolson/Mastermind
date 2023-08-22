class Board
  attr_accessor :turns, :board_visual, :pin_board, :has_walls, :current_pin_slot, :current_row

  def initialize
    @board_visual = Array.new(26)
    @current_row = 2
    @current_pin_slot = 0
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
          update_board(player_combination, board_visual[current_row])
          player_combination = 0
          board_visual[current_row + 1].sort!.reverse!
          @current_row += 2
        end
      end
    end
    @current_pin_slot = 0
  end

  def update_board(player_combination, array)
    for i in 0..3
      array[i] = player_combination[i]
    end
    array
  end

  def update_small_pins(small_colors, indicator)
    board_visual[current_row + 1][current_pin_slot] = small_colors[indicator]
    @current_pin_slot += 1
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
  attr_accessor :board, :pins, :com, :player, :randomized_pins,
                :small_colors, :player_input, :turn_counter,
                :combinations_hash, :randomized_colors_ords, :game_ended
  TURNS = 12

  def initialize
    @turn_counter = 0
    @board = Board.new
    @pins = Pins.new
    @com = Computer.new
    @player = Player.new
  end

  def start
    puts "Welcome to mastermind! You can check out this link if you need the rules: 'https://en.wikipedia.org/wiki/Mastermind_'"
    puts "Do you want to be the codebreaker(1), or the codemaker(2)?"
    loop do
      gamemode = gets.chomp.to_i
      if gamemode == 1
        gamebreaker_loop
        break
      elsif gamemode == 2
        gamemaker_loop
        break
      else
        puts "Please enter 1 or 2"
      end
    end
  end

  private

  def gamebreaker_loop
    @randomized_pins = com.generate_combination(pins.colors)
    @small_colors = pins.small_colors
    @randomized_colors_ords = Array.new
    @game_ended = false

    @board.set_up
    @board.print_board

    @combinations_hash = {
      "🔴" => 0,
      "🟣" => 0,
      "🟢" => 0,
      "🔵" => 0,
      "🟡" => 0,
      "🟠" => 0
    }

    count_color_occurences
    TURNS.times do
      if game_ended == true
        break
      end
      game_state
    end
  end

  def gamemaker_loop

  end

  def count_color_occurences
    com.randomized_colors.each do |color_symbol|
      randomized_colors_ords << color_symbol.ord
    end
    com.randomized_colors.each do |pin|
      combinations_hash[pin] = randomized_colors_ords.count(pin.ord)
    end
  end

  def game_state
    player.get_gamebreaker_input
    player_input = player.player_input_array
    transform_player_input(player_input)

    temporary_combinations_hash = combinations_hash.dup

    player_input.each_with_index do |player_pin, index|
      if player_pin == randomized_pins[index] && temporary_combinations_hash[player_pin] > 0
      board.update_small_pins(small_colors, 0) # Green
      temporary_combinations_hash[player_pin] -= 1

      elsif randomized_pins.include?(player_pin) && temporary_combinations_hash[player_pin] > 0
      board.update_small_pins(small_colors, 1) # Purple
      temporary_combinations_hash[player_pin] -= 1
      end
    end

    board.board_row_update(player_input)
    board.print_board
    @turn_counter += 1

    if turn_counter < TURNS
      comparable_player_input = player_input.join("")

      if randomized_pins == comparable_player_input
        decision_output(true)
      end
    else
      decision_output(false)
    end
  end

  def decision_output(player_wins)
    if player_wins == true
      @game_ended = true
      p "Congratulations! You won the game after #{turn_counter} turn(s)!"
    elsif player_wins == false
      @game_ended = true
      p "You couldn't guess the correct color pattern within 12 turns. You lose!"
      p "The correct color pattern would've been #{randomized_pins}"
    end
  end

  def transform_player_input(player_input)
    
    transformation_hash = {
      "r" => "🔴",
      "g" => "🟢",
      "b" => "🔵",
      "y" => "🟡",
      "p" => "🟣",
      "o" => "🟠"
    }

    i = 0
    player_input.each do |object|
      player_input[i] = transformation_hash[object]
      i += 1
    end
    player_input
  end
end


class Player
  attr_reader :player_input_array
  VALID_LETTERS = ["r", "g", "b", "y", "o", "p"]

  def initialize
    @player_input_array = Array.new
  end

  def get_gamebreaker_input
    puts "Please enter 4 colors. Hit the enter key after each color.
You can choose between R (Red), G (Green), B (Blue), Y (Yellow), P (Purple) and O (Orange)."
    player_input_array.clear

    4.times do |count|
      loop do
        print "Color number ##{count + 1}: "
        input = gets.chomp.downcase[0]
        if VALID_LETTERS.include?(input)
          player_input_array << input
          break
        else
          puts "Please only enter valid letters."
        end
      end
    end
  end

  def get_gamemaker_input
    puts "Please proceed by entering the desired color combination. \n
You can choose between R (Red), G (Green), B (Blue), Y (Yellow), P (Purple) and O (Orange)."

    4.times do |count|
      loop do
        print "Color number ##{count + 1}: "
        input = gets.chomp.downcase[0]
        if VALID_LETTERS.include?(input)
          @player_input_array << input
          break
        else
          puts "Please only enter valid letters."
        end
      end
    end
  end
end

class Computer
  attr_reader :randomized_colors_string, :randomized_colors
  def initialize
    @randomized_colors = Array.new
    @randomized_colors_string
  end

  def generate_combination(colors)
    for i in 0..3
      randomized_colors << colors[rand(6)]
    end
    randomized_colors_string = randomized_colors.join("")
    p randomized_colors_string
  end
end

#######################################################################################################################
game = Game.new
game.start
