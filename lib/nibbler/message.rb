# frozen_string_literal: true

module Nibbler
  module Message
    CHANNEL = [
      {
        status: 0x8,
        name: :note_off,
        bytes: 3
      },
      {
        status: 0x9,
        name: :note_on,
        bytes: 3
      },
      {
        status: 0xA,
        name: :polyphonic_aftertouch,
        bytes: 3
      },
      {
        status: 0xB,
        name: :control_change,
        bytes: 3
      },
      {
        status: 0xC,
        name: :program_change,
        bytes: 2
      },
      {
        status: 0xD,
        name: :channel_aftertouch,
        bytes: 2
      },
      {
        status: 0xE,
        name: :pitch_bend,
        bytes: 3
      }
    ].freeze

    SYSTEM = [
      {
        status: 0x1,
        name: :system_common,
        bytes: 2
      },
      {
        status: 0x2,
        name: :system_common,
        bytes: 3
      },
      {
        status: 0x3,
        name: :system_common,
        bytes: 2
      },
      {
        status: 0x6,
        name: :system_common,
        bytes: 1
      },
      {
        status: 0x8,
        name: :system_realtime,
        bytes: 1
      },
      {
        status: 0x9,
        name: :system_realtime,
        bytes: 1
      },
      {
        status: 0xA,
        name: :system_realtime,
        bytes: 1
      },
      {
        status: 0xB,
        name: :system_realtime,
        bytes: 1
      },
      {
        status: 0xC,
        name: :system_realtime,
        bytes: 1
      },
      {
        status: 0xE,
        name: :system_realtime,
        bytes: 1
      },
      {
        status: 0xF,
        name: :system_realtime,
        bytes: 1
      }
    ].freeze
  end
end
