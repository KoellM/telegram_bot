require 'logger'
class BotLogger
    def self.logger
        Logger.new(STDOUT, Logger::DEBUG)
    end
end