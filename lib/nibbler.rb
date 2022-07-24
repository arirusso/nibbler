# frozen_string_literal: true

#
# Nibbler
# Parse MIDI Messages
# (c)2011-2022 Ari Russo and licensed under the Apache 2.0 License
#

# libs
require 'forwardable'

# modules
require 'nibbler/message'
require 'nibbler/util'

# classes
require 'nibbler/message_builder'
require 'nibbler/message_library'
require 'nibbler/parser'
require 'nibbler/session'

#
# Parse MIDI Messages
#
module Nibbler
  VERSION = '0.3.0'

  # Shortcut to a new session object
  # @param [Symbol] message_lib The name of a message library module eg :midilib or :midi_message
  # @return [Nibbler::Session]
  def self.new(message_lib: nil)
    Session.new(message_lib: message_lib)
  end
end
