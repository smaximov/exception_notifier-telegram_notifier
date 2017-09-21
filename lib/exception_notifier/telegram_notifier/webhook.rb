# frozen_string_literal: true

require 'json'
require 'logger'
require 'uri'

begin
  require 'rack'
  require 'rack/media_type'
rescue LoadError
  warn "'rack' is required to use ExceptionNotifier::TelegramNotifier::Webhook"
  raise
end

module ExceptionNotifier
  class TelegramNotifier
    # Rack Middleware for the Telegram bot webhook.
    class Webhook
      require 'exception_notifier/telegram_notifier/webhook/command'
      require 'exception_notifier/telegram_notifier/webhook/message'
      require 'exception_notifier/telegram_notifier/webhook/reply'

      # @api private
      DEFAULT_LOGGER = Logger.new(nil)

      # @api private
      CONTENT_TYPE = 'application/json'

      # @api private
      HEADERS = { ::Rack::CONTENT_TYPE => CONTENT_TYPE }.freeze

      def initialize(app, webhook_url:, add_chat:, remove_chat:,
                     authorize: -> { true }, logger: DEFAULT_LOGGER)
        @app = app
        @webhook_url = URI(webhook_url)
        @add_chat = add_chat
        @remove_chat = remove_chat
        @authorize = authorize
        @logger = logger
      end

      def call(env)
        req = ::Rack::Request.new(env)

        return process(req) if webhook_request?(req)

        @app.call(env)
      end

      private

      # @api private
      def webhook_request?(req)
        req.post? && json?(req.content_type) && webhook_url?(req.host, req.path)
      end

      # @api private
      def json?(content_type)
        ::Rack::MediaType.type(content_type) == CONTENT_TYPE
      end

      # @api private
      def webhook_url?(host, path)
        @webhook_url.host == host && @webhook_url.path == path
      end

      # @api private
      def process(req)
        body = JSON.parse(req.body.read)
        message = Message.new(body['message'])

        dispatch(message)
      rescue StandardError => e
        @logger.error(<<~ERROR)
          TelegramNotifier: unexpected error: #{e.message}
          #{e.backtrace.join("\n")}
        ERROR

        @app.call(env)
      end

      # @api private
      def dispatch(message)
        command = case message.command
                  when Message::ADD then
                    Command::Add.new(message, @logger, @add_chat, @authorize)
                  when Message::REMOVE then
                    Command::Remove.new(message, @logger, @remove_chat)
                  else
                    Command::Usage.new(message)
                  end

        command.reply
      end
    end
  end
end
