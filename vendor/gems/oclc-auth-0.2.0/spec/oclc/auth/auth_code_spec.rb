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

describe OCLC::Auth::AuthCode do
  before(:all) do
    @auth_code = OCLC::Auth::AuthCode.new('api-key', 128807, 91475, 'http://localhost:4567/catch_auth_code', 'WMS_Availability')
  end
  
  it "should construct an auth code with the right fields" do
    @auth_code.client_id.should == 'api-key'
    @auth_code.authenticating_institution_id.should == 128807
    @auth_code.context_institution_id.should == 91475
    @auth_code.redirect_uri.should == 'http://localhost:4567/catch_auth_code'
    @auth_code.scope.should == 'WMS_Availability'
  end
  
  it "should have the correct production URL configured" do
    OCLC::Auth::AuthCode.production_url.should == 'https://authn.sd00.worldcat.org/oauth2/authorizeCode'
  end
  
  it "should produce the correct login URL" do
    uri = URI.parse(@auth_code.login_url)
    uri.hostname.should == 'authn.sd00.worldcat.org'
    uri.path.should == '/oauth2/authorizeCode'
    params = CGI.parse(uri.query)
    params["client_id"].should == ["api-key"]
    params["authenticatingInstitutionId"].should == ["128807"]
    params["contextInstitutionId"].should == ["91475"]
    params["redirect_uri"].should == ["http://localhost:4567/catch_auth_code"]
    params["response_type"].should == ["code"]
    params["scope"].should == ["WMS_Availability"]
  end
  
  it "should enable override of the auth server URL" do
    @auth_code.auth_server_url = 'https://localhost/oauth2/authorizeCode'
    uri = URI.parse(@auth_code.login_url)
    uri.hostname.should == 'localhost'
  end
end