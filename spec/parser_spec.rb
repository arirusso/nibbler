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
end
