#!/usr/bin/env ruby
# Telegram BOT
require 'telegram/bot'

require './lib/bot_config'
require './lib/bot_logger'
require './lib/bot_message'
require './lib/bot_message_parse'

config = BotConfig.new
logger = BotLogger.logger

logger.info("EEW Telegram BOT. Version: #{BotConfig.version}")
loop do
  begin
    Telegram::Bot::Client.run(config.token) do |bot|
      bot.listen do |message|
        logger.info "[#{message.from.username}]: #{message.text}" 
        BotMessageParse.new({bot: bot, message: message})
      end
    end
  rescue Telegram::Bot::Exceptions::ResponseError
    logger.error("ResponseError")
  end
  puts "60秒后再连."
  sleep 60
end
