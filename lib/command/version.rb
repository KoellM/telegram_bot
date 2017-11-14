class Version
    def self.handle(bot, a)
        BotMessageSender.new(bot).send_message("EEW Telegram BOT(#{BotConfig.version})")
    end
end