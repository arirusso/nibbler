require "helper"

class Nibbler::ParserTest < Minitest::Test

  context "Parser" do

    setup do
      @library = Nibbler::MessageLibrary.adapter
      @parser = Nibbler::Parser.new(@library)
    end

    context "#lookahead" do

      context "basic" do

        setup do
          @parser.instance_variable_set("@buffer", ["9", "0", "4", "0", "5", "0"])
          fragment = @parser.send(:get_fragment, 0)
          @output = @parser.send(:lookahead, fragment, Nibbler::MessageBuilder.for_channel_message(@library, 0x9))
        end

        should "return proper message" do
          assert_equal([0x90, 0x40, 0x50], @output[:message].to_a)
          assert_equal(["9", "0", "4", "0", "5", "0"], @output[:processed])
        end

      end

      context "with trailing nibbles" do

        setup do
          @parser.instance_variable_set("@buffer", ["9", "0", "4", "0", "5", "0", "5", "0"])
          fragment = @parser.send(:get_fragment, 0)
          @output = @parser.send(:lookahead, fragment, Nibbler::MessageBuilder.for_channel_message(@library, 0x9))
        end

        should "disregard trailing nibbles and return proper messages" do
          assert_equal([0x90, 0x40, 0x50], @output[:message].to_a)
          assert_equal(["9", "0", "4", "0", "5", "0"], @output[:processed])
        end

      end

      context "incomplete" do

        setup do
          @parser.instance_variable_set("@buffer", ["9", "0", "4"])
          fragment = @parser.send(:get_fragment, 0)
          @output = @parser.send(:lookahead, fragment, Nibbler::MessageBuilder.for_channel_message(@library, 0x9))
        end

        should "not return anything" do
          assert_nil @output
        end

      end

    end

    context "#lookahead_for_sysex" do

      context "basic" do

        setup do
          @parser.instance_variable_set("@buffer", "F04110421240007F0041F750".split(//))
          fragment = @parser.send(:get_fragment, 0)
          @output = @parser.send(:lookahead_for_sysex, fragment)
        end

        should "return proper message" do
          assert_equal([0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7], @output[:message].to_a.flatten)
          assert_equal("F04110421240007F0041F7".split(//), @output[:processed])
        end

      end

      context "incomplete" do

        setup do
          @parser.instance_variable_set("@buffer", ["9", "0", "4"])
          fragment = @parser.send(:get_fragment, 0)
          @output = @parser.send(:lookahead_for_sysex, fragment)
        end

        should "not return anything" do
          assert_nil @output
        end

      end
    end

    context "#process" do

      context "basic" do

        setup do
          short = ["9", "0", "4", "0", "5", "0", "5", "0"]
          @output = @parser.send(:process, short)
        end

        should "return proper message" do
          assert_equal(::MIDIMessage::NoteOn, @output[:messages].first.class)
          assert_equal(["9", "0", "4", "0", "5", "0"], @output[:processed])
        end

        should "have trailing nibbles in buffer" do
          assert_equal(["5", "0"], @parser.buffer)
        end

      end

      context "with running status" do

        setup do
          two_msgs = ["9", "0", "4", "0", "5", "0", "4", "0", "6", "0"]
          @output = @parser.send(:process, two_msgs)
        end

        should "return proper message" do
          refute_nil @output
          assert_equal(::MIDIMessage::NoteOn, @output[:messages][0].class)
          assert_equal(::MIDIMessage::NoteOn, @output[:messages][1].class)
          assert_equal(["9", "0", "4", "0", "5", "0", "4", "0", "6", "0"], @output[:processed])
        end

        should "not have anything left in the buffer" do
          assert_empty(@parser.buffer)
        end

      end

      context "with multiple overlapping calls" do

        setup do
          @short = ["9", "0", "4", "0", "5", "0", "9", "0"]
          @short2 = ["3", "0", "2", "0", "1", "0"]
        end

        should "return proper messages and have trailing nibbles in buffer" do
          @output = @parser.send(:process, @short)

          refute_nil @output
          assert_equal(::MIDIMessage::NoteOn, @output[:messages].first.class)
          assert_equal(["9", "0", "4", "0", "5", "0"], @output[:processed])
          assert_equal(["9", "0"], @parser.buffer)

          @output2 = @parser.send(:process, @short2)

          refute_nil @output2
          assert_equal(::MIDIMessage::NoteOn, @output2[:messages].first.class)
          assert_equal(["9", "0", "3", "0", "2", "0"], @output2[:processed])
          assert_equal(["1", "0"], @parser.buffer)
        end

      end

    end

    context "#nibbles_to_message" do

      context "basic" do

        setup do
          short = ["9", "0", "4", "0", "5", "0", "5", "0"]
          @parser.instance_variable_set("@buffer", short)
          fragment = @parser.send(:get_fragment, 0)
          @output = @parser.send(:nibbles_to_message, fragment)
        end

        should "return proper message" do
          refute_nil @output
          assert_equal(::MIDIMessage::NoteOn, @output[:message].class)
          assert_equal(["9", "0", "4", "0", "5", "0"], @output[:processed])
        end

      end

      context "with leading nibbles" do

        setup do
          short = ["5", "0", "9", "0", "4", "0", "5", "0"]
          @parser.instance_variable_set("@buffer", short)
          fragment = @parser.send(:get_fragment, 0)
          @output = @parser.send(:nibbles_to_message, fragment)
        end

        should "not do anything" do
          assert_nil @output
          assert_equal(["5", "0", "9", "0", "4", "0", "5", "0"], @parser.buffer)
        end

      end

      context "with trailing nibbles" do

        setup do
          short = ["9", "0", "4", "0", "5", "0", "5", "0"]
          @parser.instance_variable_set("@buffer", short)
          fragment = @parser.send(:get_fragment, 0)
          @output = @parser.send(:nibbles_to_message, fragment)
        end

        should "return proper message" do
          refute_nil @output
          assert_equal(::MIDIMessage::NoteOn, @output[:message].class)
          assert_equal(["9", "0", "4", "0", "5", "0"], @output[:processed])
        end

      end

      context "with running status" do

        setup do
          short = ["9", "0", "4", "0", "5", "0"]
          @parser.instance_variable_set("@buffer", short)
          fragment = @parser.send(:get_fragment, 0)
          @output = @parser.send(:nibbles_to_message, fragment)
          refute_nil @output
          assert_equal(::MIDIMessage::NoteOn, @output[:message].class)
          running_status = ["5", "0", "6", "0"]
          @parser.instance_variable_set("@buffer", running_status)
          fragment = @parser.send(:get_fragment, 0)
          @output = @parser.send(:nibbles_to_message, fragment)
        end

        should "return proper message" do
          refute_nil @output
          assert_equal(::MIDIMessage::NoteOn, @output[:message].class)
          assert_equal(["5", "0", "6", "0"], @output[:processed])
        end

      end

      context "sysex" do

        setup do
          sysex = "F04110421240007F0041F750".split(//)
          @parser.instance_variable_set("@buffer", sysex)
          fragment = @parser.send(:get_fragment, 0)
          @output = @parser.send(:nibbles_to_message, fragment)
        end

        should "return proper message" do
          refute_nil @output
          assert_equal(::MIDIMessage::SystemExclusive::Command, @output[:message].class)
          assert_equal("F04110421240007F0041F7".split(//), @output[:processed])
        end

      end

    end

  end

end
