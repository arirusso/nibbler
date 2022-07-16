# frozen_string_literal: true

require 'helper'

describe Nibbler::Session do
  let(:session) { Nibbler::Session.new }
  let(:message) { session.parse(*input) }

  context 'when varying length strings' do
    let(:input) { %w[9 04 040] }

    it 'returns correct message' do
      expect(message).to_not be_nil
      expect(message).to be_a(MIDIMessage::NoteOn)
    end
  end

  context 'when there is a timestamp' do
    let(:timestamp) { Time.now.to_i }
    let(:report) { session.parse(0x90, 0x40, 0x40, timestamp: timestamp) }
    let(:message) { report[:messages] }

    it 'returns correct message and timestamp' do
      expect(message).to_not be_nil
      expect(message).to be_a(MIDIMessage::NoteOn)
      expect(message.channel).to eq(0)
      expect(message.note).to eq(0x40)
      expect(message.velocity).to eq(0x40)
      expect(report[:timestamp]).to eq(timestamp)
    end
  end

  context 'when note off' do
    let(:input) { [0x80, 0x40, 0x40] }

    it 'returns correct message' do
      expect(message).to_not be_nil
      expect(message).to be_a(MIDIMessage::NoteOff)
      expect(message.channel).to eq(0)
      expect(message.note).to eq(0x40)
      expect(message.velocity).to eq(0x40)
    end
  end

  context 'when note on' do
    let(:input) { [0x90, 0x40, 0x40] }

    it 'returns correct message' do
      expect(message).to_not be_nil
      expect(message).to be_a(MIDIMessage::NoteOn)
      expect(message.channel).to eq(0)
      expect(message.note).to eq(0x40)
      expect(message.velocity).to eq(0x40)
    end
  end

  context 'when polyphonic aftertouch' do
    let(:input) { [0xA1, 0x40, 0x40] }

    it 'returns correct message' do
      expect(message).to_not be_nil
      expect(message).to be_a(MIDIMessage::PolyphonicAftertouch)
      expect(message.channel).to eq(1)
      expect(message.note).to eq(0x40)
      expect(message.value).to eq(0x40)
    end
  end

  context 'when control change' do
    let(:input) { [0xB2, 0x20, 0x20] }

    it 'returns correct message' do
      expect(message).to_not be_nil
      expect(message).to be_a(MIDIMessage::ControlChange)
      expect(2).to eq(message.channel)
      expect(message.index).to eq(0x20)
      expect(message.value).to eq(0x20)
    end
  end

  context 'when program change' do
    let(:input) { [0xC3, 0x40] }

    it 'returns correct message' do
      expect(message).to_not be_nil
      expect(message).to be_a(MIDIMessage::ProgramChange)
      expect(message.channel).to eq(3)
      expect(message.program).to eq(0x40)
    end
  end

  context 'when channel aftertouch' do
    let(:input) { [0xD3, 0x50] }

    it 'returns correct message' do
      expect(message).to_not be_nil
      expect(message).to be_a(MIDIMessage::ChannelAftertouch)
      expect(message.channel).to eq(3)
      expect(message.value).to eq(0x50)
    end
  end

  context 'when pitch bend' do
    let(:input) { [0xE0, 0x20, 0x00] } # center

    it 'returns correct message' do
      expect(message).to_not be_nil
      expect(message).to be_a(MIDIMessage::PitchBend)
      expect(message.channel).to eq(0)
      expect(message.low).to eq(0x20)
      expect(message.high).to eq(0x00)
    end
  end

  context 'when a generic 3-byte system common message' do
    let(:input) { [0xF1, 0x50, 0xA0] }

    it 'returns correct message' do
      expect(message).to_not be_nil
      expect(message).to be_a(MIDIMessage::SystemCommon)
      expect(message.status[1]).to eq(1)
      expect(message.data[0]).to eq(0x50)
      expect(message.data[1]).to eq(0xA0)
    end
  end

  context 'when a generic 2-byte system common message' do
    let(:input) { [0xF1, 0x50] }

    it 'returns correct message' do
      expect(message).to_not be_nil
      expect(message).to be_a(MIDIMessage::SystemCommon)
      expect(message.status[1]).to eq(1)
      expect(message.data[0]).to eq(0x50)
    end
  end

  context 'when a generic 1-byte system common message' do
    let(:input) { 0xF1 }

    it 'returns correct message' do
      expect(message).to_not be_nil
      expect(message).to be_a(MIDIMessage::SystemCommon)
      expect(message.status[1]).to eq(1)
    end
  end

  context 'when system realtime' do
    let(:input) { 0xF8 }

    it 'returns correct message' do
      expect(message).to_not be_nil
      expect(message).to be_a(MIDIMessage::SystemRealtime)
      expect(message.id).to eq(8)
    end
  end
end
