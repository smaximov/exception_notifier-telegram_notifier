# frozen_string_literal: true

module ExceptionNotifier
  class TelegramNotifier
    class Webhook
      # @api private
      module Command
        # @api private
        class Base
          attr_reader :message

          def initialize(message)
            @message = message

            freeze
          end

          def reply
            call.to_rack_reply
          end
        end

        # @api private
        class Add < Base
          def initialize(msg, logger, add_chat, authorize)
            @authorized = authorize.call(msg.params)
            @logger = logger
            @add_chat = add_chat

            super(msg)
          end

          protected

          def call
            chat_id = message.chat_id

            return unauthorized(chat_id) unless authorized?

            add_chat(chat_id)
          end

          private

          def authorized?
            @authorized
          end

          def unauthorized(chat_id)
            @logger.warn(<<~LOG_MSG)
              TelegramNotifier: /add #{chat_id}: unauthorized.
            LOG_MSG

            Reply.new(chat_id, 'Unauthorized.')
          end

          def add_chat(chat_id)
            @logger.debug(<<~LOG_MSG)
              TelegramNotifier: /add #{message.chat_id}: authorized.
            LOG_MSG

            @add_chat.call(chat_id)

            Reply.new(message.chat_id, 'Added.')
          end
        end

        # @api private
        class Remove < Base
          def initialize(msg, logger, remove_chat)
            @logger = logger
            @remove_chat = remove_chat

            super(msg)
          end

          def call
            chat_id = message.chat_id

            @logger.debug(<<~LOG_MSG)
              TelegramNotifier: /remove #{chat_id}.
            LOG_MSG

            @remove_chat.call(chat_id)

            Reply.new(chat_id, 'Removed.')
          end
        end

        # @api private
        class Usage < Base
          def call
            Reply.new(message.chat_id, <<~USAGE)
              ExceptionNotifier Telegram Bot.

              Usage:
                /<command> [PARAMS...]

              Commands:
                /add [AUTH_PARAMS]
                  - add current chat to recipients.

                /remove
                  - remove current chat from recipients.
            USAGE
          end
        end
      end
    end
  end
end
