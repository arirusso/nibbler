require "helper"

class MIDIMessageTest < Test::Unit::TestCase

  include TestHelper
 
  def test_note_off
    lib = Nibbler::MIDIMessage
    message = lib.note_off(0, 0x40, 0x40)
    assert_equal(MIDIMessage::NoteOff, message.class)
    assert_equal(0, message.channel)
    assert_equal(0x40, message.note)
    assert_equal(0x40, message.velocity)  
  end
  
  def test_note_on
    lib = Nibbler::MIDIMessage
    message = lib.note_on(0x0, 0x40, 0x40)
    assert_equal(MIDIMessage::NoteOn, message.class)
    assert_equal(0, message.channel)
    assert_equal(0x40, message.note)
    assert_equal(0x40, message.velocity)  
  end  
  
  def test_polyphonic_aftertouch
    lib = Nibbler::MIDIMessage
    message = lib.polyphonic_aftertouch(0x1, 0x40, 0x40)
    assert_equal(MIDIMessage::PolyphonicAftertouch, message.class)
    assert_equal(1, message.channel)
    assert_equal(0x40, message.note)
    assert_equal(0x40, message.value)      
  end  
  
  def test_control_change
    lib = Nibbler::MIDIMessage
    message = lib.control_change(0x2, 0x20, 0x20)
    assert_equal(MIDIMessage::ControlChange, message.class)
    assert_equal(message.channel, 2)
    assert_equal(0x20, message.index)
    assert_equal(0x20, message.value)    
  end
  
  def test_program_change
    lib = Nibbler::MIDIMessage
    message = lib.program_change(0x3, 0x40)
    assert_equal(MIDIMessage::ProgramChange, message.class)
    assert_equal(3, message.channel)
    assert_equal(0x40, message.program)  
  end
  
  def test_channel_aftertouch
    lib = Nibbler::MIDIMessage
    message = lib.channel_aftertouch(0x3, 0x50)
    assert_equal(MIDIMessage::ChannelAftertouch, message.class)
    assert_equal(3, message.channel)
    assert_equal(0x50, message.value)  
  end  
    
  def test_pitch_bend
    lib = Nibbler::MIDIMessage
    message = lib.pitch_bend(0x0, 0x20, 0x00) # center
    assert_equal(MIDIMessage::PitchBend, message.class)
    assert_equal(0, message.channel)
    assert_equal(0x20, message.low)
    assert_equal(0x00, message.high)  
  end   
  
  def test_system_exclusive_command
    lib = Nibbler::MIDIMessage
    message = lib.system_exclusive(0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7)   
    assert_equal(MIDIMessage::SystemExclusive::Command, message.class)
    assert_equal([0xF0, 0x41, 0x10, 0x42, 0x12, [0x40, 0x00, 0x7F], [0x00], 0x41, 0xF7], message.to_a)
    assert_equal([0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7], message.to_bytes)
    assert_equal("F04110421240007F0041F7", message.to_hex_s)
  end
  
  def test_system_exclusive_request
    lib = Nibbler::MIDIMessage
    message = lib.system_exclusive(0xF0, 0x41, 0x10, 0x42, 0x11, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7)   
    assert_equal(MIDIMessage::SystemExclusive::Request, message.class)
    assert_equal([0xF0, 0x41, 0x10, 0x42, 0x11, [0x40, 0x00, 0x7F], [0x00], 0x41, 0xF7], message.to_a)
    assert_equal([0xF0, 0x41, 0x10, 0x42, 0x11, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7], message.to_bytes)
    assert_equal("F04110421140007F0041F7", message.to_hex_s)
  end
  
  def test_system_exclusive_node
    lib = Nibbler::MIDIMessage
    message = lib.system_exclusive(0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7)
    node = message.node   
    assert_equal(MIDIMessage::SystemExclusive::Node, node.class)
    assert_equal(0x41, node.manufacturer_id)
    assert_equal(0x42, node.model_id)
    assert_equal(0x10, node.device_id)    
  end
   
  def test_system_common_generic_3_bytes
    lib = Nibbler::MIDIMessage
    message = lib.system_common(0x1, 0x50, 0xA0)
    assert_equal(MIDIMessage::SystemCommon, message.class)
    assert_equal(1, message.status[1])
    assert_equal(0x50, message.data[0])
    assert_equal(0xA0, message.data[1])  
  end    

  def test_system_common_generic_2_bytes
    nibbler = Nibbler.new
    message = nibbler.parse(0xF1, 0x50)
    assert_equal(MIDIMessage::SystemCommon, message.class)
    assert_equal(1, message.status[1])
    assert_equal(0x50, message.data[0])  
  end    

  def test_system_common_generic_1_byte
    nibbler = Nibbler.new
    message = nibbler.parse(0xF1)
    assert_equal(MIDIMessage::SystemCommon, message.class)
    assert_equal(1, message.status[1])
  end    
  
  def test_system_realtime
    nibbler = Nibbler.new
    message = nibbler.parse(0xF8)
    assert_equal(MIDIMessage::SystemRealtime, message.class)
    assert_equal(8, message.id)
  end        
   
end
