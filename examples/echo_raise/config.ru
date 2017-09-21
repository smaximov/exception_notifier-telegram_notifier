# frozen_string_literal: true

require 'exception_notification'
require 'exception_notifier/telegram_notifier'
require 'exception_notifier/telegram_notifier/webhook'
require 'logger'
require 'rack'
require 'set'

class EchoRaise
  def call(env)
    request = Rack::Request.new(env)

    headers = {
      'Content-Type' => 'text/plain; charset=utf-8'
    }

    raise request.path if request.path.start_with?('/raise')

    [200, headers, [request.path]]
  end
end

CHATS = Set.new

AUTH_TOKEN = ENV.fetch('AUTHORIZATION_TOKEN')

use ExceptionNotifier::TelegramNotifier::Webhook,
    webhook_url: ENV.fetch('WEBHOOK_URL'),
    authorize: ->(msg) { AUTH_TOKEN == msg.strip },
    add_chat: ->(chat_id) { CHATS << chat_id },
    remove_chat: ->(chat_id) { CHATS.delete(chat_id) },
    logger: Logger.new($stdout)

use ExceptionNotification::Rack,
    telegram: {
      bot_token: ENV.fetch('BOT_TOKEN'),
      recipients: -> { CHATS }
    }

run EchoRaise.new
