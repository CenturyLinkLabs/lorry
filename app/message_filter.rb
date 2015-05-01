module Lorry
  class MessageFilter

    KEY_UNDEFINED_MATCHER = /^key (.*) is undefined.$/

    def self.filter(message)
      return if message.nil?

      if matches = KEY_UNDEFINED_MATCHER.match(message)
        @filtered_message = "Invalid key: #{matches[1]}"
      end

      @filtered_message || message
    end

  end
end
