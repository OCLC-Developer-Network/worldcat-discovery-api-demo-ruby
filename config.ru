require "yaml"
require "sinatra"
require "haml"
require "oclc/auth"
require "worldcat/discovery"
require "rdf/turtle"

require "./discover"
require "./helpers/application_helper"

set :environment, :production
set :run, true
set :raise_errors, true

config = YAML::load(File.read("#{File.expand_path(File.dirname(__FILE__))}/config/discovery_api.yml"))
key = config[settings.environment.to_s]['key']
secret = config[settings.environment.to_s]['secret']
authenticating_institution_id = config[settings.environment.to_s]['authenticating_institution_id']
context_institution_id = config[settings.environment.to_s]['context_institution_id']
wskey = OCLC::Auth::WSKey.new(key, secret, :services => ['WorldCatDiscoveryAPI'])
WorldCat::Discovery.configure(wskey, authenticating_institution_id, context_institution_id)

app_home = File.expand_path(File.dirname(__FILE__))
BCP_47_LANGUAGES = YAML::load(File.read("#{app_home}/config/languages.yml"))
MARC_LANGUAGES = YAML::load(File.read("#{app_home}/config/marc_languages.yml"))
FORMATS = YAML::load(File.read("#{app_home}/config/formats.yml"))

run Sinatra::Application