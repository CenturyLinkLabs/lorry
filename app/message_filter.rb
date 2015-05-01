module Lorry
  class MessageFilter

    KEY_UNDEFINED_MATCHER = /^key (.*) is undefined.$/

    def self.filter(message)
      if matches = KEY_UNDEFINED_MATCHER.match(message)
        "Invalid key: #{matches[1]}"
      else
        message
      end
    end

  end
end
