require "helper"

class Nibbler::MessageLibraryTest < Minitest::Test

  context "MessageLibrary" do

    context ".adapter" do

      context "Midilib" do

        setup do
          @adapter = Nibbler::MessageLibrary.adapter(:midilib)
        end

        should "set to midilib" do
          assert_equal Nibbler::Midilib, @adapter
        end

      end

      context "MIDIMessage" do

        setup do
          @adapter = Nibbler::MessageLibrary.adapter(:midi_message)
        end

        should "set to midi message" do
          assert_equal Nibbler::MIDIMessage, @adapter
        end

      end

    end

  end

end
