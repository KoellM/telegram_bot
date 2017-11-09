class BotMessageSender
    attr_reader :bot
    attr_reader :media
    attr_reader :message
    def initialize(bot, media)
        @bot = bot[:bot]
        @message = bot[:message]
        @media = media
    end

    def send_message
        bot.api.send_message(chat_id: message.chat.id, text: media)
    end

    def send_photo(type)
        bot.api.send_photo(chat_id: message.chat.id, photo: Faraday::UploadIO.new(media, type))          
    end
end