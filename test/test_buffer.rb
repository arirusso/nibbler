#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/test_helper'

class BufferTest < Test::Unit::TestCase

  include Nibbler
  include TestHelper

  def test_buffer_nibble_str
    nibbler = Nibbler.new
    nibbler.parse("9")
    assert_equal([9], nibbler.buffer)
  end
    
  def test_buffer_single_byte
    nibbler = Nibbler.new
    nibbler.parse(0x90)
    assert_equal([9, 0], nibbler.buffer)
  end

  def test_buffer_single_byte_str
    nibbler = Nibbler.new
    nibbler.parse("90")
    assert_equal([9, 0], nibbler.buffer)
  end
  
  def test_buffer_single_byte_in_array
    nibbler = Nibbler.new
    nibbler.parse([0x90])
    assert_equal([9, 0], nibbler.buffer)
  end
  
  def test_buffer_two_bytes
    nibbler = Nibbler.new
    nibbler.parse(0x90, 0x40)
    assert_equal([9, 0, 4, 0], nibbler.buffer)    
  end

  def test_buffer_two_bytes_str
    nibbler = Nibbler.new
    nibbler.parse("90", "40")
    assert_equal([9, 0, 4, 0], nibbler.buffer)    
  end

  def test_buffer_two_bytes_single_str
    nibbler = Nibbler.new
    nibbler.parse("9040")
    assert_equal([9, 0, 4, 0], nibbler.buffer)    
  end
  
  def test_buffer_two_bytes_mixed
    nibbler = Nibbler.new
    nibbler.parse("90", 0x40)
    assert_equal([9, 0, 4, 0], nibbler.buffer)    
  end  

  def test_buffer_nibble_and_byte_mixed
    nibbler = Nibbler.new
    nibbler.parse("9", 0x40)
    assert_equal([9, 4, 0], nibbler.buffer)    
  end  
  
  def test_buffer_stepped
    nibbler = Nibbler.new
    nibbler.parse("9")
    nibbler.parse(0x40)
    assert_equal([9, 4, 0], nibbler.buffer)    
  end
  
  def test_nibbles_to_bytes  
    nibbler = Nibbler.new
    nibbles = [0x4, 0x5, 0x9, 0x3]
    bytes = nibbler.send(:nibbles_to_bytes, nibbles)
    assert_equal([0x4, 0x5, 0x9, 0x3], nibbles)
    assert_equal([0x45, 0x93], bytes) 
  end
    
end