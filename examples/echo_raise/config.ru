# frozen_string_literal: true

require 'exception_notification'
require_relative 'echo_raise'

use ExceptionNotifier::TelegramNotifier::Middleware
use ExceptionNotification::Rack, telegram: {}
run EchoRaise.new
