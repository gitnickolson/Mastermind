# frozen_string_literal: true

class Pins
  attr_reader :colors, :key_pegs

  def initialize
    @colors = %w[🔴 🔵 🟡 🟢 🟣 🟠]
    @key_pegs = %w[🟩 🟪] # Green = correct guess, Purple = close guess
  end
end
