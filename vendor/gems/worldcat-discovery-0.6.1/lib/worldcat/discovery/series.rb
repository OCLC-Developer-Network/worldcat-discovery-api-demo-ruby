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
    
    # == Properties mapped from RDF data
    #
    # RDF properties are mapped via an ORM style mapping.
    # 
    # [name] RDF predicate: http:/schema.org/name; returns: String 
    # [parts] RDF predicate: http://schema.org/hasPart; returns: Enumerable of WorldCat::Discovery::Bib objects
    
    class Series < Spira::Base
      
      property :name, :predicate => SCHEMA_NAME, :type => XSD.string
      property :creator, :predicate => SCHEMA_CREATOR, :type => 'Person'
      has_many :parts, :predicate => SCHEMA_HAS_PART, :type => 'Bib'

    end
  end
end