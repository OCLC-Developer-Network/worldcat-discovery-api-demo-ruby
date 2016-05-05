# Copyright 2016 OCLC
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

require 'spec_helper'

describe "the record page" do
  context "when displaying a periodical" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/bib/data/2243594").
        to_return(:status => 200, :body => mock_file_contents("2243594.rdf"))
      get '/catalog/883876185'
      @doc = Nokogiri::HTML(last_response.body)
    end
    it "should display the title" do
      xpath = "//h1[@id='bibliographic-resource-name'][text()='Journal of academic librarianship.']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the similar to" do
      xpath = "//p[@id='similarTo']/span/a[text()='Journal of academic librarianship (Online)']"
      expect(@doc.xpath(xpath)).not_to be_empty      
    end
    
    it "should display the subjects" do
      @subjects = @doc.xpath("//ul[@id='subjects']/li/span/a/text()")
      expect(@subjects).to include("Library science")
      expect(@subjects).to include("Academic libraries")
    end
    
    it "should display the genres" do
      @genres = @doc.xpath("//ul[@id='genres']/li/span/a/text()")
      expect(@genres).to include("Periodicals")
      expect(@genres).to include("Electronic journals")
    end
    
    it "should display the format" do
      #this is busted
      xpath = "//span[@id='format'][text()='Journal/Serial']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the language" do
      #this is busted
      xpath = "//span[@id='language'][text()='English']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the publication places" do
      @publiciationPlaces = @doc.xpath("//span[@property='library:placeOfPublication']/text()")
      expect(@publiciationPlaces).to include("New York, etc. :")
    end
    
    it "should display the publisher" do
      xpath = "//span[@property='schema:publisher']/span[@property='schema:name'][text()='[Elsevier Inc., etc.']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the date published" do
      xpath = "//span[@property='schema:datePublished'][text()='1975/9999']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the ISSNs" do
      xpath = "//span[@property='schema:issn'][text()='0099-1333']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the OCLC Number" do
      xpath = "//span[@property='library:oclcnum'][text()='2243594']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
  end
end
