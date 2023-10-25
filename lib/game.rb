# frozen_string_literal: true

require_relative 'player'
require_relative 'pins'
require_relative 'board'
require_relative 'computer'

class Game
  attr_accessor :board, :pins, :com, :player, :randomized_pins,
                :key_pegs, :player_input, :turn_counter,
                :combinations_hash, :colors_ords, :game_ended,
                :possibilities, :codebreaker, :game_mode

  TURNS = 12

  def initialize
    @turn_counter = 0
    @board = Board.new
    @pins = Pins.new
    @com = Computer.new(self)
    @player = Player.new
    @possibilities = []
    @colors_ords = []
    @game_mode = 0

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
      @game_mode = gets.chomp.to_i
      if game_mode == 1
        codebreaker_loop
        break
      elsif game_mode == 2
        codemaker_loop
        break
      else
        puts 'Please enter 1 or 2'
      end
    end
  end

  def guess_evaluation(guess, color_counts, winning_combination, board_rewrite)
    feedback = []
    done_colors = []
    guess.each_with_index do |guess_pin, index|
      next unless guess_pin == winning_combination[index]

      board.update_small_pins(key_pegs[0], board_rewrite) # Green
      color_counts[guess_pin] -= 1
      feedback << '🟩'

      done_colors << guess_pin if color_counts[guess_pin] == guess.count(guess_pin)
    end

    guess.each do |guess_pin|
      unless !done_colors.include?(guess_pin) && (winning_combination.include?(guess_pin) && color_counts[guess_pin].positive?)
        next
      end

      board.update_small_pins(key_pegs[1], board_rewrite) # Purple
      color_counts[guess_pin] -= 1
      feedback << '🟪'
    end
    feedback.sort!.reverse!
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

    game_loop(player_input)
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

    game_loop(player_input)
  end

  def game_loop(player_input)
    if game_mode == 2
      game_state_codemaker(player_input) until game_ended
    elsif game_mode == 1
      game_state_codebreaker until game_ended
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

    guess_evaluation(player_input, temporary_combinations_hash, randomized_pins, true)
    board.board_row_update(player_input)
    board.print_board
    @turn_counter += 1

    game_end(player_input.join(''), randomized_pins)
  end

  def game_state_codemaker(player_input)
    generate_possibilities if possibilities.empty?
    current_guess = com.computer_turn(turn_counter, possibilities, board, key_pegs)
    temporary_combinations_hash = combinations_hash.dup

    guess_evaluation(current_guess, temporary_combinations_hash, player_input, true)
    board.board_row_update(current_guess)
    board.print_board
    @turn_counter += 1

    game_end(current_guess.join(''), player_input.join(''))
  end

  def game_end(guess, correct_code)
    if (randomized_pins == guess) || (correct_code == guess)
      @game_ended = true
      decision_output(true)
    elsif turn_counter == TURNS
      @game_ended = true
      decision_output(false, correct_code)
    end
  end

  def decision_output(player_wins, correct_code = 0)
    if game_mode == 1
      if player_wins
        p "Congratulations! You won the game after #{turn_counter} turn(s)!"
      else
        p "You couldn't guess the correct color pattern within 12 turns. You lose!"
        p "The correct color pattern would've been #{correct_code}"
      end
    elsif player_wins
      p "Damn! The computer won the game after #{turn_counter} turn(s)!"
    else
      p "Congratulations! The computer couldn't guess your secret code (#{correct_code}) within 12 turns!"
    end
  end

  def generate_possibilities
    pins.colors.repeated_permutation(4) do |combination|
      possibilities << combination
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
