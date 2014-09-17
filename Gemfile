# Gemfile
source 'https://rubygems.org'
 
gem "sinatra", "1.4.1"
gem "sinatra-partial", "0.4.0"
gem "haml", "4.0.5"
gem "activesupport", "4.1.1"
gem "rdf-turtle", "1.1.2"
gem "nokogiri", "1.6.2.1"
gem "oclc-auth", '0.1.1', :path => "vendor/gems/oclc-auth-0.1.1"
gem "worldcat-discovery", '0.6.0', :path => "vendor/gems/worldcat-discovery-0.6.0"

group :development, :test do
  # gem 'rspec', '2.13.0'

  # guard gems
  # gem 'guard', '1.7.0'
  # gem 'guard-rspec', '2.5.2'
  # 
  # # spork gems
  # gem 'guard-spork', '1.4.2'
  gem 'spork', '0.9.2'
end

group :test do
  gem 'rspec'
  gem 'rack-test'
  
  gem 'capybara', '1.1.2'

  ###### System-dependent gems goes below here
  ### Test gems on Macintosh OS X
  # gem 'rb-fsevent', '0.9.4', :require => false
  # gem 'growl', '1.0.3'

  ### Test gems on Linux
  # gem 'rb-inotify', '0.8.8'
  # gem 'libnotify', '0.5.9'

  ### Test gems on Windows
  # gem 'rb-fchange', '0.0.5'
  # gem 'rb-notifu', '0.0.4'
  # gem 'win32console', '1.3.0'
end