# frozen_string_literal: true

require 'json'
require 'rack'
require 'rack/media_type'
require 'uri'

module ExceptionNotifier
  class TelegramNotifier
    # Rack Middleware for the Telegram bot webhook.
    class Webhook
      CONTENT_TYPE = 'application/json'

      HEADERS = { ::Rack::CONTENT_TYPE => CONTENT_TYPE }.freeze

      require 'exception_notifier/telegram_notifier/webhook/command'
      require 'exception_notifier/telegram_notifier/webhook/message'
      require 'exception_notifier/telegram_notifier/webhook/reply'

      def initialize(app)
        @app = app
      end

      def call(env)
        req = ::Rack::Request.new(env)

        return process(req) if webhook_request?(req)

        @app.call(env)
      rescue StandardError => e
        TelegramNotifier.logger.error("#{self.class.name}: unexpected error:")
        TelegramNotifier.logger.error(e.message)
        TelegramNotifier.logger.error(e.backtrace.join("\n"))
        @app.call(env)
      end

      private

      def webhook_request?(req)
        req.post? && json?(req.content_type) && webhook_url?(req.host, req.path)
      end

      def json?(content_type)
        ::Rack::MediaType.type(content_type) == CONTENT_TYPE
      end

      def webhook_url?(host, path)
        webhook_url = TelegramNotifier.webhook_url or
          begin
            TelegramNotifier.logger.warn('Telegram bot webhook URL is unset!')
            return false
          end

        webhook_url = URI(webhook_url)
        webhook_url.host == host && webhook_url.path == path
      end

      def process(req)
        body = JSON.parse(req.body.read)
        message = Message.new(body['message'])

        dispatch(message)
      end

      def dispatch(message)
        command_class = case message.command
                        when Message::ADD then Command::Add
                        when Message::REMOVE then Command::Remove
                        else Command::Usage
                        end

        command_class.new(message).reply
      end
    end
  end
end
