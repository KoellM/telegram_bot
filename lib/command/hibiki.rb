require 'json'
require 'mechanize'
require 'uri'
require 'shellwords'
require 'qiniu'
class Hibiki
    def self.handle(bot, a)
        message = bot[:message]
        if a.nil?
            BotMessageSender.new(bot).send_message("使用方法:\n/hibiki [radio_name] [+download]")
            return
        end
        d = a.match(/(.*)[ ](.*)/)
        begin
            # 尝试获取节目
            radio_name = a
            radio_name = d[1] if !d.nil?
            infos = self.get_api("https://vcms-api.hibiki-radio.jp/api/v1/programs/#{radio_name}")
            episode_id = infos["episode"]["video"]["id"]
          rescue => e
            puts e.message
          end
          additional_episode_id = infos["episode"]["additional_video"]["id"]
          
          begin
            url = self.get_api("https://vcms-api.hibiki-radio.jp/api/v1/videos/play_check?video_id=#{episode_id}")["playlist_url"]
            additional_url = self.get_api("https://vcms-api.hibiki-radio.jp/api/v1/videos/play_check?video_id=#{additional_episode_id}")["playlist_url"] if !additional_episode_id.nil?
            if d.nil?
                # 查询
                BotMessageSender.new(bot).send_message("[Hibiki] 搜索:#{radio_name} 结果: \n#{infos["episode"]["program_name"]} #{infos["episode"]["name"]}(#{infos["episode"]["updated_at"]})\n\n#{infos["description"]}\n本体ID: #{episode_id}(#{url})#{unless (additional_episode_id.nil?) then "\n楽屋裏ID: #{additional_episode_id}(#{additional_url})" end }")
            elsif d[2].match?(/download|d|ダウンロード|下载/)
                # download
                BotMessageSender.new(bot).send_message("[Hibiki] 开始下载: #{radio_name}-#{infos["episode"]["program_name"]}-#{infos["episode"]["name"]}")
                # 保存目录
                save_name = "#{radio_name}-#{infos["episode"]["program_name"]}-#{infos["episode"]["name"]}"
                save_path = "#{BotConfig.save_path}/#{save_name}"
                if !additional_episode_id.nil?
                    # additional下载
                    if(File.file?("#{save_path}-additional.mp4"))
                        qiniu = self.upload_qiniu(path, "#{save_name}-additional.mp4")
                        p qiniu
                    else                   
                        exit_status, output = self.download(additional_episode_id, save_path)
                        self.upload_qiniu(path, "#{save_name}-additional.mp4") if exit_status == 0
                    end
                end
                if (File.file?("#{save_path}.mp4"))
                    self.upload_qiniu(path, "#{save_name}.mp4")
                else
                    exit_status, output = self.download(url, save_path)
                    self.upload_qiniu(path, "#{save_name}.mp4") if exit_status == 0
                end
            else
                # TODO: ID下载
            end
          rescue => e
            puts e.message
            puts e.backtrace.join("\n")
          end
    end

    def self.download(url, save_path)
        arg = "ffmpeg\
        -loglevel error \
        -y \
        -i #{Shellwords.escape(url)} \
        -vcodec copy -acodec copy -bsf:a aac_adtstoasc\
        #{Shellwords.escape("#{save_path}.mp4")}"
        output = `#{arg}`
        exit_status = $?
        return exit_status, output
    end

    def self.upload_qiniu(path, filename)
        # 七牛初始化
        Qiniu.establish_connection!(access_key: Config.qiniu_app_access_key>,
        secret_key: Config.qiniu_app_secret_key>,
        :block_size      => 1024*1024*4,
        :chunk_size      => 1024*1024*4)
        # bucket name
        bucket = Config.qiniu_app_bucket

        filename = filename
        put_policy = Qiniu::Auth::PutPolicy.new(
            bucket, # 存储空间
            filename,    # 指定上传的资源名，如果传入 nil，就表示不指定资源名，将使用默认的资源名
            3600    # token 过期时间，默认为 3600 秒，即 1 小时
        )
        uptoken = Qiniu::Auth.generate_uptoken(put_policy)
        code, result, response_headers = Qiniu::Storage.upload_with_token_2(
            uptoken,
            path,
            filename,
            nil, # 可以接受一个 Hash 作为自定义变量，请参照 http://developer.qiniu.com/article/kodo/kodo-developer/up/vars.html#xvar
            bucket: bucket
       )
       return code, result, response_headers        
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