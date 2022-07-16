# frozen_string_literal: true

require 'helper'

describe 'rejected nibbles' do
  let(:nibbler) { Nibbler.new }
  let!(:message) { nibbler.parse(*input) }

  context 'when leading chars' do
    let(:input) { %w[0 9 04 040] }

    it 'returns correct message' do
      expect(message).to be_a(MIDIMessage::NoteOn)
    end

    it 'rejects extra char' do
      expect(nibbler.rejected).to_not be_empty
      expect(nibbler.rejected.first).to eq('0')
    end
  end

  context 'when 2 leading chars' do
    let(:input) { %w[1 0 9 04 040] }

    it 'rejects two leading chars' do
      expect(nibbler.rejected).to_not be_empty
      expect(nibbler.rejected[0]).to eq('1')
      expect(nibbler.rejected[1]).to eq('0')
    end
  end

  context 'when leading string' do
    let(:input) { %w[10 9 04 040] }

    it 'returns correct message' do
      expect(message).to be_a(MIDIMessage::NoteOn)
    end

    it 'rejects chars in leading string' do
      expect(nibbler.rejected).to_not be_empty
      expect(nibbler.rejected[0]).to eq('1')
      expect(nibbler.rejected[1]).to eq('0')
    end
  end

  context 'when long leading string' do
    let(:input) { %w[000001000010 9 04 040] }

    it 'returns correct message' do
      expect(message).to be_a(MIDIMessage::NoteOn)
    end

    it 'returns string' do
      expect(nibbler.rejected).to_not be_empty
      expect(nibbler.rejected).to eq('000001000010'.split(//))
    end
  end

  context 'when long leading string overlap' do
    let(:input) { %w[000001000010090 4 040] }

    it 'returns correct message' do
      expect(message).to be_a(MIDIMessage::NoteOn)
    end

    it 'returns leading string' do
      expect(nibbler.rejected).to_not be_empty
      expect(nibbler.rejected).to eq('0000010000100'.split(//))
    end
  end

  context 'when leading number' do
    let(:input) { [0x30, '9', '04', '040'] }

    it 'returns correct message' do
      expect(message).to be_a(MIDIMessage::NoteOn)
    end

    it 'returns leading numbers' do
      expect(nibbler.rejected).to_not be_empty
      expect(nibbler.rejected[0]).to eq('3')
      expect(nibbler.rejected[1]).to eq('0')
    end
  end

  context 'when 2 leading numbers' do
    let(:input) { [0x60, 0x30, '9', '04', '040'] }

    it 'returns correct message' do
      expect(message).to be_a(MIDIMessage::NoteOn)
    end

    it 'returns leading numbers' do
      expect(nibbler.rejected).to_not be_empty
      expect(nibbler.rejected[0]).to eq('6')
      expect(nibbler.rejected[1]).to eq('0')
      expect(nibbler.rejected[2]).to eq('3')
      expect(nibbler.rejected[3]).to eq('0')
    end
  end

  context 'when 3 leading numbers' do
    let(:input) { [0x00, 0x30, '9', '04', '040'] }

    it 'returns correct message' do
      expect(message).to be_a(MIDIMessage::NoteOn)
    end

    it 'returns leading numbers' do
      expect(nibbler.rejected).to_not be_empty
      expect(nibbler.rejected[0]).to eq('0')
      expect(nibbler.rejected[1]).to eq('0')
      expect(nibbler.rejected[2]).to eq('3')
      expect(nibbler.rejected[3]).to eq('0')
    end
  end
end
