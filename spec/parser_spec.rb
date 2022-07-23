# frozen_string_literal: true

require 'helper'

describe Nibbler::Parser do
  let(:library) { Nibbler::MessageLibrary.adapter }
  let(:parser) { Nibbler::Parser.new(library) }

  describe '#process' do
    let!(:output) { parser.process(*input) }

    context 'when basic' do
      let(:input) { [0x90, 0x40, 0x50] }

      it 'returns correct message' do
        expect(output.messages.first).to be_a(MIDIMessage::NoteOn)
        expect(output.processed).to eq([0x90, 0x40, 0x50])
      end

      it 'has nothing in buffer' do
        expect(parser.buffer).to be_empty
      end
    end

    context 'has trailing byte' do
      let(:input) { [0x90, 0x40, 0x50, 0x50] }

      it 'returns correct message' do
        expect(output.messages.first).to be_a(MIDIMessage::NoteOn)
        expect(output.processed).to eq([0x90, 0x40, 0x50])
      end

      it 'has trailing byte in buffer' do
        expect(parser.buffer).to eq([0x50])
      end
    end

    context 'has leading byte' do
      let(:input) { [0x40, 0x90, 0x40, 0x50] }

      it 'returns correct message' do
        expect(output.messages.first).to be_a(MIDIMessage::NoteOn)
        expect(output.processed).to eq([0x90, 0x40, 0x50])
      end

      it 'has leading byte as other' do
        expect(output.other).to eq([0x40])
      end
    end

    context 'with running status' do
      let(:input) { [0x90, 0x40, 0x50, 0x40, 0x60] }

      it 'returns correct message' do
        expect(output).to_not be_nil
        expect(output.messages[0]).to be_a(MIDIMessage::NoteOn)
        expect(output.messages[1]).to be_a(MIDIMessage::NoteOn)
        expect(output.processed).to eq([0x90, 0x40, 0x50, 0x40, 0x60])
      end

      it 'has nothing left in the buffer' do
        expect(parser.buffer).to be_empty
      end
    end

    context 'with multiple overlapping calls' do
      let(:input) { [0x90, 0x40, 0x50, 0x90] }
      let(:next_input) { [0x30, 0x20, 0x10] }
      let(:next_output) { parser.process(*next_input) }

      it 'returns correct messages and have trailing nibbles in buffer' do
        expect(output).to_not be_nil
        expect(output.messages.first).to be_a(MIDIMessage::NoteOn)
        expect(output.processed).to eq([0x90, 0x40, 0x50])
        expect(parser.buffer).to eq([0x90])

        expect(next_output).to_not be_nil
        expect(next_output.messages.first).to be_a(MIDIMessage::NoteOn)
        expect(next_output.processed).to eq([0x90, 0x30, 0x20])
        expect(parser.buffer).to eq([0x10])
      end
    end

    describe 'specific message types' do
      context 'when system common' do
        let(:input) { [0xF1, 0x50] }
        let(:message) { output.messages.first }

        it 'returns correct message' do
          expect(message).to_not be_nil
          expect(message).to be_a(MIDIMessage::SystemCommon)
          expect(message.status[1]).to eq(1)
          expect(message.data[0]).to eq(0x50)
        end
      end

      context 'when system realtime' do
        let(:input) { [0xFF] }
        let(:message) { output.messages.first }

        it 'returns correct message' do
          expect(message).to_not be_nil
          expect(message).to be_a(MIDIMessage::SystemRealtime)
          expect(message.status[1]).to eq(0xF)
          expect(message.to_a).to eq([0xFF])
        end
      end

      context 'when sysex' do
        let(:sysex) { [0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7, 0x50] }
        let(:output) { parser.process(*sysex) }

        it 'returns correct message' do
          expect(output).to_not be_nil
          expect(output.messages.first).to be_a(MIDIMessage::SystemExclusive::Command)
          expect(output.processed).to eq([0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7])
        end

        it 'leaves trailing byte in buffer' do
          expect(parser.buffer).to eq([0x50])
        end
      end
    end
  end

  # describe '#lookahead' do
  #   let(:output) do
  #     parser.send(:lookahead, fragment, Nibbler::MessageBuilder.for_channel_message(library, 0x9))
  #   end
  #   before { parser.instance_variable_set('@buffer', input) }
  #
  #   context 'when basic' do
  #     let(:input) { %w[9 0 4 0 5 0] }
  #
  #     it 'returns correct message' do
  #       expect(output.message.to_a).to eq([0x90, 0x40, 0x50])
  #       expect(output.processed).to eq(input)
  #     end
  #   end
  #
  #   context 'with trailing nibbles' do
  #     let(:input) { %w[9 0 4 0 5 0 5 0] }
  #
  #     it 'disregards trailing nibbles and returns correct messages' do
  #       expect(output.message.to_a).to eq([0x90, 0x40, 0x50])
  #       expect(output.processed).to eq(%w[9 0 4 0 5 0])
  #     end
  #   end
  #
  #   context 'when incomplete' do
  #     let(:input) { %w[9 0 4] }
  #
  #     it 'returns nil' do
  #       expect(output).to be_nil
  #     end
  #   end
  # end
  #
  # describe '#lookahead_for_sysex' do
  #   let(:output) do
  #     parser.send(:lookahead_for_sysex, fragment)
  #   end
  #   before { parser.instance_variable_set('@buffer', input) }
  #
  #   context 'when basic' do
  #     let(:input) { 'F04110421240007F0041F750'.split(//) }
  #
  #     it 'returns correct message' do
  #       expect(output.message.to_a.flatten).to eq([0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7])
  #       expect(output.processed).to eq('F04110421240007F0041F7'.split(//))
  #     end
  #   end
  #
  #   context 'when incomplete' do
  #     let(:input) { %w[9 0 4] }
  #
  #     it 'returns nothing' do
  #       expect(output).to be_nil
  #     end
  #   end
  # end
  #
  # describe '#nibbles_to_message' do
  #   context 'when basic' do
  #     let(:input) { %w[9 0 4 0 5 0 5 0] }
  #     let(:output) { parser.send(:nibbles_to_message, fragment) }
  #     before { parser.instance_variable_set('@buffer', input) }
  #
  #     it 'returns correct message' do
  #       expect(output).to_not be_nil
  #       expect(output.message).to be_a(MIDIMessage::NoteOn)
  #       expect(output.processed).to eq(%w[9 0 4 0 5 0])
  #     end
  #   end
  #
  #   context 'with leading nibbles' do
  #     let(:input) { %w[5 0 9 0 4 0 5 0] }
  #     let(:output) { parser.send(:nibbles_to_message, fragment) }
  #     before do
  #       parser.instance_variable_set('@buffer', input)
  #     end
  #
  #     it 'returns nothing' do
  #       expect(output).to be_nil
  #       expect(parser.buffer).to eq(%w[5 0 9 0 4 0 5 0])
  #     end
  #   end
  #
  #   context 'with trailing nibbles' do
  #     let(:input) { %w[9 0 4 0 5 0 5 0] }
  #     let(:output) { parser.send(:nibbles_to_message, fragment) }
  #     before do
  #       parser.instance_variable_set('@buffer', input)
  #     end
  #
  #     it 'returns correct message' do
  #       expect(output).to_not be_nil
  #       expect(output.message).to be_a(MIDIMessage::NoteOn)
  #       expect(output.processed).to eq(%w[9 0 4 0 5 0])
  #     end
  #   end
  #
  #   context 'with running status' do
  #     let(:first_input) { %w[9 0 4 0 5 0] }
  #     let(:second_input) { %w[5 0 6 0] }
  #     let(:first_output) do
  #       parser.instance_variable_set('@buffer', first_input)
  #       parser.send(:nibbles_to_message, fragment)
  #     end
  #     let(:second_output) do
  #       parser.instance_variable_set('@buffer', second_input)
  #       fragment = parser.send(:get_fragment_from_buffer, 0)
  #       parser.send(:nibbles_to_message, fragment)
  #     end
  #
  #     it 'returns correct messages' do
  #       expect(first_output).to_not be_nil
  #       expect(first_output.message).to be_a(MIDIMessage::NoteOn)
  #       expect(first_output.processed).to eq(%w[9 0 4 0 5 0])
  #
  #       expect(second_output).to_not be_nil
  #       expect(second_output.message).to be_a(MIDIMessage::NoteOn)
  #       expect(second_output.message).to_not eq(first_output.message)
  #       expect(second_output.processed).to eq(%w[5 0 6 0])
  #     end
  #   end
  #
  #   context 'when sysex' do
  #     let(:sysex) { 'F04110421240007F0041F750'.split(//) }
  #     let(:output) { parser.send(:nibbles_to_message, fragment) }
  #     before do
  #       parser.instance_variable_set('@buffer', sysex)
  #     end
  #
  #     it 'returns correct message' do
  #       expect(output).to_not be_nil
  #       expect(output.message).to be_a(MIDIMessage::SystemExclusive::Command)
  #       expect(output.processed).to eq('F04110421240007F0041F7'.split(//))
  #     end
  #   end
  # end
end
