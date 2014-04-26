require "rubygems"
require "yaml"
require "bundler/setup"
require "sinatra"
require "haml"
require "rdf/rdfxml"
require "json/ld"
require "equivalent-xml"
require "oclc/auth"
require "./discover"
require "./config/configure"
require "./helpers/application_helper"
require "./models/resource"
require "./models/bib"
require "./models/result_set"
require "./models/offer"

set :environment, :production
set :run, true
set :raise_errors, true

ENV['base_url'] = CONFIG[settings.environment.to_s]['base_url']
API_KEY = create_key
app_home = File.expand_path(File.dirname(__FILE__))
LANGUAGES = YAML::load(File.read("#{app_home}/config/languages.yml"))
FORMATS = YAML::load(File.read("#{app_home}/config/formats.yml"))

run Sinatra::Application