module Nibbler

  # Accepts various types of input and returns an array of hex digit chars
  module DataProcessor

    extend self

    # Accepts various types of input and returns an array of hex digit chars
    # Invalid input is disregarded
    #
    # @param [*String, *Fixnum] args
    # @return [Array<String>] An array of hex string nibbles eg "6", "a"
    def process(*args)
      args.map { |arg| convert(arg) }.flatten.compact.map(&:upcase)
    end

    private

    # Convert a single value to hex chars
    # @param [Array<Fixnum>, Array<String>, Fixnum, String] value
    # @return [Array<String>]
    def convert(value)
      case value
        when Array then value.map { |arr| process(*arr) }.reduce(:+)
        when String then TypeConversion.hex_str_to_hex_chars(filter_string(value))
        when Fixnum then TypeConversion.numeric_byte_to_hex_chars(filter_numeric(value))
      end
    end

    # Limit the given number to bytes usable in MIDI ie values (0..240)
    # returns nil if the byte is outside of that range
    # @param [Fixnum] num
    # @return [Fixnum, nil]
    def filter_numeric(num)
      num if (0x00..0xFF).include?(num)
    end

    # Only return valid hex string characters
    # @param [String] string
    # @return [String]
    def filter_string(string)
      string.gsub(/[^0-9a-fA-F]/, "").upcase
    end

  end

end
