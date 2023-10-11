require_relative 'game'
require_relative 'pins'

class Player
  attr_reader :player_input_array

  VALID_LETTERS = %w[r g b y o p]

  def initialize
    @player_input_array = []
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
