require 'yaml'

class BotConfig
    def self.version
        "0.1.0"
    end
    def token
        YAML::load(IO.read('config/config.yml'))['token']
    end
end