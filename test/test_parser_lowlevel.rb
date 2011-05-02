#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/test_helper'

class LowlevelTest < Test::Unit::TestCase

  include Nibbler
  include TestHelper
  
  def test_nibbles_to_bytes  
    nibbler = Nibbler.new
    nibbles = ["4", "5", "9", "3"]
    bytes = nibbler.send(:nibbles_to_bytes, nibbles)
    assert_equal(["4", "5", "9", "3"], nibbles)
    assert_equal([0x45, 0x93], bytes) 
  end
    
  def test_only_with_bytes
    nibbler = Nibbler.new
    num_bytes = 3
    nibbles = ["9", "0", "4", "0", "5", "0", "5", "0"]
    outp = nibbler.send(:only_with_bytes, num_bytes, nibbles) { |b| b }
    assert_equal([0x90, 0x40, 0x50], outp[0])
    assert_equal(["9", "0", "4", "0", "5", "0"], outp[1])    
    assert_equal(["5", "0"], nibbles)
    nibbles = ["9", "0", "4"]
    outp = nibbler.send(:only_with_bytes, num_bytes, nibbles) { |b| b }
    assert_equal(nil, outp[0])
    assert_equal([], outp[1])        
    assert_equal(["9", "0", "4"], nibbles)
  end
  
  def test_only_with_sysex_bytes
    nibbler = Nibbler.new
    nibbles = ["F", "0", "4", "1", "1", "0", "4", "2", "1", "2", "4", "0", "0", "0", "7", "F", "0", "0", "4", "1", "F", "7", "5", "0"]
    outp = nibbler.send(:only_with_sysex_bytes, nibbles) { |b| b }
    assert_equal([0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7], outp[0])
    assert_equal(["F", "0", "4", "1", "1", "0", "4", "2", "1", "2", "4", "0", "0", "0", "7", "F", "0", "0", "4", "1", "F", "7"], outp[1])    
    assert_equal(["5", "0"], nibbles)

    nibbles = ["9", "0", "4"]
    outp = nibbler.send(:only_with_sysex_bytes, nibbles) { |b| b }
    assert_equal(nil, outp[0])
    assert_equal([], outp[1])        
    assert_equal(["9", "0", "4"], nibbles)
  end
  
  def test_nibbles_to_message
    nibbler = Nibbler.new
    #sysex = ['F', '0', '4', '1', '1', '0', '4', "2, "1, "2, "4, "0, "0, "0, "7, "F, "0, "0, "4, "1, "F, "7, "5, "0]
    short = ['9', '0', '4', '0', '5', '0', '5', '0']
    outp = nibbler.send(:nibbles_to_message, short)
    assert_equal(MIDIMessage::NoteOn, outp[:message].class)
    assert_equal(['5', '0'], outp[:remaining])
    assert_equal(['9', '0', '4', '0', '5', '0'], outp[:processed])
    #outp = nibbler.send(:nibbles_to_message, sysex)
    #assert_equal(MIDIMessage::SystemExclusive::Command, outp[:message].class)
    #assert_equal([0x5, "0], outp[:remaining])
    #assert_equal([0xF, "0, "4, "1, "1, "0, "4, "2, "1, "2, "4, "0, "0, "0, "7, "F, "0, "0, "4, "1, "F, "7], outp[:processed])
  end
                 
end