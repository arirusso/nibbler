module Nibbler
 
  # A parser session
  #
  # Holds on to data that is not relevant to the parser between calls. For instance,
  # past messages, rejected bytes
  #
  class Session

    extend Forwardable

    attr_reader :messages,
                :processed,
                :rejected
    
    def_delegators :@parser, :buffer            
    def_delegator :clear_buffer, :buffer, :clear
    def_delegator :clear_processed, :processed, :clear
    def_delegator :clear_rejected, :rejected, :clear
    def_delegator :clear_messages, :messages, :clear

    def initialize(options = {})
      @timestamps = options[:timestamps] || false
      @callbacks, @processed, @rejected, @messages = [], [], [], []
      @parser = Parser.new(options)    
    end
    
    def all_messages
      @messages | @fragmented_messages
    end
    
    def buffer_s
      buffer.join
    end
    alias_method :buffer_hex, :buffer_s

    def clear_buffer
      buffer.clear
    end

    def clear_messages
      @messages.clear
    end
    
    # Convert messages to hashes with timestamps
    def use_timestamps
      @messages = @messages.map do |message|
        { 
          :messages => message, 
          :timestamp => nil
        }
      end
      @timestamps = true
    end

    def parse(*args)
      args.compact!
      options = args.pop if args.last.kind_of?(Hash) 

      timestamp = options[:timestamp] if !options.nil? && !options[:timestamp].nil?
      use_timestamps if !timestamp.nil? && !@timestamps 

      queue = HexProcessor.process(args)
      result = @parser.process(queue)
      report_message(result[:messages], :timestamp => timestamp)
      @processed += result[:processed]
      @rejected += result[:rejected]
      get_parse_output(result[:messages], options)
    end    
    
    private
        
    def report_message(message, options = {})
      if @timestamps
        @messages << { 
          :messages => message, 
          :timestamp => options[:timestamp] 
        }     
      else
        @messages += message
      end
    end
    
    def get_parse_output(messages, options = nil)
      # return type
      # 0 messages: nil
      # 1 message: the message
      # >1 message: an array of messages
      # might make sense to make this an array no matter what...iii dunnoo
      output = messages.length < 2 ? (messages.empty? ? nil : messages[0]) : messages
      output = { :messages => output, :timestamp => options[:timestamp] } if @timestamps && !options.nil?
      output      
    end
    
  end
  
end
