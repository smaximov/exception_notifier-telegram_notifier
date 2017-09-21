# frozen_string_literal: true

module ExceptionNotifier
  # Telegram notifier for the exception_notification gem.
  class TelegramNotifier
    require 'exception_notifier/telegram_notifier/client'
    require 'exception_notifier/telegram_notifier/formatter'
    require 'exception_notifier/telegram_notifier/version'

    # @return [#call] Default message formatter.
    #
    # @api private
    DEFAULT_FORMATTER = Formatter.new.freeze

    # @param bot_token [String] Bot token.
    # @param recipients [Enumerable, #call]
    #   Enumerable (or a proc that returns an enumerable)
    #   that yields persisted chat IDs.
    # @param formatter [#call]
    #   Notification message formatter.
    def initialize(bot_token:, recipients:, formatter: DEFAULT_FORMATTER)
      @client = Client.new(bot_token)
      @recipients = recipients
      @formatter = formatter

      freeze
    end

    def call(exception, data = {})
      message = @formatter.call(exception, data)

      each_recipient do |chat_id|
        @client.send_message(chat_id: chat_id, text: message)
      end
    end

    private

    # @yieldparam chat_id [Integer] Chat ID of the recipient.
    # @yieldreturn [void]
    #
    # @api private
    def each_recipient(&block)
      recipients = if @recipients.respond_to?(:call)
                     @recipients.call
                   else
                     @recipients
                   end

      recipients.each(&block)
    end
  end
end
