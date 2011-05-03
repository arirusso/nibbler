#!/usr/bin/env ruby

require 'test_helper'

class TypeConversionTest < Test::Unit::TestCase

  include Nibbler
  include TestHelper
  
  def test_hex_chars_to_bytes  
    nibbles = ["4", "5", "9", "3"]
    bytes = TypeConversion.hex_chars_to_bytes(nibbles)
    assert_equal(["4", "5", "9", "3"], nibbles)
    assert_equal([0x45, 0x93], bytes) 
  end
                 
end