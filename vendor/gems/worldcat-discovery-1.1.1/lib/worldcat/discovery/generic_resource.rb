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

module WorldCat
  module Discovery
    
    # A generic resource corresponding to the document representing a bibliographic resource. 
    # This class should not be used by clients, rather WorldCat::Discovery::Bib objects should
    # be used instead.
    
    class GenericResource < Spira::Base
      
      property :about, :predicate => SCHEMA_ABOUT, :type => 'Bib'
      has_many :datasets, :predicate => VOID_IN_DATASET, :type => RDF::URI
      property :date_modified, :predicate => SCHEMA_DATE_MODIFIED, :type => XSD.string
      
    end
  end
end