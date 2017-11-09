class Version
    def self.handle(bot, message, a)
        BotMessageSender.new(bot, "EEW Telegram BOT(#{BotConfig.version})").send_message
    end
end