# frozen_string_literal: true

module ExceptionNotifier
  class TelegramNotifier
    class Webhook
      # @api private
      class Message
        ADD = 'add'
        REMOVE = 'remove'
        COMMAND_SPLIT_REGEXP = %r{\A\s*(?:/(?<command>\w+))(?<params>.*)\z}

        attr_reader :chat_id
        attr_reader :text
        attr_reader :command
        attr_reader :params

        def initialize(data)
          @chat_id = data.dig('chat', 'id')
          @text = data['text']

          if (match = COMMAND_SPLIT_REGEXP.match(@text))
            @command = match[:command]
            @params = match[:params]&.strip
          end

          freeze
        end
      end
    end
  end
end
