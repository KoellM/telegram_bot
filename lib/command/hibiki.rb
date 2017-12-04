require 'json'
require 'mechanize'
require 'uri'
require 'shellwords'
class Hibiki
    def self.handle(bot, a)
        message = bot[:message]
        if a.nil?
            BotMessageSender.new(bot).send_message("使用方法:\n/hibiki [radio_name] [+download]")
            return
        end
        d = a.match(/(.*)[ ](.*)/)        
        begin
            radio_name = a
            radio_name = d[1] if !d.nil?
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
            additional_url = self.get_api("https://vcms-api.hibiki-radio.jp/api/v1/videos/play_check?video_id=#{additional_episode_id}")["playlist_url"] if !additional_episode_id.nil?
            if d.nil?
                BotMessageSender.new(bot).send_message("[Hibiki] 搜索:#{radio_name} 结果: \n#{infos["episode"]["program_name"]} #{infos["episode"]["name"]}(#{infos["episode"]["updated_at"]})\n\n#{infos["description"]}\n本体ID: #{episode_id}(#{url})#{unless (additional_episode_id.nil?) then "\n楽屋裏ID: #{additional_episode_id}(#{additional_url})" end }")
            elsif d[2].match?(/download|d|ダウンロード|下载/)
                # download
                BotMessageSender.new(bot).send_message("[Hibiki] 开始下载: #{radio_name}-#{infos["episode"]["program_name"]}-#{infos["episode"]["name"]}")
                save_path = "#{BotConfig.save_path}/#{radio_name}-#{infos["episode"]["program_name"]}-#{infos["episode"]["name"]}"
                if !additional_episode_id.nil?
                arg = "ffmpeg\
                -loglevel error \
                -y \
                -i #{Shellwords.escape(additional_url)} \
                -vcodec copy -acodec copy -bsf:a aac_adtstoasc\
                ./#{Shellwords.escape("#{save_path}-additional.mp4")
                begin
                    output = `#{arg}`
                    exit_status = $?
                    [exit_status, output]
                    BotMessageSender.new(bot).send_message("[Hibiki] #{radio_name} additional下载完成. #{output}(#{exit_status})")
                    BotMessageSender.new(bot).send_video("#{save_path}-additional.mp4", "video/mp4")
                rescue => e
                    exit_status, output = 0
                    p e
                end
            end
                arg = "ffmpeg\
                -loglevel error \
                -y \
                -i #{Shellwords.escape(url)} \
                -vcodec copy -acodec copy -bsf:a aac_adtstoasc\
                ./#{Shellwords.escape("#{save_path}.mp4")
                begin
                    output = `#{arg}`
                    exit_status = $?
                    [exit_status, output]
                    BotMessageSender.new(bot).send_message("[Hibiki] #{radio_name} 下载完成. #{output}(#{exit_status})")
                    BotMessageSender.new(bot).send_video("#{save_path}.mp4", "video/mp4")
                rescue => e
                    exit_status, output = 0, e.to_s
                end
            else
                # TODO
                # 尝试直接下载
            end
          rescue => e
            puts e.message
            puts e.backtrace.join("\n")
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