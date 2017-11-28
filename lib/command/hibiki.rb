require 'json'
require 'mechanize'
class Hibiki
    def self.handle(bot, a)
        message = bot[:message]
        if a.nil?
            BotMessageSender.new(bot).send_message("使用方法:\n/hibiki [radio_name]")
            return
        end
        begin
            radio_name = a
            infos = self.get_api("https://vcms-api.hibiki-radio.jp/api/v1/programs/#{radio_name}")
            episode_id = infos["episode"]["video"]["id"]
          rescue => e
            puts e.message
          end
          begin
            additional_episode_id = infos["episode"]["additional_video"]["id"]
          rescue
            additional_episode_id = nil
          end
          begin
            url = self.get_api("https://vcms-api.hibiki-radio.jp/api/v1/videos/play_check?video_id=#{episode_id}")["playlist_url"]
            additional_url = self.get_api("https://vcms-api.hibiki-radio.jp/api/v1/videos/play_check?video_id=#{additional_episode_id}")["playlist_url"]
            BotMessageSender.new(bot).send_message("[Hibiki] 搜索:#{radio_name} 结果: \n #{infos["episode"]["program_name"]} #{infos["episode"]["name"]}(#{infos["episode"]["updated_at"]})\n#{infos["description"]}\n本体ID: #{episode_id}(#{url}), #{unless (additional_episode_id.nil?) then "楽屋裏ID: #{additional_episode_id}(#{additional_url})" end }")
          rescue => e
            puts e.message
          end
    end

    def self.get_api(url)
        @a = Mechanize.new
        @a.user_agent_alias = 'Windows Chrome'
        res = @a.get(
            url,
            [],
            "http://hibiki-radio.jp/",
            'X-Requested-With' => 'XMLHttpRequest',
            'Origin' => 'http://hibiki-radio.jp'
        )
        return JSON.parse(res.body)
    end
end