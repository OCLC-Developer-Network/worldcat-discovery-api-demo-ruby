# Copyright 2014 OCLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative '../../spec_helper'

describe WorldCat::Discovery::Offer do
  
  context "when retrieving holdings as offers for a bib" do
    before(:all) do
      wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret', :services => ['WorldCatDiscoveryAPI'])
      WorldCat::Discovery.configure(wskey, 128807, 128807)
      
      access_token_request_url = "https://authn.sd00.worldcat.org/oauth2/accessToken?" + 
          "authenticatingInstitutionId=128807&contextInstitutionId=128807&" + 
          "grant_type=client_credentials&scope=WorldCatDiscoveryAPI"
      stub_request(:post, access_token_request_url).to_return(:body => body_content("access_token.json"), :status => 200)

      url = 'https://beta.worldcat.org/discovery/offer/oclc/30780581'
      stub_request(:get, url).to_return(:body => body_content("offer_set.rdf"), :status => 200)
      @results = WorldCat::Discovery::Offer.find_by_oclc(30780581)
    end
    
    it "should return a offer results set" do
      @results.class.should == WorldCat::Discovery::OfferSearchResults
    end

    it "should contain the right id" do
      uri = RDF::URI("https://beta.worldcat.org/discovery/offer/oclc/30780581?itemsPerPage=10=0")
      @results.id.should == uri
    end
    
    it "should have the right number of items" do
      @results.items.size.should == 10
    end
    
    it "should return a result set of Offers" do
      @results.items.each {|offer| offer.class.should == WorldCat::Discovery::Offer}
    end
    
    it "should respond to a request for its items as offers" do
      @results.offers.size.should == 10
      @results.offers.each {|item| item.class.should == WorldCat::Discovery::Offer}
    end
    
    it "should return the Offers in the correct order" do
      i = 1
      @results.offers.each {|offer| offer.display_position.should == i; i += 1}
    end
    
    it "should have the correct total results" do
      @results.total_results.should == 579
    end
    
    it "should have the correct start index" do
      @results.start_index.should == 0
    end
    
    it "should have the correct items per page" do
      @results.items_per_page.should == 10
    end
    
    it "should have the correct bib" do
      @bib = @results.bib
      @bib.id.should == RDF::URI.new('http://www.worldcat.org/oclc/30780581')
      @bib.name.should == 'The Wittgenstein reader'
      @bib.class.should == WorldCat::Discovery::Bib
    end
    
    context "when looking at the first offer" do
      before(:all) do
        @offer = @results.offers.first
        @item_offered = @offer.item_offered
        @collection = @item_offered.collection
        @library = @collection.library
      end
      
      it "should have the correct type" do
        @offer.type.should == RDF::URI.new('http://schema.org/Offer')
      end
      
      it "should have the correct display position" do
        @offer.display_position.should == 1
      end
      
      it "should have the correct item offered" do
        @item_offered.id.should == RDF::Node.new("A19")
        @item_offered.type.should == RDF::URI.new('http://schema.org/SomeProducts')
        @item_offered.bib.subject.should == RDF::URI.new('http://www.worldcat.org/oclc/30780581')
        @item_offered.bib.name.should == 'The Wittgenstein reader'
      end

      it "should belong to the correct collection" do
        @collection.id.should == RDF::URI.new('http://worldcat.org/wcr/oclc-symbol/resource/AIZ')
        @collection.type.should == RDF::URI.new('http://purl.org/dc/terms/Collection')
        @collection.oclc_symbol.should == 'AIZ'
      end

      it "should be managed by the correct library" do
        @library.id.should == 'http://worldcat.org/wcr/organization/resource/72545'
        @library.type.should == RDF::URI.new('http://schema.org/Library')
        @library.name.should == 'ACADEMIA SINICA INST EUROPEAN AM STUDIES'
        @library.collection.should == @collection
      end
    end
  end
  
  context "when retrieving holdings as offers for a bib that is an Article" do
    before(:all) do
      url = 'https://beta.worldcat.org/discovery/offer/oclc/5131938809'
      stub_request(:get, url).to_return(:body => body_content("offer_set_5131938809.rdf"), :status => 200)
      @results = WorldCat::Discovery::Offer.find_by_oclc(5131938809)
    end
    
    it "should have not offers" do
      @results.offers.count.should == 0
    end
    
    it "should have the correct bib" do
      @bib = @results.bib
      @bib.id.should == RDF::URI.new('http://www.worldcat.org/oclc/5131938809')
      @bib.name.should == 'How Much Would US Style Fiscal Integration Buffer European Unemployment and Income Shocks? (A Comparative Empirical Analysis)'
      @bib.class.should == WorldCat::Discovery::Article
    end
  end

  context "when retrieving holdings as offers for a bib that is a Movie" do
    before(:all) do
      url = 'https://beta.worldcat.org/discovery/offer/oclc/62774704'
      stub_request(:get, url).to_return(:body => body_content("offer_set_62774704.rdf"), :status => 200)
      @results = WorldCat::Discovery::Offer.find_by_oclc(62774704)
    end
    
    it "should have the correct bib" do
      @bib = @results.bib
      @bib.id.should == RDF::URI.new('http://www.worldcat.org/oclc/62774704')
      @bib.name.should == 'Pride & prejudice'
      @bib.class.should == WorldCat::Discovery::Movie
    end
  end
  
  context "when retrieving holdings as offers for a bib that is a MusicAlbum" do
    before(:all) do
      url = 'https://beta.worldcat.org/discovery/offer/oclc/226390945'
      stub_request(:get, url).to_return(:body => body_content("offer_set_226390945.rdf"), :status => 200)
      @results = WorldCat::Discovery::Offer.find_by_oclc(226390945)
    end
    
    it "should have the correct bib" do
      @bib = @results.bib
      @bib.id.should == RDF::URI.new('http://www.worldcat.org/oclc/226390945')
      @bib.name.should == 'Song for an uncertain lady'
      @bib.class.should == WorldCat::Discovery::MusicAlbum
    end
  end  

  context "when retrieving holdings as offers for a bib that is a Periodical" do
    before(:all) do
      url = 'https://beta.worldcat.org/discovery/offer/oclc/2243594'
      stub_request(:get, url).to_return(:body => body_content("offer_set_2243594.rdf"), :status => 200)
      @results = WorldCat::Discovery::Offer.find_by_oclc(2243594)
    end
    
    it "should have the correct bib" do
      @bib = @results.bib
      @bib.id.should == RDF::URI.new('http://www.worldcat.org/oclc/2243594')
      @bib.name.should == 'Journal of academic librarianship.'
      @bib.class.should == WorldCat::Discovery::Periodical
    end
  end
  
  context "if sending an invalid Access Token" do
    before(:all) do
      url = 'https://beta.worldcat.org/discovery/offer/oclc/30780581'
      stub_request(:get, url).to_return(:body => body_content("error_response_bad_access_token.rdf"), :status => 401)
      @results = WorldCat::Discovery::Offer.find_by_oclc(30780581)
    end
    
    it "should return a client request error" do
      @results.class.should == WorldCat::Discovery::ClientRequestError
    end

    it "should contain the right id" do
      @results.subject.should == RDF::Node.new("A0")
    end

    it "should have an error message" do
      @results.error_message.should == 'The given access token is not authorized to view this resource.  Please check your Authorization header and try again.'
    end
    
    it "should have an error code" do
      @results.error_code.should == 401
    end
    
    it "should have an error type" do
      @results.error_type.should == 'http'
    end
  end
  
  context "if sending an Access Token for the wrong service" do
    before(:all) do
      url = 'https://beta.worldcat.org/discovery/offer/oclc/30780581'
      stub_request(:get, url).to_return(:body => body_content("error_response_access_token_wrong_service.rdf"), :status => 401)
      @results = WorldCat::Discovery::Offer.find_by_oclc(30780581)
    end
    
    it "should return a client request error" do
      @results.class.should == WorldCat::Discovery::ClientRequestError
    end

    it "should contain the right id" do
      @results.subject.should == RDF::Node.new("A0")
    end

    it "should have an error message" do
      @results.error_message.should == 'Access to this resource is denied.  Please check your Authorization header and try again.'
    end
    
    it "should have an error code" do
      @results.error_code.should == 403
    end
    
    it "should have an error type" do
      @results.error_type.should == 'http'
    end
  end  
  
  context "if sending an unknown OCLC Number" do
    before(:all) do
      url = 'https://beta.worldcat.org/discovery/offer/oclc/999999999999999'
      stub_request(:get, url).to_return(:body => body_content("error_response_not_found.rdf"), :status => 404)
      @results = WorldCat::Discovery::Offer.find_by_oclc(999999999999999)
    end
    
    it "should return a client request error" do
      @results.class.should == WorldCat::Discovery::ClientRequestError
    end

    it "should contain the right id" do
      @results.subject.should == RDF::Node.new("A0")
    end

    it "should have an error message" do
      @results.error_message.should == 'The requested record could not be found.'
    end
    
    it "should have an error code" do
      @results.error_code.should == 404
    end
    
    it "should have an error type" do
      @results.error_type.should == 'http'
    end
  end
  
end