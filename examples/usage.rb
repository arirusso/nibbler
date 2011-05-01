#!/usr/bin/env ruby
#
# Walk through of different ways to use Nibbler
#

dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'

require 'nibbler'
require 'pp'

nibbler = Nibbler.new

pp nibbler.parse(0x90, 0x40)

pp nibbler.buffer

pp nibbler.clear_buffer

pp nibbler.parse(0x90, 0x40, 0x40)

pp nibbler.buffer
