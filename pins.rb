class Pins
  attr_reader :colors, :key_pegs

  def initialize
    @colors = ['🔴', '🔵', '🟡', '🟢', '🟣', '🟠']
    @key_pegs = ['🟩', '🟪'] # Green = correct guess, Purple = close guess
  end
end
