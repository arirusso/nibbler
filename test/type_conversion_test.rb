require "helper"

class TypeConversionTest < Test::Unit::TestCase

  include Nibbler
  include TestHelper
  
  def test_hex_chars_to_numeric_bytes  
    nibbles = ["4", "5", "9", "3"]
    bytes = TypeConversion.hex_chars_to_numeric_bytes(nibbles)
    
    assert_equal(["4", "5", "9", "3"], nibbles)
    assert_equal([0x45, 0x93], bytes) 
  end
  
  def test_hex_str_to_hex_chars
    str = "904050"
    nibbles = TypeConversion.send(:hex_str_to_hex_chars, str)
    
    assert_equal("904050", str)
    assert_equal(["9", "0", "4", "0", "5", "0"], nibbles)    
  end
  
  def test_numeric_byte_to_hex_chars
    num = 0x90
    nibbles = TypeConversion.send(:numeric_byte_to_hex_chars, num)
    
    assert_equal(0x90, num)
    assert_equal(["9", "0"], nibbles)     
  end         
              
end
