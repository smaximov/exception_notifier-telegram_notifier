# frozen_string_literal: true

module ExceptionNotifier
  class TelegramNotifier
    # Default notificatation message formatter.
    class Formatter
      # Format notification message.
      #
      # @param exception [Exception] captured exception.
      # @param data [Hash] additional data.
      #
      # @note Telegram will reject messages that exceed maximum length
      #   (currently, 4096 UTF-8 characters).
      def call(exception, _data)
        <<~MESSAGE
          Exception: #{exception.message}

          Backtrace:

          #{exception.backtrace[0..10].join("\n")}
        MESSAGE
      end
    end
  end
end
