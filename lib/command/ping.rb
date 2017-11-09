class Ping
    def self.handle(bot, message, a)
        BotMessageSender.new(bot, 'Pong').send_message
    end
end