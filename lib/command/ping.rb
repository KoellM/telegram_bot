class Ping
    def self.handle(bot, a)
        BotMessageSender.new(bot, 'Pong').send_message
    end
end