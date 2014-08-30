require "helper"

class MIDIMessageFactoryTest < Test::Unit::TestCase

  include Nibbler
  include TestHelper
 
  def test_note_off
    factory = MIDIMessageFactory.new
    msg = factory.note_off(0, 0x40, 0x40)
    assert_equal(MIDIMessage::NoteOff, msg.class)
    assert_equal(0, msg.channel)
    assert_equal(0x40, msg.note)
    assert_equal(0x40, msg.velocity)  
  end
  
  def test_note_on
    factory = MIDIMessageFactory.new
    msg = factory.note_on(0x0, 0x40, 0x40)
    assert_equal(MIDIMessage::NoteOn, msg.class)
    assert_equal(0, msg.channel)
    assert_equal(0x40, msg.note)
    assert_equal(0x40, msg.velocity)  
  end  
  
  def test_polyphonic_aftertouch
    factory = MIDIMessageFactory.new
    msg = factory.polyphonic_aftertouch(0x1, 0x40, 0x40)
    assert_equal(MIDIMessage::PolyphonicAftertouch, msg.class)
    assert_equal(1, msg.channel)
    assert_equal(0x40, msg.note)
    assert_equal(0x40, msg.value)      
  end  
  
  def test_control_change
    factory = MIDIMessageFactory.new
    msg = factory.control_change(0x2, 0x20, 0x20)
    assert_equal(MIDIMessage::ControlChange, msg.class)
    assert_equal(msg.channel, 2)
    assert_equal(0x20, msg.index)
    assert_equal(0x20, msg.value)    
  end
  
  def test_program_change
    factory = MIDIMessageFactory.new
    msg = factory.program_change(0x3, 0x40)
    assert_equal(MIDIMessage::ProgramChange, msg.class)
    assert_equal(3, msg.channel)
    assert_equal(0x40, msg.program)  
  end
  
  def test_channel_aftertouch
    factory = MIDIMessageFactory.new
    msg = factory.channel_aftertouch(0x3, 0x50)
    assert_equal(MIDIMessage::ChannelAftertouch, msg.class)
    assert_equal(3, msg.channel)
    assert_equal(0x50, msg.value)  
  end  
    
  def test_pitch_bend
    factory = MIDIMessageFactory.new
    msg = factory.pitch_bend(0x0, 0x20, 0x00) # center
    assert_equal(MIDIMessage::PitchBend, msg.class)
    assert_equal(0, msg.channel)
    assert_equal(0x20, msg.low)
    assert_equal(0x00, msg.high)  
  end   
  
  def test_system_exclusive_command
    factory = MIDIMessageFactory.new
    msg = factory.system_exclusive(0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7)   
    assert_equal(MIDIMessage::SystemExclusive::Command, msg.class)
    assert_equal([0xF0, 0x41, 0x10, 0x42, 0x12, [0x40, 0x00, 0x7F], [0x00], 0x41, 0xF7], msg.to_a)
    assert_equal([0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7], msg.to_bytes)
    assert_equal("F04110421240007F0041F7", msg.to_hex_s)
  end
  
  def test_system_exclusive_request
    factory = MIDIMessageFactory.new
    msg = factory.system_exclusive(0xF0, 0x41, 0x10, 0x42, 0x11, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7)   
    assert_equal(MIDIMessage::SystemExclusive::Request, msg.class)
    assert_equal([0xF0, 0x41, 0x10, 0x42, 0x11, [0x40, 0x00, 0x7F], [0x00], 0x41, 0xF7], msg.to_a)
    assert_equal([0xF0, 0x41, 0x10, 0x42, 0x11, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7], msg.to_bytes)
    assert_equal("F04110421140007F0041F7", msg.to_hex_s)
  end
  
  def test_system_exclusive_node
    factory = MIDIMessageFactory.new
    msg = factory.system_exclusive(0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7)
    node = msg.node   
    assert_equal(MIDIMessage::SystemExclusive::Node, node.class)
    assert_equal(0x41, node.manufacturer_id)
    assert_equal(0x42, node.model_id)
    assert_equal(0x10, node.device_id)    
  end
   
  def test_system_common_generic_3_bytes
    factory = MIDIMessageFactory.new
    msg = factory.system_common(0x1, 0x50, 0xA0)
    assert_equal(MIDIMessage::SystemCommon, msg.class)
    assert_equal(1, msg.status[1])
    assert_equal(0x50, msg.data[0])
    assert_equal(0xA0, msg.data[1])  
  end    

  def test_system_common_generic_2_bytes
    nibbler = Nibbler.new
    msg = nibbler.parse(0xF1, 0x50)
    assert_equal(MIDIMessage::SystemCommon, msg.class)
    assert_equal(1, msg.status[1])
    assert_equal(0x50, msg.data[0])  
  end    

  def test_system_common_generic_1_byte
    nibbler = Nibbler.new
    msg = nibbler.parse(0xF1)
    assert_equal(MIDIMessage::SystemCommon, msg.class)
    assert_equal(1, msg.status[1])
  end    
  
  def test_system_realtime
    nibbler = Nibbler.new
    msg = nibbler.parse(0xF8)
    assert_equal(MIDIMessage::SystemRealtime, msg.class)
    assert_equal(8, msg.id)
  end        
   
end
