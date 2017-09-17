# frozen_string_literal: true

require 'logger'

module ExceptionNotifier
  class TelegramNotifier
    # Telegram notifier configuration.
    #
    # @example
    #   ExceptionNotifier::TelegramNotifier.configure do |config|
    #     config.bot_token = ENV.fetch('MY_BOT_TOKEN')
    #     config.webhook_url = 'https://example.com/webhook'
    #     config.logger = Logger.new($stdout)
    #
    #     config.authorize_proc = ->(message) do
    #       message.strip == ENV['TELEGRAM_NOTIFIER_SECRET_TOKEN']
    #     end
    #
    #     config.add_chat_proc = ->(chat_id) do
    #       TelegramChat.create(chat_id: chat_id)
    #     end
    #
    #     config.remove_chat_proc = ->(chat_id) do
    #       TelegramChat.find_by(chat_id: chat_id)&.destroy
    #     end
    #
    #     config.fetch_chats_proc = -> do
    #       TelegramChat.all.pluck(:chat_id)
    #     end
    #   end
    class Configuration
      DEFAULT_LOGGER = Logger.new(nil)

      DEFAULT_AUTHORIZE_PROC = ->(_) { true }

      DEFAULT_ADD_CHAT_PROC = lambda do |_|
        raise <<~ERROR_MESSAGE
          You must set `add_chat_proc` configuration option for
          ExceptionNotifier::TelegramNotifier! For example:

            ExceptionNotifier::TelegramNotifier.configure do |config|
              config.add_chat_proc = ->(chat_id) do
                # Code to persist `chat_id`.
              end
            end
        ERROR_MESSAGE
      end

      DEFAULT_REMOVE_CHAT_PROC = lambda do |_|
        raise <<~ERROR_MESSAGE
          You must set `remove_chat_proc` configuration option for
          ExceptionNotifier::TelegramNotifier! For example:

            ExceptionNotifier::TelegramNotifier.configure do |config|
              config.remove_chat_proc = ->(chat_id) do
                # Code to remove persisted `chat_id`
              end
            end
        ERROR_MESSAGE
      end

      DEFAULT_FETCH_CHATS_PROC = lambda do
        raise <<~ERROR_MESSAGE
          You must set `fetch_chats_proc` configuration option for
          ExceptionNotifier::TelegramNotifier! For example:

            ExceptionNotifier::TelegramNotifier.configure do |config|
              config.fetch_chats_proc = ->(chat_id) do
                # Code to fetch all persisted chat IDs.
              end
            end
        ERROR_MESSAGE
      end

      DEFAULT_CONFIG = {
        bot_token: nil,
        webhook_url: nil,
        logger: DEFAULT_LOGGER,
        authorize_proc: DEFAULT_AUTHORIZE_PROC,
        add_chat_proc: DEFAULT_ADD_CHAT_PROC,
        remove_chat_proc: DEFAULT_REMOVE_CHAT_PROC,
        fetch_chats_proc: DEFAULT_FETCH_CHATS_PROC
      }.freeze

      def initialize(options)
        options.each do |key, value|
          public_send("#{key}=", value)
        end
      end

      # @return [String] Telegram bot token.
      attr_accessor :bot_token

      # @return [String] Bot webhook URL.
      attr_accessor :webhook_url

      # @return [Logger] Logger instance.
      attr_accessor :logger

      # Optional authorization proc that returns true if webhook request
      # from a chat is authorized. If not set, consider all requests
      # authorized.
      #
      # @return [Proc]
      attr_accessor :authorize_proc

      # Proc that persists chat ID of the sender when the `/start` message is
      # sent to the bot.
      #
      # @return [Proc]
      attr_accessor :add_chat_proc

      # Proc that deletes chat ID of the sender when the `/stop` message is sent
      # to the bot.
      #
      # @return [Proc]
      attr_accessor :remove_chat_proc

      # Proc that fetches all persisted chat IDs.
      #
      # @return [Proc]
      attr_accessor :fetch_chats_proc
    end
  end
end
