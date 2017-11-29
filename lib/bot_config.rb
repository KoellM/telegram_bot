require 'yaml'

class BotConfig
    def self.version
        "0.1.0"
    end

    def self.save_path
        YAML::load(IO.read('config/config.yml'))['save_token']
    end
    def token
        YAML::load(IO.read('config/config.yml'))['token']
    end
end