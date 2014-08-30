module Nibbler  
  
  # Turns various types of input in to an array of hex digit chars
  class HexCharArrayFilter

    #extend self
       
    # @params [*String, *Fixnum] args
    # @return [Array<String>] An array of hex string nibbles eg "6", "a"
    def process(*args)
      args.map { |arg| convert(arg) }.flatten.map(&:upcase) 
    end
    
    private

    def convert(value)
      case value
        when Array then value.map { |arr| process(*arr) }.inject { |a,b| a + b }
        when String then TypeConversion.hex_str_to_hex_chars(filter_string(value))
        when Fixnum then TypeConversion.numeric_byte_to_hex_chars(filter_numeric(value))
      end
    end
    
    # Limit the given number to bytes usable in MIDI ie values (0..240)
    # returns nil if the byte is outside of that range
    def filter_numeric(num)
      (0x00..0xFF).include?(num) ? num : nil
    end
    
    # Only return valid hex string characters
    def filter_string(string)
      string.gsub(/[^0-9a-fA-F]/, '').upcase
    end
  
  end

end
