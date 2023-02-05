# frozen_string_literal: true

require 'helper'
require 'nibbler/midilib'

describe Nibbler::Midilib do
  let(:lib) { Nibbler::Midilib }

  context 'when note off' do
    let(:message) { lib.note_off(0x0, 0x40, 0x40) }
    it 'returns correct message' do
      expect(message).to be_a(MIDI::NoteOff)
      expect(message.channel).to eq(0)
      expect(message.note).to eq(0x40)
      expect(message.velocity).to eq(0x40)
    end
  end

  context 'when note on' do
    let(:message) { lib.note_on(0x0, 0x40, 0x40) }

    it 'returns correct message' do
      expect(message).to be_a(MIDI::NoteOn)
      expect(message.channel).to eq(0)
      expect(message.note).to eq(0x40)
      expect(message.velocity).to eq(0x40)
    end
  end

  context 'when polyphonic aftertouch' do
    let(:message) { lib.polyphonic_aftertouch(0x1, 0x40, 0x40) }

    it 'returns correct message' do
      expect(message).to be_a(MIDI::PolyPressure)
      expect(message.channel).to eq(1)
      expect(message.note).to eq(0x40)
      expect(message.pressure).to eq(0x40)
    end
  end

  context 'when control change' do
    let(:message) { lib.control_change(0x2, 0x20, 0x20) }

    it 'returns correct message' do
      expect(message).to be_a(MIDI::Controller)
      expect(2).to eq(message.channel)
      expect(message.controller).to eq(0x20)
      expect(message.value).to eq(0x20)
    end
  end

  context 'when program change' do
    let(:message) { lib.program_change(0x3, 0x40) }

    it 'returns correct message' do
      expect(message).to be_a(MIDI::ProgramChange)
      expect(message.channel).to eq(3)
      expect(message.program).to eq(0x40)
    end
  end

  context 'when channel aftertouch' do
    let(:message) { lib.channel_aftertouch(0x3, 0x50) }

    it 'returns correct message' do
      expect(message).to be_a(MIDI::ChannelPressure)
      expect(message.channel).to eq(3)
      expect(message.pressure).to eq(0x50)
    end
  end

  context 'when pitch bend' do
    let(:message) { lib.pitch_bend(0x0, 0x10, 0x3f) }

    it 'returns correct message' do
      expect(message).to be_a(MIDI::PitchBend)
      expect(message.channel).to eq(0)
      expect(message.value).to eq(8080)
    end
  end

  context 'when system exclusive' do
    let(:message) { lib.system_exclusive(0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7) }

    it 'returns correct message' do
      expect(message).to be_a(MIDI::SystemExclusive)
      expect(message.data).to eq([0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7])
    end
  end

  context 'when song pointer' do
    let(:message) { lib.system_common(0x2, 0x6d, 0x01) }

    it 'returns correct message' do
      expect(message).to be_a(MIDI::SongPointer)
      expect(message.pointer).to eq(237)
    end
  end

  context 'when song select' do
    let(:message) { lib.system_common(0x3, 0xA0) }

    it 'returns correct message' do
      expect(message).to be_a(MIDI::SongSelect)
      expect(message.song).to eq(0xA0)
    end
  end

  context 'when tune request' do
    let(:message) { lib.system_common(0x6) }

    it 'returns correct message' do
      expect(message).to be_a(MIDI::TuneRequest)
    end
  end

  context 'when clock' do
    let(:message) { lib.system_realtime(0x8) }

    it 'returns correct message' do
      expect(message).to be_a(MIDI::Clock)
    end
  end

  context 'when start' do
    let(:message) { lib.system_realtime(0xA) }

    it 'returns correct message' do
      expect(message).to be_a(MIDI::Start)
    end
  end

  context 'when continue' do
    let(:message) { lib.system_realtime(0xB) }

    it 'returns correct message' do
      expect(message).to be_a(MIDI::Continue)
    end
  end

  context 'when stop' do
    let(:message) { lib.system_realtime(0xC) }

    it 'returns correct message' do
      expect(message).to be_a(MIDI::Stop)
    end
  end

  context 'when sense' do
    let(:message) { lib.system_realtime(0xE) }

    it 'returns correct message' do
      expect(message).to be_a(MIDI::ActiveSense)
    end
  end

  context 'when reset' do
    let(:message) { lib.system_realtime(0xF) }

    it 'returns correct message' do
      expect(message).to be_a(MIDI::SystemReset)
    end
  end
end
