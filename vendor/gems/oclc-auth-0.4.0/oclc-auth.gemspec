# -*- encoding: utf-8 -*-
require File.expand_path('../lib/oclc/auth/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Steve Meyer"]
  gem.email         = ["devnet@oclc.org"]
  gem.description   = %q{OCLC authentication gem}
  gem.summary       = %q{A Ruby wrapper around API key authentication to OCLC Web Services.}
  gem.homepage      = "http://www.oclc.org/developer"

  # gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "oclc-auth"
  gem.require_paths = ["lib"]
  gem.version       = OCLC::Auth::VERSION
  gem.files = [
    "Gemfile",
    "Rakefile", 
    "oclc-auth.gemspec", 
    "lib/oclc/auth.rb",
    "lib/oclc/auth/version.rb",
    "lib/oclc/auth/access_token.rb",
    "lib/oclc/auth/auth_code.rb",
    "lib/oclc/auth/exception.rb",
    "lib/oclc/auth/wskey.rb"
    ]
  
  gem.add_dependency 'json', '~> 1.8', '>= 1.8.1'
  gem.add_dependency 'rest-client', '~> 1.6', '>= 1.6.7'
  
  gem.add_development_dependency 'rspec', '~> 2.14', '>= 2.14.1'
  gem.add_development_dependency 'simplecov', '~> 0.8', '>= 0.8.2'
  gem.add_development_dependency 'webmock', '~> 1.16'
end
