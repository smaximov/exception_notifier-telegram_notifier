# frozen_string_literal: true

require 'exception_notifier/telegram_notifier'
require 'logger'

CHATS = Set.new
AUTHORIZATION_TOKEN = ENV.fetch('AUTHORIZATION_TOKEN')

ExceptionNotifier::TelegramNotifier.configure do |config|
  config.bot_token = ENV.fetch('BOT_TOKEN')
  config.webhook_url = ENV.fetch('WEBHOOK_URL')
  config.logger = Logger.new($stdout)

  config.authorize_proc = lambda do |message|
    AUTHORIZATION_TOKEN == message.strip
  end

  config.add_chat_proc = ->(chat_id) { CHATS << chat_id }
  config.remove_chat_proc = ->(chat_id) { CHATS.delete(chat_id) }
  config.fetch_chats_proc = -> { CHATS }
end
