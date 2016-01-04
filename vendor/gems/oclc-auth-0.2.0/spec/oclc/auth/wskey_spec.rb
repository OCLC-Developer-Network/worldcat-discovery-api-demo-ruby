# Copyright 2013 OCLC
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

describe OCLC::Auth::WSKey do
  context "when testing the HMAC signature pattern" do
    before(:all) do
      @wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret')
      @wskey.debug_timestamp = 1386264196
      @wskey.debug_nonce = 'as7shfn3'
    end
  
    it "should construct a key with the right fields" do
      @wskey.key.should == 'api-key'
      @wskey.secret.should == 'api-key-secret'
      @wskey.redirect_uri.should == nil
      @wskey.services.should == nil
    end
    
    it "should produce the correct signature when no principal info is required" do
      signature = @wskey.hmac_signature('GET', 'https://worldcat.org/circ/availability/sru/service?x-registryId=91475&query=no:+ocm42692282')
      signature.should == 'http://www.worldcat.org/wskey/v2/hmac/v1 clientId="api-key", timestamp="1386264196", nonce="as7shfn3", ' + 
          'signature="iuWyElIi0pvb2ahNyzDK1kRj+qE0Wr4eCRwPrLhwXcI="'
    end

    it "should produce the correct signature when principal info is required and already included in the URL" do
      url = 'https://worldcat.org/bib/data/823520553?classificationScheme=LibraryOfCongress&holdingLibraryCode=MAIN&' +
          'principalID=201571dd-b197-42e1-bd36-9fea404a864d&principalIDNS=urn:oclc:wms:da'
      signature = @wskey.hmac_signature('GET', url, :principal_id => '201571dd-b197-42e1-bd36-9fea404a864d', :principal_idns => 'urn:oclc:wms:da')
      signature.should == 'http://www.worldcat.org/wskey/v2/hmac/v1 clientId="api-key", timestamp="1386264196", nonce="as7shfn3", ' + 
          'signature="/6o6Of9SZDPPQG7gIi6Qpbf4xqvQQ7lHK06EMiAZ6o0="'
    end

    it "should produce the correct signature when principal info is required and not already included in the URL" do
      url = 'https://worldcat.org/bib/data/823520553?classificationScheme=LibraryOfCongress&holdingLibraryCode=MAIN'
      signature = @wskey.hmac_signature('GET', url, :principal_id => '201571dd-b197-42e1-bd36-9fea404a864z', :principal_idns => 'urn:oclc:wms:da')
      signature.should == 'http://www.worldcat.org/wskey/v2/hmac/v1 clientId="api-key", timestamp="1386264196", nonce="as7shfn3", ' + 
          'signature="1IHjKiIqrvg6bw/OJ6LzxMSrQDuaY+F0qMioo09fBII=", principalID="201571dd-b197-42e1-bd36-9fea404a864z", principalIDNS="urn:oclc:wms:da"'
    end
    
    it "should add the principal info to the signature when there are no URL query parameters" do
      url = 'https://128807.share.worldcat.org/ncip/circ-patron'
      signature = @wskey.hmac_signature('GET', url, :principal_id => '201571dd-b197-42e1-bd36-9fea404a864z', :principal_idns => 'urn:oclc:wms:da')
      signature.should == 'http://www.worldcat.org/wskey/v2/hmac/v1 clientId="api-key", timestamp="1386264196", nonce="as7shfn3", ' + 
          'signature="zzKvqg051OgLuTcE8HqPUjF1TaHyBk+iUnfBr9xMngY=", principalID="201571dd-b197-42e1-bd36-9fea404a864z", principalIDNS="urn:oclc:wms:da"'
    end
    
    it "should handle a URL with multiples instances of the same parameter" do
      url = "https://beta.worldcat.org/discovery/bib/search?q=wittgenstein+reader&facets=author%3A10&facets=inLanguage%3A10"
      signature = @wskey.hmac_signature('GET', url)
      signature.should == 'http://www.worldcat.org/wskey/v2/hmac/v1 clientId="api-key", timestamp="1386264196", nonce="as7shfn3", ' + 
          'signature="VoG1j6XSPPbwUbUiFY8eCx2/7JyqGWGTtZDwA+y7A4w="'
    end
  end
  
  
  context "when testing the explicit authorization pattern" do
    before(:all) do
      @wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret', :redirect_uri => 'http://localhost:4567/catch_auth_code', :services => ['WMS_Availability', 'WMS_NCIP'])
    end

    it "should construct a key with the right fields" do
      @wskey.key.should == 'api-key'
      @wskey.secret.should == 'api-key-secret'
      @wskey.redirect_uri.should == 'http://localhost:4567/catch_auth_code'
      @wskey.services.should == ['WMS_Availability', 'WMS_NCIP']
    end

    context "when obtaining an authorization code" do
      it "should produce the correct login URL" do
        expected_url = 'https://authn.sd00.worldcat.org/oauth2/authorizeCode?client_id=api-key&authenticatingInstitutionId=128807&contextInstitutionId=91475&' + 
            'redirect_uri=http%3A%2F%2Flocalhost%3A4567%2Fcatch_auth_code&response_type=code&scope=WMS_Availability+WMS_NCIP'
        expected_uri = URI.parse(expected_url)

        actual_url = @wskey.login_url(128807, 91475)
        actual_uri = URI.parse(actual_url)

        actual_uri.hostname.should == expected_uri.hostname
        actual_uri.path.should == expected_uri.path
        expected_params = CGI.parse(expected_uri.query)
        actual_params = CGI.parse(actual_uri.query)
        expected_params.should == actual_params
      end

      it "should throw an exception if the services are empty" do
        wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret', :redirect_uri => 'http://localhost:4567/catch_auth_code', :services => [])
        lambda { wskey.login_url(128807, 91475) }.should raise_error(OCLC::Auth::Exception)
      end

      it "should throw an exception if the services are absent" do
        wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret', :redirect_uri => 'http://localhost:4567/catch_auth_code')
        lambda { wskey.login_url(128807, 91475) }.should raise_error(OCLC::Auth::Exception)
      end
    end

    context "when redeeming an authorization code for an access token" do
      it "should return an object with the class OCLC::Auth::AccessToken" do
        url = 'https://authn.sd00.worldcat.org/oauth2/accessToken?' + 
            'authenticatingInstitutionId=128807&contextInstitutionId=91475&grant_type=authorization_code&scope=WMS_Availability+WMS_NCIP&' +
            'redirect_uri=http%3A%2F%2Flocalhost%3A4567%2Fcatch_auth_code&code=the_code'
        stub_request(:post, url).to_return(
            :body => File.new("#{File.expand_path(File.dirname(__FILE__))}/../../support/responses/token.json"),
            :status => 200)
      
        token = @wskey.auth_code_token('the_code', 128807, 91475)
        token.class.should == OCLC::Auth::AccessToken
      end
      
    end
  end
  
  
  context "when testing the client credentials grant pattern" do
    before(:all) do
      @wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret', :services => ['WMS_Availability', 'WMS_NCIP'])
    end

    it "should construct a key with the right fields" do
      @wskey.key.should == 'api-key'
      @wskey.secret.should == 'api-key-secret'
      @wskey.redirect_uri.should == nil
      @wskey.services.should == ['WMS_Availability', 'WMS_NCIP']
    end
    
    it "should return an object with the class OCLC::Auth::AccessToken" do
      url = 'https://authn.sd00.worldcat.org/oauth2/accessToken?' + 
          'authenticatingInstitutionId=128807&contextInstitutionId=91475&grant_type=client_credentials&scope=WMS_Availability%20WMS_NCIP'
      stub_request(:post, url).to_return(
          :body => File.new("#{File.expand_path(File.dirname(__FILE__))}/../../support/responses/token.json"),
          :status => 200)
  
      token = @wskey.client_credentials_token(128807, 91475)
      token.class.should == OCLC::Auth::AccessToken
    end
    
    it "should throw an exception if the services are empty" do
      wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret', :services => [])
      lambda { wskey.client_credentials_token(128807, 91475) }.should raise_error(OCLC::Auth::Exception)
    end

    it "should throw an exception if the services are absent" do
      wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret')
      lambda { wskey.client_credentials_token(128807, 91475) }.should raise_error(OCLC::Auth::Exception)
    end
  end
end















