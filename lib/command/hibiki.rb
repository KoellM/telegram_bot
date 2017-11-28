class Hibiki
    def self.handle(bot, a)
        message = bot[:message]
        if a.nil?
            BotMessageSender.new(bot).send_message("使用方法:\n/hibiki [radio_name]")
            return
        end
        begin
            radio_name = a
            res = get_api("https://vcms-api.hibiki-radio.jp/api/v1/programs/#{radio_name}")
            infos = JSON.parse(res.body)
            episode_id = infos["episode"]["video"]["id"]
          rescue => e
            puts e
          end
          begin
            additional_episode_id = infos["episode"]["additional_video"]["id"]
          rescue
            additional_episode_id = nil
          end
          begin
            bot.api.send_message(chat_id: message.chat.id, text: "[Hibiki] 搜索关键词:#{radio_name} 结果: \n #{infos["episode"]["program_name"]} #{infos["episode"]["name"]}(#{infos["episode"]["updated_at"]})\n#{infos["description"]}\n本体ID: #{episode_id}, #{unless (additional_episode_id.nil?) then "楽屋裏ID: #{additional_episode_id}" end }")
          rescue
          end
    end
end