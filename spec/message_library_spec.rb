# frozen_string_literal: true

require 'helper'

describe Nibbler::MessageLibrary do
  describe '.adapter' do
    context 'when Midilib' do
      let(:adapter) { Nibbler::MessageLibrary.adapter(:midilib) }

      it 'sets to midilib' do
        expect(adapter).to eq(Nibbler::Midilib)
      end
    end

    context 'when MIDIMessage' do
      let(:adapter) { Nibbler::MessageLibrary.adapter(:midi_message) }

      it 'sets to midi message' do
        expect(adapter).to eq(Nibbler::MIDIMessage)
      end
    end
  end
end
