require './lib/command/ping'
require './lib/command/version'
require './lib/command/web'
require './lib/command/command'

class BotMessageParse
    attr_reader :bot
    attr_reader :message
    
    def initialize(bot)
        @bot = bot
        @message = bot[:message]
        self.parse
    end

    def parse
        on /^\/ping@jpEEWBot[ ]?(.+)?/ do |a|
          Ping.handle(bot, a)
        end

        on /^\/version@jpEEWBot[ ]?(.+)?/ do |a|
          Version.handle(bot, a)
        end

        on /^\/hibiki@jpEEWBot[ ]?(.+)?/ do |a|
          Ping.handle(bot, a)
        end

        on /^\/command@jpEEWBot[ ]?(.+)?/ do |a|
          Command.handle(bot, a)
        end

        on(/(https?):\/\/[-A-Za-z0-9+&@#\/%?=~_|!:,.;]+[-A-Za-z0-9+&@#\/%=~_|]/) do |a|
          Web.handle(bot, message, a)
        end
    end

    private
    def on regex, &block
        regex =~ message.text
    
        if $~
          case block.arity
          when 0
            yield
          when 1
            yield $1
          when 2
            yield $1, $2
          end
        end
      end

      def send_message(text)
        puts text
      end
end