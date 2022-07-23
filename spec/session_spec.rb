# frozen_string_literal: true

require 'helper'

describe Nibbler::Session do
  let!(:session) { Nibbler::Session.new }

  describe '#parse_string' do

  end

  describe '#parse' do
    let(:returned_messages) { session.parse(*input) }
    let(:returned_message) { returned_messages.first }
    let(:last_event) { session.events.last }

    context 'when there is a timestamp' do
      let(:timestamp) { Time.now.to_i }
      let(:returned_messages) { session.parse(0x90, 0x40, 0x40, timestamp: timestamp) }

      it 'returns correct message' do
        expect(returned_messages.count).to eq(1)
        expect(returned_message).to be_a(MIDIMessage::NoteOn)
        expect(returned_message.channel).to eq(0)
        expect(returned_message.note).to eq(0x40)
        expect(returned_message.velocity).to eq(0x40)
        expect(last_event.timestamp).to eq(timestamp)
      end
    end

    context 'when note off' do
      let(:input) { [0x80, 0x40, 0x40] }

      it 'returns correct message' do
        expect(returned_messages.count).to eq(1)
        expect(returned_message).to_not be_nil
        expect(returned_message).to be_a(MIDIMessage::NoteOff)
        expect(returned_message.channel).to eq(0)
        expect(returned_message.note).to eq(0x40)
        expect(returned_message.velocity).to eq(0x40)
      end
    end

    context 'when note on' do
      let(:input) { [0x90, 0x40, 0x40] }

      it 'returns correct message' do
        expect(returned_messages.count).to eq(1)
        expect(returned_message).to_not be_nil
        expect(returned_message).to be_a(MIDIMessage::NoteOn)
        expect(returned_message.channel).to eq(0)
        expect(returned_message.note).to eq(0x40)
        expect(returned_message.velocity).to eq(0x40)
      end
    end

    context 'when polyphonic aftertouch' do
      let(:input) { [0xA1, 0x40, 0x40] }

      it 'returns correct message' do
        expect(returned_messages.count).to eq(1)
        expect(returned_message).to_not be_nil
        expect(returned_message).to be_a(MIDIMessage::PolyphonicAftertouch)
        expect(returned_message.channel).to eq(1)
        expect(returned_message.note).to eq(0x40)
        expect(returned_message.value).to eq(0x40)
      end
    end

    context 'when control change' do
      let(:input) { [0xB2, 0x20, 0x20] }

      it 'returns correct message' do
        expect(returned_messages.count).to eq(1)
        expect(returned_message).to_not be_nil
        expect(returned_message).to be_a(MIDIMessage::ControlChange)
        expect(returned_message.channel).to eq(2)
        expect(returned_message.index).to eq(0x20)
        expect(returned_message.value).to eq(0x20)
      end
    end

    context 'when program change' do
      let(:input) { [0xC3, 0x40] }

      it 'returns correct message' do
        expect(returned_messages.count).to eq(1)
        expect(returned_message).to_not be_nil
        expect(returned_message).to be_a(MIDIMessage::ProgramChange)
        expect(returned_message.channel).to eq(3)
        expect(returned_message.program).to eq(0x40)
      end
    end

    context 'when channel aftertouch' do
      let(:input) { [0xD3, 0x50] }

      it 'returns correct message' do
        expect(returned_messages.count).to eq(1)
        expect(returned_message).to_not be_nil
        expect(returned_message).to be_a(MIDIMessage::ChannelAftertouch)
        expect(returned_message.channel).to eq(3)
        expect(returned_message.value).to eq(0x50)
      end
    end

    context 'when pitch bend' do
      let(:input) { [0xE0, 0x20, 0x00] } # center

      it 'returns correct message' do
        expect(returned_messages.count).to eq(1)
        expect(returned_message).to_not be_nil
        expect(returned_message).to be_a(MIDIMessage::PitchBend)
        expect(returned_message.channel).to eq(0)
        expect(returned_message.low).to eq(0x20)
        expect(returned_message.high).to eq(0x00)
      end
    end

    context 'when a 3-byte system common message' do
      let(:input) { [0xF2, 0x50, 0x20] }

      it 'returns correct message' do
        expect(returned_messages.count).to eq(1)
        expect(returned_message).to_not be_nil
        expect(returned_message).to be_a(MIDIMessage::SystemCommon)
        expect(returned_message.status[1]).to eq(0x2)
        expect(returned_message.data[0]).to eq(0x50)
        expect(returned_message.data[1]).to eq(0x20)
      end
    end

    context 'when a 2-byte system common message' do
      let(:input) { [0xF1, 0x50] }

      it 'returns correct message' do
        expect(returned_messages.count).to eq(1)
        expect(returned_message).to_not be_nil
        expect(returned_message).to be_a(MIDIMessage::SystemCommon)
        expect(returned_message.status[1]).to eq(0x1)
        expect(returned_message.data[0]).to eq(0x50)
      end
    end

    context 'when a 1-byte system common message' do
      let(:input) { [0xF6] }

      it 'returns correct message' do
        expect(returned_messages.count).to eq(1)
        expect(returned_message).to_not be_nil
        expect(returned_message).to be_a(MIDIMessage::SystemCommon)
        expect(returned_message.status[1]).to eq(0x6)
      end
    end

    context 'when system realtime' do
      let(:input) { [0xF8] }

      it 'returns correct message' do
        expect(returned_messages.count).to eq(1)
        expect(returned_message).to_not be_nil
        expect(returned_message).to be_a(MIDIMessage::SystemRealtime)
        expect(returned_message.id).to eq(0x8)
      end
    end
  end
end
