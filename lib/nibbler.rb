# frozen_string_literal: true

#
# Nibbler
# Parse MIDI Messages
# (c)2011-2022 Ari Russo and licensed under the Apache 2.0 License
#

# libs
require 'forwardable'

# modules
require 'nibbler/data_processor'
require 'nibbler/type_conversion'

# classes
require 'nibbler/message_builder'
require 'nibbler/message_library'
require 'nibbler/parser'
require 'nibbler/session'

#
# Parse MIDI Messages
#
module Nibbler
  VERSION = '0.2.4'

  # Shortcut to a new session object
  def self.new(*args, &block)
    Session.new(*args, &block)
  end
end
