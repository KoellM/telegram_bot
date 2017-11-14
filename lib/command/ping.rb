class Ping
    def self.handle(bot, a)
        BotMessageSender.new(bot).send_message('Pong')
    end
end