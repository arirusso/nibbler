#!/usr/bin/env ruby
#
module Nibbler

  # factory for constructing messages with {midilib}(https://github.com/jimm/midilib)
  # midilib is copyright © 2003-2010 Jim Menard
  class MidilibFactory
  
    def initialize
      require 'midilib'
    end
    
  end

end