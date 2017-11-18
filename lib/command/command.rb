class Command
    def self.handle(bot, a)
        message = bot[:message]
        if a.nil?
            BotMessageSender.new(bot).send_message("使用方法:\n/command []")
            return
        end
        if message.from.username == 'koell'
            BotMessageSender.new(bot).send_message（"[Command] 已执行.")
            begin
              output = `#{message.text.match(/\/command@jpEEWBot (.*)/)[1]}`
              exit_status = $?
              [exit_status, output]
            rescue => e
              exit_status, output = 0, e.to_s
            end
            BotMessageSender.new(bot).send_message("[Command] 返回结果: #{output}(#{exit_status}).")
          else
            # bot.api.send_message(chat_id: message.chat.id, text: "[Command] 無理.")
          end
    end
end