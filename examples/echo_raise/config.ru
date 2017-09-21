# frozen_string_literal: true

require 'exception_notification'
require 'exception_notifier/telegram_notifier'
require 'exception_notifier/telegram_notifier/webhook'
require 'logger'
require 'rack'
require 'rotp'
require 'rqrcode'
require 'set'

totp_secret = ENV.fetch('TOTP_SECRET') do
  puts 'TOTP_SECRET environment variable is unset, generating random secret...'

  ROTP::Base32.random_base32
end

totp = ROTP::TOTP.new(totp_secret, issuer: 'TelegramNotifier')
provisioning_uri = totp.provisioning_uri(ENV.fetch('USER', 'unknown'))
qrcode = RQRCode::QRCode.new(provisioning_uri)

puts "Provisioning URI: #{provisioning_uri}"
puts qrcode.as_ansi

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
    authorize: ->(msg) { totp.verify(msg.strip) },
    add_chat: ->(chat_id) { CHATS << chat_id },
    remove_chat: ->(chat_id) { CHATS.delete(chat_id) },
    logger: Logger.new($stdout)

use ExceptionNotification::Rack,
    telegram: {
      bot_token: ENV.fetch('BOT_TOKEN'),
      recipients: -> { CHATS }
    }

run EchoRaise.new
