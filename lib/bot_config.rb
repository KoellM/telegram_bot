require 'yaml'

class BotConfig
    def self.version
        version = YAML::load(IO.read('config/config.yml'))['version']
        commit_id = `git rev-parse --short HEAD`
        "#{version}-#{commit_id}"
    end

    def self.save_path
        YAML::load(IO.read('config/config.yml'))['save_path']
    end
    
    def token
        YAML::load(IO.read('config/config.yml'))['token']
    end

    def self.qiniu_app_access_key
        YAML::load(IO.read('config/config.yml'))['qiniu_app_access_key']
    end

    def self.qiniu_app_secret_key
        YAML::load(IO.read('config/config.yml'))['qiniu_app_secret_key']
    end

    def self.qiniu_app_bucket
        YAML::load(IO.read('config/config.yml'))['qiniu_app_bucket']
    end        
end