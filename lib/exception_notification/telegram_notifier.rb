# frozen_string_literal: true

module ExceptionNotification
  # Telegram notifier for the exception_notification gem.
  module TelegramNotifier
    require 'exception_notification/telegram_notifier/configuration'
    require 'exception_notification/telegram_notifier/version'

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
    end
  end
end
