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

describe "the article record page" do
  before(:all) do
    url = 'https://authn.sd00.worldcat.org/oauth2/accessToken?authenticatingInstitutionId=128807&contextInstitutionId=128807&grant_type=client_credentials&scope=WorldCatDiscoveryAPI'
    stub_request(:post, url).to_return(:body => mock_file_contents("token.json"), :status => 200)
  end
  context "when displaying an article with an issue and volume (5131938809)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/offer/oclc/5131938809?heldBy=OCPSB").
        to_return(:status => 200, :body => mock_file_contents("offer_set_5131938809.rdf"))
      get '/catalog/5131938809'
      @doc = Nokogiri::HTML(last_response.body)
    end    
    
    it "should display the title" do
      puts @doc
      xpath = "//h1[@id='bibliographic-resource-name'][text()='How Much Would US Style Fiscal Integration Buffer European Unemployment and Income Shocks? (A Comparative Empirical Analysis)']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the author" do
      author_name = @doc.xpath("//h2[@id='author-name']/a/text()")
      expect(author_name.to_s.gsub("\n", '').squeeze(' ').strip).to be == "Feyrer, James"
    end
    
    it "should display the contributors" do
      @contributors = @doc.xpath("//ul[@id='contributors']/li/span/a/text()")
      expect(@contributors.size).to eq(1)
      @contributors = @contributors.map {|contributor| contributor.to_s.gsub("\n", '').squeeze(' ').strip}
      expect(@contributors).to include("Sacerdote, Bruce")
    end
    
    it "should display the format" do
      xpath = "//span[@id='format'][text()='Article']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the language" do
      xpath = "//span[@id='language'][text()='English']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the publisher" do
      xpath = "//span[@property='schema:publisher']/span[@property='schema:name'][text()='American Economic Association']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the date published" do
      xpath = "//span[@property='schema:datePublished'][text()='2013-05-01']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the OCLC Number" do
      xpath = "//span[@property='library:oclcnum'][text()='5131938809']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should have the right periodical name" do
      xpath = "//p[@id='citation']/span/span/span/span[@property='schema:name'][text()='American Economic Review']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should have the right volume" do
      xpath = "//span[@property='schema:volumeNumber'][text()='103']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should have the right issue" do
      xpath = "//span[@property='schema:issueNumber'][text()='3']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should have the right start page" do
      xpath = "//span[@property='schema:pageStart'][text()='125']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should have the right end page" do
      xpath = "//span[@property='schema:pageEnd'][text()='128']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the descriptions" do
      @descriptions = @doc.xpath("//p[@property='schema:description']/text()")
      expect(@descriptions.count).to eq(1)
      @descriptions = @descriptions.map {|description| description.to_s}
      File.open("#{File.expand_path(File.dirname(__FILE__))}/../text/5131938809_descriptions.txt").each do |line|
        expect(@descriptions).to include(line.chomp)
      end
    end
    
  end
  
  context "when displaying an article with no issue (204144725)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/offer/oclc/204144725?heldBy=OCPSB").
        to_return(:status => 200, :body => mock_file_contents("offer_set_204144725.rdf"))
      get '/catalog/204144725'
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should display the title" do
      title = @doc.xpath("//h1[@id='bibliographic-resource-name']/text()")
      expect(title.to_s.gsub("\n", '').squeeze(' ').strip).to be == "Van Gogh's Rediscovered Night Sky What brilliant celestial object did Vincent van Gogh include in his painting White House at Night?"
    end
    
    it "should display the author" do
      author_name = @doc.xpath("//h2[@id='author-name']/a/text()")
      expect(author_name.to_s.gsub("\n", '').squeeze(' ').strip).to be == "Olson, D. W."
    end
    
    it "should display the contributors" do
      @contributors = @doc.xpath("//ul[@id='contributors']/li/span/a/text()")
      expect(@contributors.size).to eq(1)
      @contributors = @contributors.map {|contributor| contributor.to_s.gsub("\n", '').squeeze(' ').strip}
      expect(@contributors).to include("Doescher, R. L.")
    end
    
    it "should display the format" do
      xpath = "//span[@id='format'][text()='Article']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the language" do
      xpath = "//span[@id='language'][text()='English']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the date published" do
      xpath = "//span[@property='schema:datePublished'][text()='2001']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the OCLC Number" do
      xpath = "//span[@property='library:oclcnum'][text()='204144725']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end    
    
    it "should have the right periodical name" do
      xpath = "//p[@id='citation']/span/span/span[@property='schema:name'][text()='SKY AND TELESCOPE']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should have the right volume" do
      xpath = "//span[@property='schema:volumeNumber'][text()='101']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should have the right start page" do
      xpath = "//span[@property='schema:pageStart'][text()='34']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
        
  end
  
  context "when displaying an article with no issue or volume  (777986070)" do
    before(:all) do
      stub_request(:get, "https://beta.worldcat.org/discovery/offer/oclc/777986070?heldBy=OCPSB").
        to_return(:status => 200, :body => mock_file_contents("offer_set_777986070.rdf"))
      get '/catalog/777986070'
      @doc = Nokogiri::HTML(last_response.body)
    end
    
    it "should display the title" do
      xpath = "//h1[@id='bibliographic-resource-name'][text()='MapFAST a FAST geographic authorities mashup with Google Maps']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the author" do
      author_name = @doc.xpath("//h2[@id='author-name']/a/text()")
      expect(author_name.to_s.gsub("\n", '').squeeze(' ').strip).to be == "Rick Bennet"
    end
    
    it "should display the contributors" do
      @contributors = @doc.xpath("//ul[@id='contributors']/li/span/a/text()")
      expect(@contributors.size).to eq(4)
      @contributors = @contributors.map {|contributor| contributor.to_s.gsub("\n", '').squeeze(' ').strip}
  
      expect(@contributors).to include("OCLC Research.")
      expect(@contributors).to include("Edward T. O'Neill")
      expect(@contributors).to include("J. D. Shipengrover")
      expect(@contributors).to include("Kerre Kammerer")
    end
    
    it "should display the subjects" do
      @subjects = @doc.xpath("//ul[@id='subjects']/li/span/a/text()")
      
      expect(@subjects.count).to eq(2)
      @subjects = @subjects.map {|subject_value| subject_value.to_s}
  
      expect(@subjects).to include("Mashups (World Wide Web)--Library applications")
      expect(@subjects).to include("FAST subject headings")

    end
    
    it "should display the format" do
      xpath = "//span[@id='format'][text()='Article']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the language" do
      xpath = "//span[@id='language'][text()='English']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the OCLC Number" do
      xpath = "//span[@property='library:oclcnum'][text()='777986070']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should have the right periodical name" do
      xpath = "//p[@id='citation']/span/span[@property='schema:name'][text()='Code4lib journal']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should have the right pagination" do
      xpath = "//span[@property='schema:pagination'][text()='issue 14 (July 25, 2011)']"
      expect(@doc.xpath(xpath)).not_to be_empty
    end
    
    it "should display the descriptions" do
      @descriptions = @doc.xpath("//p[@property='schema:description']/text()")
      expect(@descriptions.count).to eq(1)
      @descriptions = @descriptions.map {|description| description.to_s}
      File.open("#{File.expand_path(File.dirname(__FILE__))}/../text/777986070_descriptions.txt").each do |line|
        expect(@descriptions).to include(line.chomp)
      end
    end     
  end
end
