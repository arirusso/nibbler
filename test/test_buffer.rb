#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/test_helper'

class BufferTest < Test::Unit::TestCase

  include Nibbler
  include TestHelper

  def test_buffer_nibble
    nibbler = Nibbler.new
    nibbler.parse(0x9)
    assert_equal(nibbler.buffer, [9])
  end

  def test_buffer_nibble_str
    nibbler = Nibbler.new
    nibbler.parse("9")
    assert_equal(nibbler.buffer, [9])
  end
    
  def test_buffer_single_byte
    nibbler = Nibbler.new
    nibbler.parse(0x90)
    assert_equal(nibbler.buffer, [144])
  end

  def test_buffer_single_byte_str
    nibbler = Nibbler.new
    nibbler.parse("90")
    assert_equal(nibbler.buffer, [144])
  end
  
  def test_buffer_single_byte_in_array
    nibbler = Nibbler.new
    nibbler.parse([0x90])
    assert_equal(nibbler.buffer, [144])
  end
  
  def test_buffer_two_bytes
    nibbler = Nibbler.new
    nibbler.parse(0x90, 0x40)
    assert_equal(nibbler.buffer, [144, 64])    
  end

  def test_buffer_two_bytes_str
    nibbler = Nibbler.new
    nibbler.parse("90", "40")
    assert_equal(nibbler.buffer, [144, 64])    
  end

  def test_buffer_two_bytes_single_str
    nibbler = Nibbler.new
    nibbler.parse("9040")
    assert_equal(nibbler.buffer, [144, 64])    
  end
  
  def test_buffer_two_bytes_mixed
    nibbler = Nibbler.new
    nibbler.parse("90", 0x40)
    assert_equal(nibbler.buffer, [144, 64])    
  end  
  
end