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

wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret', :services => ['WorldCatDiscoveryAPI'])
WorldCat::Discovery.configure(wskey, 128807, 128807)

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

wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret', :services => ['WorldCatDiscoveryAPI'])
WorldCat::Discovery.configure(wskey, 128807, 128807)

params = Hash.new
params[:q] = 'programming ruby'
params[:facetFields] = ['itemType:10', 'inLanguage:10']
params[:startNum] = 0
results = WorldCat::Discovery::Bib.search(params)

results.bibs.map {|bib| str = bib.name; str += " (#{bib.date_published})" if bib.date_published; str}
# => ["Programming Ruby. (2008)", "Programming Ruby : the pragmatic programmers' guide (2005)", "The Ruby programming language (2008)", ... ]
```
### Understanding the subclasses
The library contains subclasses for different types of materials that appear within WorldCat. These include:
+ Article
+ Movie
+ Music Album
+ Periodical

#### Article Example

```ruby
require 'worldcat/discovery'

wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret', :services => ['WorldCatDiscoveryAPI'])
WorldCat::Discovery.configure(wskey, 128807, 128807)

bib = WorldCat::Discovery::Bib.find(5131938809)

bib.name            # => "How Much Would US Style Fiscal Integration Buffer European Unemployment and Income Shocks? (A Comparative Empirical Analysis)"
bib.id              # => #<RDF::URI:0x3feb33057c70 URI:http://www.worldcat.org/oclc/5131938809>
bib.id.to_s         # => "http://www.worldcat.org/oclc/5131938809"
bib.type            # => #<RDF::URI:0x3feb3300fe84 URI:http://schema.org/Article>
bib.type.to_s       # => "http://schema.org/Article" 
bib.author          # => <WorldCat::Discovery::Person:70279384406040 @subject: http://viaf.org/viaf/107579098> 
bib.author.name     # => "Feyrer, James"
bib.contributors.map{|contributor| contributor.name} # => ["Sacerdote, Bruce", "Feyrer, James"]
bib.page_start      # => 125
bib.page_end        # => 128
bib.periodical_name # => "American Economic Review"
bib.volume_number   # => 3
bib.issue_number    # => 103

```
