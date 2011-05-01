#!/usr/bin/env ruby
#
# Walk through of different ways to use Nibbler
#

dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'

require 'nibbler'
require 'pp'

nibbler = Nibbler.new

  p nibbler.parse("90")
  nil

  p nibbler.parse("40")
  nil

  p nibbler.parse("40")


