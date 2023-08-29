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

  def update_small_pins(key_pegs, indicator)
    board_visual[current_row + 1][current_pin_slot] = key_pegs[indicator]
    @current_pin_slot += 1
  end
end


class Pins
  attr_reader :colors, :key_pegs
  def initialize
    @colors = ['🔴', '🔵', '🟡', '🟢', '🟣', '🟠']
    @key_pegs = ['🟩', '🟪'] # Green = correct guess, Purple = close guess
  end
end


class Game
  attr_accessor :board, :pins, :com, :player, :randomized_pins,
                :key_pegs, :player_input, :turn_counter,
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
    @key_pegs = pins.key_pegs
    @game_ended = false

    @board.set_up
    @board.print_board
    count_color_occurrences

    until game_ended do
      game_state_codebreaker
    end
  end

  def codemaker_loop
    @codebreaker = false
    @key_pegs = pins.key_pegs
    @game_ended = false

    @board.set_up
    @board.print_board

    player.get_player_input(true)
    player_input = player.player_input_array
    transform_player_input!(player_input)
    count_color_occurrences(player_input)

    until game_ended do
      game_state_codemaker(player_input)
    end
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
        combinations_hash
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

    game_end(player_input.join(""), randomized_pins)
  end

  def game_state_codemaker(player_input)
    get_possibilities
    current_guess = com.computer_turn(turn_counter, possibilities, board, key_pegs)
    p current_guess
    temporary_combinations_hash = combinations_hash.dup

    guess_evaluation(current_guess, temporary_combinations_hash, player_input)
    board.board_row_update(current_guess)
    board.print_board
    @turn_counter += 1

    game_end(current_guess, player_input)
  end

  def game_end(guess, correct_code)
    if randomized_pins == guess or correct_code == guess
      @game_ended = true
      decision_output(true)
    elsif turn_counter == TURNS
      @game_ended = true
      decision_output(false, correct_code)
    end
  end

  def decision_output(player_wins, correct_code = 0)
    if player_wins
      p "Congratulations! You won the game after #{turn_counter} turn(s)!"
    else
      p "You couldn't guess the correct color pattern within 12 turns. You lose!"
      p "The correct color pattern would've been #{correct_code.join("")}"
    end
  end

  def get_possibilities
    if possibilities.empty?
      pins.colors.repeated_permutation(4) do |combination|
        possibilities << combination
      end
    end
  end

  def guess_evaluation(guess, color_counts, winning_combination)
    done_colors = Array.new
    guess.each_with_index do |guess_pin, index|
      if guess_pin == winning_combination[index]
        board.update_small_pins(key_pegs, 0) # Green
        color_counts[guess_pin] -= 1

        if color_counts[guess_pin] == guess.count(guess_pin)
          done_colors << guess_pin
        end
      end
    end

    guess.each do |guess_pin|
      if !done_colors.include?(guess_pin)
        if winning_combination.include?(guess_pin) && color_counts[guess_pin].positive?
          board.update_small_pins(key_pegs, 1) # Purple
          color_counts[guess_pin] -= 1
        end
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
  attr_reader :randomized_colors_string, :randomized_colors, :previous_guess, :previous_feedback

  def initialize
    @randomized_colors = Array.new
    @randomized_colors_string
    @previous_guess = Array.new
    @previous_feedback = Array.new
  end

  def generate_combination(colors)
    for i in 0..3
      randomized_colors << colors[rand(6)]
    end
    randomized_colors_string = randomized_colors.join('')
    p randomized_colors_string
  end

  def computer_turn(turn_counter, possibilities, board, key_pegs)
    previous_feedback = Array.new

    case turn_counter
    when 0
      #current_guess = possibilities.delete(["🔴", "🟢", "🟣", "🔵"])
      #current_guess = possibilities.delete(["🔴", "🔴", "🟢", "🟢"])
      current_guess = possibilities.sample
      possibilities.delete(current_guess)
      @previous_guess = current_guess
      current_guess
    when 1..12
      @previous_feedback = board.board_visual[board.current_row - 1]
      current_guess = find_best_guess(possibilities)

      #current_guess = possibilities.sample
       possibilities.delete(current_guess)
    end
  end

  def find_best_guess(possibilities)
    best_guess = nil
    best_score = -1

    feedback_translator = {
      '◼️' => 0,
      '🟪' => 1,
      '🟩' => 2
    }

    possibilities.each_with_index do |guess, index|
      guess_score = calculate_score(guess, feedback_translator)
      if guess_score > best_score
        best_score = guess_score
        best_guess = guess
      else
        possibilities.delete_at(index)
      end
    end

    best_guess
  end

  def calculate_score(guess, feedback_translator)
    feedback_points = 0
    guess.each_with_index do |possibility_pin, index|
      if possibility_pin == previous_guess[index]
        feedback_points += feedback_translator["🟩"]
      elsif previous_guess.include?(possibility_pin)
        feedback_points += feedback_translator["🟪"]
      end
    end
    feedback_points
  end

end

#######################################################################################################################
game = Game.new
game.start


# Algorithmus soll die evaluation methode aus game benutze
# => Dafür muss ich diese so umschreiben, dass Board sich seperat updated
# Der Algorithmus funktioniert dann wie folgt
# ich gebe einen ersten guess ab, dann iteriere ich durch den möglichkeiten array gegen diesen guess und
# behalte nur jene Möglichkeiten in meinen Möglichkeiten, die genau das selbe feedback erzeugen wie der gesetzte guess.
# Aus den übrigen Möglichkeiten entnehme ich dann einen random guess und gebe diesen ab
# dieses verfahren verfolge ich so oft bis ich durch bin

