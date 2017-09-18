# frozen_string_literal: true

require 'exception_notification'
require_relative 'echo_raise'

use ExceptionNotifier::TelegramNotifier::Webhook
use ExceptionNotification::Rack, telegram: {}
run EchoRaise.new
