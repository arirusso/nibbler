# frozen_string_literal: true

module Nibbler
  # Parse string bytes
  module StringConversion
    module_function

    def convert_strings_to_numeric_bytes(*strings)
      string_bytes = strings.map { |string| string.scan(/../) }.flatten
      string_bytes.map(&:hex)
    end
  end
end
