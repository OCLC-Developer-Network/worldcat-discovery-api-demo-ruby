CONFIG = YAML::load(File.read("#{File.expand_path(File.dirname(__FILE__))}/discovery_api.yml"))

def create_key
  key = CONFIG[settings.environment.to_s]['key']
  secret = CONFIG[settings.environment.to_s]['secret']
  OCLC::Auth::WSKey.new(key, secret)
end