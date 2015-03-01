require "helper"
require "nibbler/midi-message"

class Nibbler::MIDIMessageTest < Minitest::Test

  context "MIDIMessage" do

    setup do
      @lib = Nibbler::MIDIMessage
    end

    context "note off" do

      setup do
        @message = @lib.note_off(0, 0x40, 0x40)
      end

      should "create correct message" do
        assert_equal(MIDIMessage::NoteOff, @message.class)
        assert_equal(0, @message.channel)
        assert_equal(0x40, @message.note)
        assert_equal(0x40, @message.velocity)
      end

    end

    context "note on" do

      setup do
        @message = @lib.note_on(0x0, 0x40, 0x40)
      end

      should "create correct message" do
        assert_equal(MIDIMessage::NoteOn, @message.class)
        assert_equal(0, @message.channel)
        assert_equal(0x40, @message.note)
        assert_equal(0x40, @message.velocity)
      end

    end

    context "polyphonic aftertouch" do

      setup do
        @message = @lib.polyphonic_aftertouch(0x1, 0x40, 0x40)
      end

      should "create correct message" do
        assert_equal(MIDIMessage::PolyphonicAftertouch, @message.class)
        assert_equal(1, @message.channel)
        assert_equal(0x40, @message.note)
        assert_equal(0x40, @message.value)
      end

    end

    context "control change" do

      setup do
        @message = @lib.control_change(0x2, 0x20, 0x20)
      end

      should "create correct message" do
        assert_equal(MIDIMessage::ControlChange, @message.class)
        assert_equal(@message.channel, 2)
        assert_equal(0x20, @message.index)
        assert_equal(0x20, @message.value)
      end

    end

    context "program change" do

      setup do
        @message = @lib.program_change(0x3, 0x40)
      end

      should "create correct message" do
        assert_equal(MIDIMessage::ProgramChange, @message.class)
        assert_equal(3, @message.channel)
        assert_equal(0x40, @message.program)
      end

    end

    context "channel aftertouch" do

      setup do
        @message = @lib.channel_aftertouch(0x3, 0x50)
      end

      should "create correct message" do
        assert_equal(MIDIMessage::ChannelAftertouch, @message.class)
        assert_equal(3, @message.channel)
        assert_equal(0x50, @message.value)
      end

    end

    context "pitch bend" do

      setup do
        @message = @lib.pitch_bend(0x0, 0x20, 0x00) # center
      end

      should "create correct message" do
        assert_equal(MIDIMessage::PitchBend, @message.class)
        assert_equal(0, @message.channel)
        assert_equal(0x20, @message.low)
        assert_equal(0x00, @message.high)
      end

    end

    context "system exclusive command" do

      setup do
        @message = @lib.system_exclusive(0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7)
      end

      should "create correct message" do
        assert_equal(MIDIMessage::SystemExclusive::Command, @message.class)
        assert_equal([0xF0, [0x41, 0x10, 0x42], 0x12, [0x40, 0x00, 0x7F], [0x00], 0x41, 0xF7], @message.to_a)
        assert_equal([0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7], @message.to_bytes)
        assert_equal("F04110421240007F0041F7", @message.to_hex_s)
      end

    end

    context "system exclusive request" do

      setup do
        @message = @lib.system_exclusive(0xF0, 0x41, 0x10, 0x42, 0x11, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7)
      end

      should "create correct message" do
        assert_equal(MIDIMessage::SystemExclusive::Request, @message.class)
        assert_equal([0xF0, [0x41, 0x10, 0x42], 0x11, [0x40, 0x00, 0x7F], [0x00, 0x00, 0x00], 0x41, 0xF7], @message.to_a)
        assert_equal([0xF0, 0x41, 0x10, 0x42, 0x11, 0x40, 0x00, 0x7F, 0x00, 0x00, 0x00, 0x41, 0xF7], @message.to_bytes)
        assert_equal("F04110421140007F00000041F7", @message.to_hex_s)
      end

    end

    context "system exclusive node" do

      setup do
        @message = @lib.system_exclusive(0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7)
        @node = @message.node
      end

      should "create correct message" do
        assert_equal(MIDIMessage::SystemExclusive::Node, @node.class)
        assert_equal(0x41, @node.manufacturer_id)
        assert_equal(0x42, @node.model_id)
        assert_equal(0x10, @node.device_id)
      end

    end

    context "system realtime" do

      setup do
        @message = @lib.system_realtime(0x8)
      end

      should "create correct message" do
        assert_equal(MIDIMessage::SystemRealtime, @message.class)
        assert_equal(8, @message.id)
      end

    end

    context "system common" do

      context "1 byte" do

        setup do
          @message = @lib.system_common(0x1)
        end

        should "create correct message" do
          assert_equal(MIDIMessage::SystemCommon, @message.class)
          assert_equal(1, @message.status[1])
        end

      end

      context "2 bytes" do

        setup do
          @message = @lib.system_common(0x1, 0x50)
        end

        should "create correct message" do
          assert_equal(MIDIMessage::SystemCommon, @message.class)
          assert_equal(1, @message.status[1])
          assert_equal(0x50, @message.data[0])
        end

      end

      context "3 bytes" do

        setup do
          @message = @lib.system_common(0x1, 0x50, 0xA0)
        end

        should "create correct message" do
          assert_equal(MIDIMessage::SystemCommon, @message.class)
          assert_equal(1, @message.status[1])
          assert_equal(0x50, @message.data[0])
          assert_equal(0xA0, @message.data[1])
        end

      end

    end

  end

end
