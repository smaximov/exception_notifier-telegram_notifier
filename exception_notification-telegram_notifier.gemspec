# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'exception_notification/telegram_notifier/version'

Gem::Specification.new do |spec|
  spec.name          = 'exception_notification-telegram_notifier'
  spec.version       = ExceptionNotification::TelegramNotifier::VERSION
  spec.authors       = ['Sergei Maximov']
  spec.email         = ['s.b.maximov@gmail.com']

  spec.summary       = 'Telegram notifier for the exception_notification gem'
  spec.homepage      = 'https://github.com/smaximov/exception_notification-telegram_notifier'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.50.0'
  spec.add_development_dependency 'yard', '~> 0.9.9'
end
