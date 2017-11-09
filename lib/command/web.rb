class Web
    def self.handle(bot, message, a)
        begin
            # url = message.text.match(/\/web@jpEEWBot (.*)/)[1]
            url = message.text.match(/(https?|ftp|file):\/\/[-A-Za-z0-9+&@#\/%?=~_|!:,.;]+[-A-Za-z0-9+&@#\/%=~_|]/)[0]
            url = message.text.match(/URL: (https?|ftp|file):\/\/[-A-Za-z0-9+&@#\/%?=~_|!:,.;]+[-A-Za-z0-9+&@#\/%=~_|]/)[0] unless message.text.match(/URL: (https?|ftp|file):\/\/[-A-Za-z0-9+&@#\/%?=~_|!:,.;]+[-A-Za-z0-9+&@#\/%=~_|]/).nil?
            puts url
            output = `google-chrome-unstable --headless --disable-gpu --screenshot --window-size=1280,1696 "#{url.match(/(https?|ftp|file):\/\/[-A-Za-z0-9+&@#\/%?=~_|!:,.;]+[-A-Za-z0-9+&@#\/%=~_|]/)[0]}"`
            exit_status = $?
            [exit_status, output]
            BotMessageSender.new(bot, './screenshot.png').send_photo('image/png')
        rescue => e
            # bot.api.send_message(chat_id: message.chat.id, text: "[Command] 返回结果: URL 似乎无法解析.")
        end
 end
end