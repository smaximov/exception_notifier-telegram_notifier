# frozen_string_literal: true

module ExceptionNotifier
  class TelegramNotifier
    class Middleware
      # @api private
      class Reply
        METHOD = 'sendMessage'

        attr_reader :chat_id
        attr_reader :text

        def initialize(chat_id, text)
          @chat_id = chat_id
          @text = text

          body = JSON.dump(method: METHOD, chat_id: chat_id, text: text)

          @rack_reply = [200, Middleware::CONTENT_TYPE_HEADER, [body]]

          freeze
        end

        def to_rack_reply
          @rack_reply
        end
      end
    end
  end
end
