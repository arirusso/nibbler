#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/test_helper'

class LowlevelTest < Test::Unit::TestCase

  include Nibbler
  include TestHelper
  
  def test_nibbles_to_bytes  
    nibbler = Nibbler.new
    nibbles = [0x4, 0x5, 0x9, 0x3]
    bytes = nibbler.send(:nibbles_to_bytes, nibbles)
    assert_equal([0x4, 0x5, 0x9, 0x3], nibbles)
    assert_equal([0x45, 0x93], bytes) 
  end
  
  def test_hexstr_to_nibbles  
    nibbler = Nibbler.new
    hexstr = "904040"
    bytes = nibbler.send(:hexstr_to_nibbles, hexstr)
    assert_equal("904040", hexstr)
    assert_equal([0x9, 0x0, 0x4, 0x0, 0x4, 0x0], bytes) 
  end
  
  def test_filter_numeric
    nibbler = Nibbler.new
    badnum = 560
    output = nibbler.send(:filter_numeric, badnum)
    assert_equal(560, badnum)
    assert_equal(nil, output)     
    goodnum = 50
    output = nibbler.send(:filter_numeric, goodnum)
    assert_equal(50, goodnum)
    assert_equal(50, output)     
  end

  def test_byte_to_nibbles
    nibbler = Nibbler.new
    byte = 0x90
    nibbles = nibbler.send(:byte_to_nibbles, byte)
    assert_equal(0x90, byte)
    assert_equal([0x9, 0x0], nibbles)     
  end

  def test_to_nibbles_array_mixed
    nibbler = Nibbler.new
    array = [0x90, "90", "9"]
    nibbles = nibbler.send(:to_nibbles, array)
    assert_equal([0x90, "90", "9"], array)
    assert_equal([0x9, 0x0, 0x9, 0x0, 0x9], nibbles)     
  end
  
  def test_to_nibbles_mixed
    nibbler = Nibbler.new
    array = [0x90, "90", "9"]
    nibbles = nibbler.send(:to_nibbles, *array)
    assert_equal([0x90, "90", "9"], array)
    assert_equal([0x9, 0x0, 0x9, 0x0, 0x9], nibbles)     
  end

  def test_to_nibbles_numeric
    nibbler = Nibbler.new
    num = 0x90
    nibbles = nibbler.send(:to_nibbles, num)
    assert_equal(0x90, num)
    assert_equal([0x9, 0x0], nibbles)     
  end                

  def test_to_nibbles_string
    nibbler = Nibbler.new
    str = "904050"
    nibbles = nibbler.send(:to_nibbles, str)
    assert_equal("904050", str)
    assert_equal([0x9, 0x0, 0x4, 0x0, 0x5, 0x0], nibbles)     
  end   
  
  def test_only_with_bytes
    nibbler = Nibbler.new
    num_bytes = 3
    nibbles = [0x9, 0x0, 0x4, 0x0, 0x5, 0x0, 0x5, 0x0]
    outp = nibbler.send(:only_with_bytes, num_bytes, nibbles) { |b| b }
    assert_equal([0x90, 0x40, 0x50], outp[0])
    assert_equal([0x9, 0x0, 0x4, 0x0, 0x5, 0x0], outp[1])    
    assert_equal([0x5, 0x0], nibbles)
    nibbles = [0x9, 0x0, 0x4]
    outp = nibbler.send(:only_with_bytes, num_bytes, nibbles) { |b| b }
    assert_equal(nil, outp[0])
    assert_equal([], outp[1])        
    assert_equal([0x9, 0x0, 0x4], nibbles)
  end
  
  def test_only_with_sysex_bytes
    nibbler = Nibbler.new
    nibbles = [0xF, 0x0, 0x4, 0x1, 0x1, 0x0, 0x4, 0x2, 0x1, 0x2, 0x4, 0x0, 0x0, 0x0, 0x7, 0xF, 0x0, 0x0, 0x4, 0x1, 0xF, 0x7, 0x5, 0x0]
    outp = nibbler.send(:only_with_sysex_bytes, nibbles) { |b| b }
    assert_equal([0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7], outp[0])
    assert_equal([0xF, 0x0, 0x4, 0x1, 0x1, 0x0, 0x4, 0x2, 0x1, 0x2, 0x4, 0x0, 0x0, 0x0, 0x7, 0xF, 0x0, 0x0, 0x4, 0x1, 0xF, 0x7], outp[1])    
    assert_equal([0x5, 0x0], nibbles)

    nibbles = [0x9, 0x0, 0x4]
    outp = nibbler.send(:only_with_sysex_bytes, nibbles) { |b| b }
    assert_equal(nil, outp[0])
    assert_equal([], outp[1])        
    assert_equal([0x9, 0x0, 0x4], nibbles)
  end
  
  def test_nibbles_to_message
    nibbler = Nibbler.new
    sysex = [0xF, 0x0, 0x4, 0x1, 0x1, 0x0, 0x4, 0x2, 0x1, 0x2, 0x4, 0x0, 0x0, 0x0, 0x7, 0xF, 0x0, 0x0, 0x4, 0x1, 0xF, 0x7, 0x5, 0x0]
    short = [0x9, 0x0, 0x4, 0x0, 0x5, 0x0, 0x5, 0x0]
    outp = nibbler.send(:nibbles_to_message, short)
    assert_equal(MIDIMessage::NoteOn, outp[:message].class)
    assert_equal([0x5, 0x0], outp[:remaining])
    assert_equal([0x9, 0x0, 0x4, 0x0, 0x5, 0x0], outp[:processed])
    outp = nibbler.send(:nibbles_to_message, sysex)
    assert_equal(MIDIMessage::SystemExclusive::Command, outp[:message].class)
    assert_equal([0x5, 0x0], outp[:remaining])
    assert_equal([0xF, 0x0, 0x4, 0x1, 0x1, 0x0, 0x4, 0x2, 0x1, 0x2, 0x4, 0x0, 0x0, 0x0, 0x7, 0xF, 0x0, 0x0, 0x4, 0x1, 0xF, 0x7], outp[:processed])
  end
                 
end