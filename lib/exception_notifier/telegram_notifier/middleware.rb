# frozen_string_literal: true

require 'json'
require 'rack'
require 'rack/media_type'
require 'uri'

module ExceptionNotifier
  class TelegramNotifier
    # Rack Middleware for Telegram bot webhook.
    class Middleware
      CONTENT_TYPE = 'application/json'

      CONTENT_TYPE_HEADER = { ::Rack::CONTENT_TYPE => CONTENT_TYPE }.freeze

      require 'exception_notifier/telegram_notifier/middleware/command'
      require 'exception_notifier/telegram_notifier/middleware/message'
      require 'exception_notifier/telegram_notifier/middleware/reply'

      def initialize(app)
        @app = app
      end

      def call(env)
        req = ::Rack::Request.new(env)

        return process(req) if webhook_request?(req)

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
        webhook_url = URI(TelegramNotifier.webhook_url)
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
