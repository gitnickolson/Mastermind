require_relative 'game'
require_relative 'pins'

class Computer
  attr_reader :randomized_colors_string, :randomized_colors, :previous_guess,
              :transformed_previous_feedback, :game, :true_possibilities

  def initialize(game)
    @randomized_colors = []
    @previous_guess = []
    @transformed_previous_feedback = []
    @true_possibilities = []
    @game = game
  end

  def generate_combination(colors)
    for i in 0..3
      randomized_colors << colors[rand(6)]
    end
    randomized_colors_string = randomized_colors.join('')
  end

  def computer_turn(turn_counter, possibilities, board, _key_pegs)
    case turn_counter
    when 0
      # current_guess = possibilities.delete(["🔴", "🔴", "🟢", "🟢"])
      current_guess = possibilities.delete(possibilities.sample)
      @previous_guess = current_guess
      current_guess

    when 1..12
      transformed_previous_feedback.clear
      previous_feedback = board.board_visual[board.current_row - 1]

      previous_feedback.each do |element|
        transformed_previous_feedback << element if element != '◼️'
      end

      current_guess = find_best_guess(possibilities)
      @previous_guess = current_guess
      possibilities.delete(current_guess)
      current_guess
    end
  end

  def find_best_guess(possibilities)
    color_counts = {
      '🔴' => 0,
      '🟣' => 0,
      '🟢' => 0,
      '🔵' => 0,
      '🟡' => 0,
      '🟠' => 0
    }

    previous_guess.each do |guess|
      color_counts[guess] += 1
    end

    possibilities.each_with_index do |guess, _index|
      possible_feedback = game.guess_evaluation(guess, color_counts, previous_guess, false)
      @true_possibilities << guess if possible_feedback == transformed_previous_feedback
      possibilities.delete(guess)
    end

    next_guess = if true_possibilities.empty?
                   possibilities.sample
                 else
                   true_possibilities.sample
                 end

    true_possibilities.delete(next_guess)
    next_guess
  end
end
