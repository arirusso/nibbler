require "helper"

class Nibbler::MessageBuilderTest < Minitest::Test

  context "MessageBuilder" do

    context ".library" do

      should "be set to midi message by default" do
        assert_equal Nibbler::MIDIMessage, Nibbler::MessageBuilder.library
      end

    end

    context ".use_library" do

      context "Midilib" do

        setup do
          Nibbler::MessageBuilder.use_library(:midilib)
        end

        should "set to midilib" do
          assert_equal Nibbler::Midilib, Nibbler::MessageBuilder.library
        end

      end

      context "MIDIMessage" do

        setup do
          Nibbler::MessageBuilder.use_library(:midi_message)
        end

        should "set to midi message" do
          assert_equal Nibbler::MIDIMessage, Nibbler::MessageBuilder.library
        end

      end

    end

  end

end
