# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

module ExceptionNotifier
  # Telegram notifier for the exception_notification gem.
  class TelegramNotifier
    require 'exception_notifier/telegram_notifier/configuration'
    require 'exception_notifier/telegram_notifier/version'
    require 'exception_notifier/telegram_notifier/webhook'

    class << self
      # Configure Telegram notifier.
      #
      # @yieldparam config [Configuration] Telegram notifier config.
      #
      # @return [void]
      #
      # @example (see Configuration)
      def configure
        yield config
      end

      # @return [Configuration] Telegram notifier config.
      def config
        @config ||= Configuration.new(Configuration::DEFAULT_CONFIG)
      end

      # (see Configuration#bot_token)
      #
      # @raise [RuntimeError] if bot token is unset.
      def bot_token
        config.bot_token or raise 'Telegram bot token is unset!'
      end

      # (see Configuration#webhook_url)
      #
      # @raise [RuntimeError] if bot webhook URL is unset.
      def webhook_url
        config.webhook_url
      end

      # (see Configuration#logger)
      def logger
        config.logger
      end

      # Set webhook URL for the bot.
      def set_webhook
        uri = request_uri('setWebhook')
        Net::HTTP.post_form(uri, url: webhook_url, allowed_updates: %w[message])
      end

      def request_uri(method)
        URI("https://api.telegram.org/bot#{bot_token}/#{method}")
      end
    end

    def initialize(_options); end

    def call(exception, _options = {})
      message = format_message(exception)

      uri = self.class.request_uri('sendMessage')

      self.class.config.fetch_chats_proc.call.each do |chat_id|
        send_message(uri, chat_id, message)
      end
    end

    private

    def send_message(uri, chat_id, message)
      data = JSON.dump(chat_id: chat_id, text: message, parse_mode: 'Markdown')

      Net::HTTP.post(uri, data, Webhook::HEADERS).tap do |res|
        logger.error("TelegramNotifier: request failed: #{res.body}") if
          res.code != 200
      end
    end

    def format_message(exception)
      <<~MESSAGE
        Exception: #{exception.message}

        Backtrace:

        ```
        #{exception.backtrace[0..10].join("\n")}
        ```
      MESSAGE
    end
  end
end
