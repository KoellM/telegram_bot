class BotMessageSender
    attr_reader :bot
    attr_reader :message
    def initialize(bot)
        @bot = bot[:bot]
        @message = bot[:message]
    end

    def send_message(text)
        bot.api.send_message(chat_id: message.chat.id, text: text)
    end

    def send_photo(filename, type)
        bot.api.send_photo(chat_id: message.chat.id, photo: Faraday::UploadIO.new(filename, type))
    end
end