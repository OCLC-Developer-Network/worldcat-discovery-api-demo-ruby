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

describe OCLC::Auth::AccessToken do
  before(:all) do
    @token = OCLC::Auth::AccessToken.new('client_credentials', 'WMS_Availability', 128807, 91475)
  end
  
  it "should construct a token with the correct fields" do
    @token.grant_type.should == 'client_credentials'
    @token.authenticating_institution_id.should == 128807
    @token.context_institution_id.should == 91475
    @token.scope.should == 'WMS_Availability'
    @token.redirect_uri.should == nil
    @token.code.should == nil
  end
  
  it "should produced the correct request URL" do
    expected_url = 'https://authn.sd00.worldcat.org/oauth2/accessToken?' + 
        'grant_type=client_credentials&scope=WMS_Availability&contextInstitutionId=91475&authenticatingInstitutionId=128807'
    expected_uri = URI.parse(expected_url)
    actual_uri = URI.parse(@token.request_url)
    
    actual_uri.hostname.should == expected_uri.hostname
    actual_uri.path.should == expected_uri.path
    
    expected_params = CGI.parse(expected_uri.query)
    actual_params = CGI.parse(actual_uri.query)
    expected_params.should == actual_params
  end
  
  it "should parse the token JSON data" do
    stub_request(:post, @token.request_url).to_return(
        :body => File.new("#{File.expand_path(File.dirname(__FILE__))}/../../support/responses/token.json"),
        :status => 200)
          
    wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret')
    @token.create!(wskey)
    @token.value.should == 'tk_fdsa'
    @token.principal_id.should == 'principal-ID'
    @token.principal_idns.should == 'principal-IDNS'
    
    expected = DateTime.parse('2013-12-05 19:35:42Z')
    @token.expires_at.should == expected
  end
  
  it "should throw an exception if the wskey is not authorized for the institution" do
    stub_request(:post, @token.request_url).to_return(
        :body => File.new("#{File.expand_path(File.dirname(__FILE__))}/../../support/responses/errorToken.json"),
        :status => 403)
              
    wskey = OCLC::Auth::WSKey.new('api-key', 'api-key-secret')
  lambda {@token.create!(wskey)}.should raise_error(OCLC::Auth::Exception)
  lambda {@token.create!(wskey)}.should raise_error(OCLC::Auth::Exception, 'unauthorized_client')
  end
  
  it "should report the token is expired" do
    @token.expired?().should == true
  end
end