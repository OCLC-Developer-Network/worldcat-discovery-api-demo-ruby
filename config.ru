require "yaml"
require "sinatra"
require "haml"
require "oclc/auth"
require "worldcat/discovery"

require "./discover"
require "./helpers/application_helper"

set :environment, :development
set :run, true
set :raise_errors, true

config = YAML::load(File.read("#{File.expand_path(File.dirname(__FILE__))}/config/discovery_api.yml"))
key = config[settings.environment.to_s]['key']
secret = config[settings.environment.to_s]['secret']
wskey = OCLC::Auth::WSKey.new(key, secret)
WorldCat::Discovery.configure(wskey)

app_home = File.expand_path(File.dirname(__FILE__))
BCP_47_LANGUAGES = YAML::load(File.read("#{app_home}/config/languages.yml"))
MARC_LANGUAGES = YAML::load(File.read("#{app_home}/config/marc_languages.yml"))
FORMATS = YAML::load(File.read("#{app_home}/config/formats.yml"))

run Sinatra::Application