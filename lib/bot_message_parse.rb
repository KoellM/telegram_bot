require "find"
Find.find('./lib/command') { |f| require f if !File.directory?(f) }

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
          fork do
            Hibiki.handle(bot, a)
          end
        end

        on /^\/command@jpEEWBot[ ]?(.+)?/ do |a|
          fork do
            Command.handle(bot, a)
          end
        end

        on /^\/reload@jpEEWBot[ ]?(.+)?/ do |a|
          begin
            load './lib/bot_message_parse.rb'
            Find.find('./lib/command') { |f| load f if !File.directory?(f) }
            BotMessageSender.new(bot).send_message("成功.\n版本: #{BotConfig.version}")
          rescue => e
            BotMessageSender.new(bot).send_message("失败!\n#{e.message}")
          end
        end

        on(/(https?):\/\/[-A-Za-z0-9+&@#\/%?=~_|!:,.;]+[-A-Za-z0-9+&@#\/%=~_|]/) do |a|
          Web.handle(bot, a)
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