class Board
  attr_accessor :turns, :board_visual, :pin_board, :has_walls, :current_pin_slot, :current_row
  def initialize
    @board_visual = Array.new(26)
    @current_row = 2
    @current_pin_slot = 0
  end

  def set_up
    board_visual.map! { |a, b, c, d| a = '', b = '', c = '', d = ''}
    board_visual.each_with_index do |row, row_index|
      row.each_with_index do |field, column_index|
        if row_index.even?
          row[column_index] = '🔘'
        else
          row[column_index] = '◼️'
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
    board_visual.each_with_index do |row, index|
      if index.even?
        if combination != 0 && index != 0
          update_board(combination, board_visual[current_row])
          combination = 0
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
    @colors = ['🔴', '🔵', '🟡', '🟢', '🟣', '🟠']
    @small_colors = ['🟩', '🟪']
  end
end


class Game
  attr_accessor :board, :pins, :com, :player, :randomized_pins,
                :small_colors, :player_input, :turn_counter,
                :combinations_hash, :colors_ords, :game_ended,
                :possibilities, :codebreaker
  TURNS = 12

  def initialize
    @turn_counter = 0
    @board = Board.new
    @pins = Pins.new
    @com = Computer.new
    @player = Player.new
    @possibilities = Array.new
    @colors_ords = Array.new

    @combinations_hash = {
      '🔴' => 0,
      '🟣' => 0,
      '🟢' => 0,
      '🔵' => 0,
      '🟡' => 0,
      '🟠' => 0
    }
  end

  def start
    puts "Welcome to mastermind! You can check out this link if you need the rules: 'https://en.wikipedia.org/wiki/Mastermind_'"
    puts 'Do you want to be the codebreaker(1), or the codemaker(2)?'
    loop do
      gamemode = gets.chomp.to_i
      if gamemode == 1
        codebreaker_loop
        break
      elsif gamemode == 2
        codemaker_loop
        break
      else
        puts 'Please enter 1 or 2'
      end
    end
  end

  private

  def codebreaker_loop
    @codebreaker = true
    @randomized_pins = com.generate_combination(pins.colors)
    @small_colors = pins.small_colors
    @game_ended = false

    @board.set_up
    @board.print_board
    count_color_occurrences

    loop do
      break if game_ended
      game_state_codebreaker
    end
  end

  def codemaker_loop
    @codebreaker = false
    @small_colors = pins.small_colors
    @game_ended = false

    @board.set_up
    @board.print_board

    player.get_player_input(true)
    player_input = player.player_input_array
    transform_player_input!(player_input)
    count_color_occurrences(player_input)

    game_state_codemaker(player_input)
  end

  def count_color_occurrences(code = 0)
    if codebreaker == true
      com.randomized_colors.each do |pin|
        colors_ords << pin.ord
        combinations_hash[pin] = colors_ords.count(pin.ord)
      end
    else
      code.each do |pin|
        colors_ords << pin.ord
        combinations_hash[pin] = colors_ords.count(pin.ord)
        p combinations_hash
      end
    end
  end

  def game_state_codebreaker
    player.get_player_input(false)
    player_input = player.player_input_array
    transform_player_input!(player_input)
    temporary_combinations_hash = combinations_hash.dup

    guess_evaluation(player_input, temporary_combinations_hash, randomized_pins)
    board.board_row_update(player_input)
    board.print_board
    @turn_counter += 1

    has_game_ended?(player_input.join(""), randomized_pins)
  end

  def game_state_codemaker(player_input)
    p player_input.join("")
    get_possibilities
    current_guess = com.computer_turn(turn_counter, possibilities)
    p current_guess
    temporary_combinations_hash = combinations_hash.dup

    guess_evaluation(current_guess, temporary_combinations_hash, player_input)
    board.board_row_update(current_guess)
    board.print_board
    @turn_counter += 1
  end

  def has_game_ended?(guess, correct_code)
    if turn_counter < TURNS
      if randomized_pins == guess
        @game_ended = true
        decision_output(true, correct_code)
      end
    else
      @game_ended = true
      decision_output(false, correct_code)
    end
  end

  def decision_output(player_wins, correct_code)
    if player_wins
      p "Congratulations! You won the game after #{turn_counter} turn(s)!"
    else
      p "You couldn't guess the correct color pattern within 12 turns. You lose!"
      p "The correct color pattern would've been #{correct_code}"
    end
  end

  def get_possibilities
    pins.colors.repeated_permutation(4) do |combination|
      possibilities << combination
    end
  end

  def guess_evaluation(guess, combinations, winning_combination)
    guess.each_with_index do |guess_pin, index|
      if guess_pin == winning_combination[index] && (combinations[guess_pin]).positive?
        board.update_small_pins(small_colors, 0) # Green
        combinations[guess_pin] -= 1
      end
    end

    guess.each_with_index do |guess_pin|
      if winning_combination.include?(guess_pin) && (combinations[guess_pin]).positive?
        board.update_small_pins(small_colors, 1) # Purple
        combinations[guess_pin] -= 1
      end
    end
  end

  def transform_player_input!(player_input)
    transformation_hash = {
      'r' => '🔴',
      'g' => '🟢',
      'b' => '🔵',
      'y' => '🟡',
      'p' => '🟣',
      'o' => '🟠'
    }

    player_input.each_with_index do |object, i|
      player_input[i] = transformation_hash[object]
    end
    player_input
  end
end


class Player
  attr_reader :player_input_array
  VALID_LETTERS = ['r', 'g', 'b', 'y', 'o', 'p']

  def initialize
    @player_input_array = Array.new
  end

  def get_player_input(codemaker)
    if codemaker == false
      player_input_array.clear
      puts "Please enter 4 colors. Hit the enter key after each color.
You can choose between R (Red), G (Green), B (Blue), Y (Yellow), P (Purple) and O (Orange)."
      get_colors_loop
    else
      player_input_array.clear
      puts "Please proceed by entering the desired color combination for the computer to guess. \n
You can choose between R (Red), G (Green), B (Blue), Y (Yellow), P (Purple) and O (Orange)."
      get_colors_loop
    end
  end

  def get_colors_loop
    4.times do |count|
      loop do
        print "Color number ##{count + 1}: "
        input = gets.chomp.downcase[0]
        if VALID_LETTERS.include?(input)
          @player_input_array << input
          break
        else
          puts 'Please only enter valid letters.'
        end
      end
    end
  end
end


class Computer
  attr_reader :randomized_colors_string, :randomized_colors, :current_guess
  def initialize
    @possibilities = Array.new
    @randomized_colors = Array.new
    @randomized_colors_string
    @current_guess = Array.new
  end

  def generate_combination(colors)
    for i in 0..3
      randomized_colors << colors[rand(6)]
    end
    randomized_colors_string = randomized_colors.join('')
  end

  def computer_turn(turn_counter, possibilities)
    previous_guesses = Array.new

    if turn_counter == 0
      current_guess = possibilities.delete_at(0)
      previous_guesses << current_guess
      current_guess
    else
      possibilities.each_with_index do |combination, index|

      end
    end
  end
end

#######################################################################################################################
game = Game.new
game.start

# game.guess_evaluation is now a method
# changed the code for said evaluation because it sometimes didn't work as it should
# Changed the way how the game checks if someone won completely and made it compatible for both codebreaker and codemaker mode
