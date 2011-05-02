#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/test_helper'

class TypeFilterTest < Test::Unit::TestCase

  include Nibbler
  include TestHelper
  
  def test_to_nibbles_array_mixed
    nibbler = TypeFilter.new
    array = [0x90, "90", "9"]
    nibbles = nibbler.send(:to_nibbles, array)
    assert_equal([0x90, "90", "9"], array)
    assert_equal(["9", "0", "9", "0", "9"], nibbles)     
  end
  
  def test_to_nibbles_mixed
    nibbler = TypeFilter.new
    array = [0x90, "90", "9"]
    nibbles = nibbler.send(:to_nibbles, *array)
    assert_equal([0x90, "90", "9"], array)
    assert_equal(["9", "0", "9", "0", "9"], nibbles)     
  end

  def test_to_nibbles_numeric
    nibbler = TypeFilter.new
    num = 0x90
    nibbles = nibbler.send(:to_nibbles, num)
    assert_equal(0x90, num)
    assert_equal(["9", "0"], nibbles)     
  end                

  def test_to_nibbles_string
    nibbler = TypeFilter.new
    str = "904050"
    nibbles = nibbler.send(:to_nibbles, str)
    assert_equal("904050", str)
    assert_equal(["9", "0", "4", "0", "5", "0"], nibbles)     
  end
  
  def test_hexstr_to_nibbles
    nibbler = TypeFilter.new
    str = "904050"
    nibbles = nibbler.send(:hexstr_to_nibbles, str)
    assert_equal("904050", str)
    assert_equal(["9", "0", "4", "0", "5", "0"], nibbles)    
  end
  
  def test_numbyte_to_nibbles
    nibbler = TypeFilter.new
    num = 0x90
    nibbles = nibbler.send(:numbyte_to_nibbles, num)
    assert_equal(0x90, num)
    assert_equal(["9", "0"], nibbles)     
  end         
  
  def test_filter_numeric
    nibbler = TypeFilter.new
    badnum = 560
    output = nibbler.send(:filter_numeric, badnum)
    assert_equal(560, badnum)
    assert_equal(nil, output)     
    goodnum = 50
    output = nibbler.send(:filter_numeric, goodnum)
    assert_equal(50, goodnum)
    assert_equal(50, output)     
  end
  
end