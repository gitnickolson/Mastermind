# frozen_string_literal: true

require_relative 'game'
require_relative 'pins'

class Player
  attr_reader :player_input_array

  VALID_LETTERS = %w[r g b y o p].freeze

  def initialize
    @player_input_array = []
  end

  def get_player_input(codemaker)
    player_input_array.clear
    if codemaker == false
      puts "Please enter 4 colors. Hit the enter key after each color. \n
You can choose between R (Red), G (Green), B (Blue), Y (Yellow), P (Purple) and O (Orange). You can also type \"exit\" to quit the game."
    else
      puts "Please proceed by entering the desired color combination for the computer to guess. \n
You can choose between R (Red), G (Green), B (Blue), Y (Yellow), P (Purple) and O (Orange). You can also type \"exit\" to quit the game."
    end
    use_colors_loop
  end

  def use_colors_loop
    4.times do |count|
      loop do
        print "Color number ##{count + 1}: "
        input = gets.chomp.downcase[0]
        if VALID_LETTERS.include?(input)
          @player_input_array << input
          break
        elsif input == 'exit'
          exit(0)
        else
          puts 'Please only enter valid letters.'
        end
      end
    end
  end
end
