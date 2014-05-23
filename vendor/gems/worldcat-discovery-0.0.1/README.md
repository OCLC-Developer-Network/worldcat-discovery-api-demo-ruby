# Worldcat::Discovery

Ruby gem wrapper around WorldCat Discovery API. 

Please Note: This API is not yet in production and this documentation is only published for our group 
of alpha release testers for feedback purposes only.

## Installation

Prior to installing this gem manually as outlined below, you will need to go through the same 
process for the [OCLC::Auth](https://github.com/OCLC-Developer-Network/oclc-auth-ruby) gem for the API key dependency.

```bash
$ git clone https://github.com/OCLC-Developer-Network/worldcat-discovery-ruby.git
$ cd worldcat-discovery-ruby
$ gem build worldcat-discovery.gemspec
$ gem install worldcat-discovery-<VERSION-NUMBER>.gem
```

## Usage

### Find a Bibliographic Resource in WorldCat

```ruby
require 'worldcat/discovery'

wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret')
WorldCat::Discovery.configure(wskey)

bib = WorldCat::Discovery::Bib.find(255034622)

bib.name         # => "Programming Ruby."
bib.id           # => #<RDF::URI:0x3feb33057c70 URI:http://www.worldcat.org/oclc/255034622>
bib.id.to_s      # => "http://www.worldcat.org/oclc/255034622"
bib.type         # => #<RDF::URI:0x3feb3300fe84 URI:http://schema.org/Book>
bib.type.to_s    # => "http://schema.org/Book" 
bib.author       # => <WorldCat::Discovery::Person:70279384406040 @subject: http://viaf.org/viaf/107579098> 
bib.author.name  # => "Thomas, David."
bib.contributors.map{|contributor| contributor.name} # => [" Fowler, Chad.", "Hunt, Andrew."]
```

### Search for Bibliographic Resources in WorldCat

```ruby
require 'worldcat/discovery'

wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret')
WorldCat::Discovery.configure(wskey)

params = Hash.new
params[:q] = 'programming ruby'
params[:facets] = ['author:10', 'inLanguage:10']
params[:startNum] = 0
results = WorldCat::Discovery::Bib.search(params)

results.bibs.map {|bib| str = bib.name; str += " (#{bib.date_published})" if bib.date_published; str}
# => ["Programming Ruby. (2008)", "Programming Ruby : the pragmatic programmers' guide (2005)", "The Ruby programming language (2008)", ... ]
```