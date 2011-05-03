#!/usr/bin/env ruby

require 'test_helper'

class HexCharArrayFilterTest < Test::Unit::TestCase

  include Nibbler
  include TestHelper
  
  def test_to_nibbles_array_mixed
    filter = HexCharArrayFilter.new
    array = [0x90, "90", "9"]
    nibbles = filter.send(:process, array)
    assert_equal([0x90, "90", "9"], array)
    assert_equal(["9", "0", "9", "0", "9"], nibbles)     
  end
  
  def test_to_nibbles_mixed
    filter = HexCharArrayFilter.new
    array = [0x90, "90", "9"]
    nibbles = filter.send(:process, *array)
    assert_equal([0x90, "90", "9"], array)
    assert_equal(["9", "0", "9", "0", "9"], nibbles)     
  end

  def test_to_nibbles_numeric
    filter = HexCharArrayFilter.new
    num = 0x90
    nibbles = filter.send(:process, num)
    assert_equal(0x90, num)
    assert_equal(["9", "0"], nibbles)     
  end                

  def test_to_nibbles_string
    filter = HexCharArrayFilter.new
    str = "904050"
    nibbles = filter.send(:process, str)
    assert_equal("904050", str)
    assert_equal(["9", "0", "4", "0", "5", "0"], nibbles)     
  end
  
  def test_hexstr_to_nibbles
    filter = HexCharArrayFilter.new
    str = "904050"
    nibbles = filter.send(:hexstr_to_nibbles, str)
    assert_equal("904050", str)
    assert_equal(["9", "0", "4", "0", "5", "0"], nibbles)    
  end
  
  def test_numbyte_to_nibbles
    filter = HexCharArrayFilter.new
    num = 0x90
    nibbles = filter.send(:numbyte_to_nibbles, num)
    assert_equal(0x90, num)
    assert_equal(["9", "0"], nibbles)     
  end         
  
  def test_filter_numeric
    filter = HexCharArrayFilter.new
    badnum = 560
    output = filter.send(:filter_numeric, badnum)
    assert_equal(560, badnum)
    assert_equal(nil, output)     
    goodnum = 50
    output = filter.send(:filter_numeric, goodnum)
    assert_equal(50, goodnum)
    assert_equal(50, output)     
  end
  
end