# frozen_string_literal: true

require 'helper'
require 'nibbler/midi-message'

describe Nibbler::MIDIMessage do
  let(:lib) { Nibbler::MIDIMessage }

  context 'when note off' do
    let(:message) { lib.note_off(0, 0x40, 0x40) }

    it 'creates correct message' do
      expect(message).to be_a(MIDIMessage::NoteOff)
      expect(message.channel).to eq(0)
      expect(message.note).to eq(0x40)
      expect(message.velocity).to eq(0x40)
    end
  end

  context 'when note on' do
    let(:message) { lib.note_on(0x0, 0x40, 0x40) }

    it 'creates correct message' do
      expect(message).to be_a(MIDIMessage::NoteOn)
      expect(message.channel).to eq(0)
      expect(message.note).to eq(0x40)
      expect(message.velocity).to eq(0x40)
    end
  end

  context 'when polyphonic aftertouch' do
    let(:message) { lib.polyphonic_aftertouch(0x1, 0x40, 0x40) }

    it 'creates correct message' do
      expect(message).to be_a(MIDIMessage::PolyphonicAftertouch)
      expect(message.channel).to eq(1)
      expect(message.note).to eq(0x40)
      expect(message.value).to eq(0x40)
    end
  end

  context 'when control change' do
    let(:message) { lib.control_change(0x2, 0x20, 0x20) }

    it 'creates correct message' do
      expect(message).to be_a(MIDIMessage::ControlChange)
      expect(message.channel).to eq(2)
      expect(message.index).to eq(0x20)
      expect(message.value).to eq(0x20)
    end
  end

  context 'when program change' do
    let(:message) { lib.program_change(0x3, 0x40) }

    it 'creates correct message' do
      expect(message).to be_a(MIDIMessage::ProgramChange)
      expect(message.channel).to eq(3)
      expect(message.program).to eq(0x40)
    end
  end

  context 'when channel aftertouch' do
    let(:message) { lib.channel_aftertouch(0x3, 0x50) }

    it 'creates correct message' do
      expect(message).to be_a(MIDIMessage::ChannelAftertouch)
      expect(message.channel).to eq(3)
      expect(message.value).to eq(0x50)
    end
  end

  context 'when pitch bend' do
    let(:message) { lib.pitch_bend(0x0, 0x20, 0x00) } # center

    it 'creates correct message' do
      expect(message).to be_a(MIDIMessage::PitchBend)
      expect(message.channel).to eq(0)
      expect(message.low).to eq(0x20)
      expect(message.high).to eq(0x00)
    end
  end

  context 'when system exclusive command' do
    let(:message) { lib.system_exclusive(0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7) }

    it 'creates correct message' do
      expect(message).to be_a(MIDIMessage::SystemExclusive::Command)
      expect(message.to_a).to eq([0xF0, [0x41, 0x10, 0x42], 0x12, [0x40, 0x00, 0x7F], [0x00], 0x41, 0xF7])
      expect(message.to_bytes).to eq([0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7])
      expect(message.to_hex_s).to eq('F04110421240007F0041F7')
    end
  end

  context 'when system exclusive request' do
    let(:message) { lib.system_exclusive(0xF0, 0x41, 0x10, 0x42, 0x11, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7) }

    it 'creates correct request message' do
      expect(message).to be_a(MIDIMessage::SystemExclusive::Request)
      expect(message.to_a).to eq([0xF0, [0x41, 0x10, 0x42], 0x11, [0x40, 0x00, 0x7F], [0x00, 0x00, 0x00], 0x41,
                                  0xF7])
      expect(message.to_bytes).to eq([0xF0, 0x41, 0x10, 0x42, 0x11, 0x40, 0x00, 0x7F, 0x00, 0x00, 0x00, 0x41, 0xF7])
      expect(message.to_hex_s).to eq('F04110421140007F00000041F7')
    end
  end

  context 'when system exclusive node' do
    let(:message) { lib.system_exclusive(0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7) }

    it 'creates correct node message' do
      expect(message.node).to be_a(MIDIMessage::SystemExclusive::Node)
      expect(message.node.manufacturer_id).to eq(0x41)
      expect(message.node.model_id).to eq(0x42)
      expect(message.node.device_id).to eq(0x10)
    end
  end

  context 'when system realtime' do
    let(:message) { lib.system_realtime(0x8) }

    it 'creates correct message' do
      expect(message).to be_a(MIDIMessage::SystemRealtime)
      expect(message.id).to eq(8)
    end
  end

  context 'when system common' do
    let(:message) { lib.system_common(0x1) }

    context 'when 1 byte' do
      it 'creates correct message' do
        expect(message).to be_a(MIDIMessage::SystemCommon)
        expect(message.status[1]).to eq(1)
      end
    end

    context 'when 2 bytes' do
      let(:message) { lib.system_common(0x1, 0x50) }

      it 'creates correct message' do
        expect(message).to be_a(MIDIMessage::SystemCommon)
        expect(message.status[1]).to eq(1)
        expect(message.data[0]).to eq(0x50)
      end
    end

    context 'when 3 bytes' do
      let(:message) { lib.system_common(0x1, 0x50, 0xA0) }

      it 'creates correct message' do
        expect(message).to be_a(MIDIMessage::SystemCommon)
        expect(message.status[1]).to eq(1)
        expect(message.data[0]).to eq(0x50)
        expect(message.data[1]).to eq(0xA0)
      end
    end
  end
end
