require 'yaml'

class BotConfig
    def self.version
        version = YAML::load(IO.read('config/config.yml'))['version']
        commit_id = `git rev-parse --short HEAD`
        "#{version}-#{commit_id}"
    end

    def self.save_path
        YAML::load(IO.read('config/config.yml'))['save_token']
    end
    def token
        YAML::load(IO.read('config/config.yml'))['token']
    end
end