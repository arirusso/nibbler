require "helper"

class Nibbler::ParserRejectedTest < Minitest::Test

  context "Rejected" do

    setup do
      @nibbler = Nibbler.new
    end

    context "leading chars" do

      setup do
        @message = @nibbler.parse("0", "9", "04", "040")
      end

      should "return correct message" do
        assert_equal(::MIDIMessage::NoteOn, @message.class)
      end

      should "reject extra char" do
        refute_empty @nibbler.rejected
        assert_equal("0", @nibbler.rejected.first)
      end

    end

    context "2 leading chars" do

      setup do
        @message = @nibbler.parse("1", "0", "9", "04", "040")
      end

      should "reject two leading chars" do
        refute_empty @nibbler.rejected
        assert_equal "1", @nibbler.rejected[0]
        assert_equal "0", @nibbler.rejected[1]
      end

    end

    context "leading string" do

      setup do
        @message = @nibbler.parse("10", "9", "04", "040")
      end

      should "return correct message" do
        assert_equal(::MIDIMessage::NoteOn, @message.class)
      end

      should "reject chars in leading string" do
        refute_empty @nibbler.rejected
        assert_equal "1", @nibbler.rejected[0]
        assert_equal "0", @nibbler.rejected[1]
      end

    end

    context "long leading string" do

      setup do
        @message = @nibbler.parse("000001000010", "9", "04", "040")
      end

      should "return correct message" do
        assert_equal(::MIDIMessage::NoteOn, @message.class)
      end

      should "return string" do
        refute_empty @nibbler.rejected
        assert_equal("000001000010".split(//), @nibbler.rejected)
      end

    end

    context "long leading string overlap" do

      setup do
        @message = @nibbler.parse("000001000010090", "4", "040")
      end

      should "return correct message" do
        assert_equal(::MIDIMessage::NoteOn, @message.class)
      end

      should "return leading string" do
        refute_empty @nibbler.rejected
        assert_equal("0000010000100".split(//), @nibbler.rejected)
      end

    end

    context "leading number" do

      setup do
        @message = @nibbler.parse(0x30, "9", "04", "040")
      end

      should "return correct message" do
        assert_equal(::MIDIMessage::NoteOn, @message.class)
      end

      should "return leading numbers" do
        refute_empty @nibbler.rejected
        assert_equal "3", @nibbler.rejected[0]
        assert_equal "0", @nibbler.rejected[1]
      end

    end

    context "2 leading numbers" do

      setup do
        @message = @nibbler.parse(0x60, 0x30, "9", "04", "040")
      end

      should "return correct message" do
        assert_equal(::MIDIMessage::NoteOn, @message.class)
      end

      should "return leading numbers" do
        refute_empty @nibbler.rejected
        assert_equal "6", @nibbler.rejected[0]
        assert_equal "0", @nibbler.rejected[1]
        assert_equal "3", @nibbler.rejected[2]
        assert_equal "0", @nibbler.rejected[3]
      end

    end

    context "3 leading numbers" do

      setup do
        @message = @nibbler.parse(0x00, 0x30, "9", "04", "040")
      end

      should "return correct message" do
        assert_equal(::MIDIMessage::NoteOn, @message.class)
      end

      should "return leading numbers" do
        refute_empty @nibbler.rejected
        assert_equal "0", @nibbler.rejected[0]
        assert_equal "0", @nibbler.rejected[1]
        assert_equal "3", @nibbler.rejected[2]
        assert_equal "0", @nibbler.rejected[3]
      end

    end

  end

end
