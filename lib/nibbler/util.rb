# frozen_string_literal: true

module Nibbler
  # Utility methods
  module Util
    module_function

    # The status bit of a MIDI byte
    # eg 0x90 => 1, 0x20 => 0
    # @param [Integer] byte
    # @return [Integer]
    def status_bit(byte)
      # ruby binary goes least to most significant thus 7 and not 0
      byte[7]
    end

    # Is the given byte a MIDI status byte?
    # @param [Integer] byte
    # @return [Boolean]
    def status_byte?(byte)
      status_bit(byte) == 1
    end

    # Util methods for converting data types
    module Conversion
      module_function

      # Converts a numeric byte to an array of numeric nibbles eg 0x90 => [0x9, 0x0]
      # @param [Integer] num
      # @return [Array<String>]
      def numeric_byte_to_numeric_nibbles(num)
        [((num & 0xF0) >> 4), (num & 0x0F)]
      end

      # Converts a string byte or bytes to integer bytes
      # eg
      # @param [String, Array<String>] strings
      # @return [Array<Integer>]
      def strings_to_numeric_bytes(*strings)
        string_bytes = strings.map { |string| string.scan(/../) }.flatten
        string_bytes.map(&:hex)
      end
    end
  end
end
