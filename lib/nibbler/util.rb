# frozen_string_literal: true

module Nibbler
  # Utility methods
  module Util
    module_function

    def status_bit(byte)
      # ruby binary goes least to most significant thus 7 and not 0
      byte[7]
    end

    def status_byte?(byte)
      status_bit(byte) == 1
    end

    # Converts a numeric byte to an array of numeric nibbles eg 0x90 => [0x9, 0x0]
    # @param [Integer] num
    # @return [Array<String>]
    def numeric_byte_to_numeric_nibbles(num)
      [((num & 0xF0) >> 4), (num & 0x0F)]
    end
  end
end
