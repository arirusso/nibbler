module Nibbler

  # A helper for converting between different types of nibbles and bytes
  module TypeConversion

    extend self

    # Converts an array of hex nibble strings to numeric bytes
    # eg ["9", "0", "5", "0", "4", "0"] => [0x90, 0x50, 0x40]
    # @param [Array<String>] nibbles
    # @return [Array<Fixnum>]
    def hex_chars_to_numeric_bytes(nibbles)
      nibbles = nibbles.dup
      # get rid of last nibble if there's an odd number
      # it will be processed later anyway
      nibbles.slice!(nibbles.length-2, 1) if nibbles.length.odd?
      bytes = []
      until (nibs = nibbles.slice!(0,2)).empty?
        byte = (nibs[0].hex << 4) + nibs[1].hex
        bytes << byte
      end
      bytes
    end

    # Converts a string of hex digits to string nibbles
    # eg "905040" => ["9", "0", "5", "0", "4", "0"]
    # @param [String] string
    # @return [Array<String>]
    def hex_str_to_hex_chars(string)
      string.split(//)
    end

    # Converts a string of hex digits to numeric nibbles
    # eg "905040" => [0x9, 0x0, 0x5, 0x0, 0x4, 0x0]
    # @param [String] string
    # @return [Array<String>]
    def hex_str_to_numeric_nibbles(string)
      bytes = hex_str_to_numeric_bytes(string)
      numeric_bytes_to_numeric_nibbles(bytes)
    end

    # Converts a string of hex digits to numeric bytes
    # eg "905040" => [0x90, 0x50, 0x40]
    # @param [String] string
    # @return [Array<String>]
    def hex_str_to_numeric_bytes(string)
      chars = hex_str_to_hex_chars(string)
      hex_chars_to_numeric_bytes(chars)
    end

    # Converts an array bytes to an array of nibbles
    # eg [0x90, 0x50, 0x40] => [0x9, 0x0, 0x5, 0x0, 0x4, 0x0]
    # @param [String] string
    # @return [Array<String>]
    def numeric_bytes_to_numeric_nibbles(bytes)
      bytes.map { |byte| numeric_byte_to_numeric_nibbles(byte) }.flatten
    end

    # Converts a numeric byte to an array of hex nibble strings eg 0x90 => ["9", "0"]
    # @param [Fixnum] num
    # @return [Array<String>]
    def numeric_byte_to_hex_chars(num)
      nibbles = numeric_byte_to_numeric_nibbles(num)
      nibbles.map { |n| n.to_s(16) }
    end

    # Converts a numeric byte to an array of numeric nibbles eg 0x90 => [0x9, 0x0]
    # @param [Fixnum] num
    # @return [Array<String>]
    def numeric_byte_to_numeric_nibbles(num)
      [((num & 0xF0) >> 4), (num & 0x0F)]
    end

  end

end
