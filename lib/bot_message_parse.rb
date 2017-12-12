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

        on /开服/ do
          fork do
            require 'faraday'
            begin
              response = Faraday.get('https://krr-prd.star-api.com/api/app/version/get?platform=1&version=1.0.2')
              json = JSON.parse(response.body)
              result_code = json["resultCode"]
              message = json["message"]
              version = json["serverVersion"]
              end_at = json["endAt"]
              time = Time.parse(end_at + " +09:00")
              time.localtime("+08:00")
              str = "服务器状态:#{result_code} 版本: #{version} 预计结束时间:#{time}#{message}"
              BotMessageSender.new(bot).send_message(str)
            rescue => e
              BotMessageSender.new(bot).send_message("查询失败: #{e.message}")
            end
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