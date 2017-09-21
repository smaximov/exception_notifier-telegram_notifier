# frozen_string_literal: true

module ExceptionNotifier
  class TelegramNotifier
    # Utility functions.
    module Util
      # @api private
      WORD_SEPARATOR = '_'

      module_function

      # @param name [String]
      # @param lower [Boolean]
      #
      # @return [String]
      def camelize(name, lower: false)
        words = name.split(WORD_SEPARATOR)
        start = lower ? 1 : 0
        words[start..-1].map!(&:capitalize!)
        words.join
      end
    end
  end
end
