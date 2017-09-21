# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

require 'exception_notifier/telegram_notifier/util'

module ExceptionNotifier
  class TelegramNotifier
    # Telegram Bot API client.
    class Client
      # @api private
      BASE_URI = 'https://api.telegram.org/bot'

      # @api private
      METHODS = %w[
        send_message set_webhook
      ].freeze

      # @api private
      HEADERS = { 'Content-Type' => 'application/json' }.freeze

      # @return [String] Bot token.
      attr_reader :bot_token

      # @param bot_token [String] Bot token.
      def initialize(bot_token)
        @bot_token = bot_token
      end

      METHODS.each do |method|
        request_method = Util.camelize(method, lower: true)

        define_method(method) do |data|
          request(request_method, data)
        end
      end

      private

      # @param method [String] Telegram API method.
      #
      # @return [Net::HTTPResponse]
      #
      # @api private
      def request(method, data)
        request_uri = URI("#{BASE_URI}#{bot_token}/#{method}")
        request_data = JSON.dump(data)

        Net::HTTP.post(request_uri, request_data, HEADERS)
      end
    end
  end
end
