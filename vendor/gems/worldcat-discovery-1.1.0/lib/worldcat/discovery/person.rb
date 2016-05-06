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
    # [type] RDF predicate: http://www.w3.org/1999/02/22-rdf-syntax-ns#type; returns: RDF::URI
    # [name] RDF predicate: http://schema.org/name; returns: String
    
    class Person < Spira::Base
      
      property :name, :predicate => SCHEMA_NAME, :type => XSD.string
      property :type, :predicate => RDF.type, :type => RDF::URI
      property :given_name, :predicate => SCHEMA_GIVEN_NAME, :type => XSD.string
      property :family_name, :predicate => SCHEMA_FAMILY_NAME, :type => XSD.string
      property :birth_date, :predicate => SCHEMA_BIRTH_DATE, :type => XSD.string
      property :death_date, :predicate => SCHEMA_DEATH_DATE, :type => XSD.string
      
      # call-seq:
      #   id() => RDF::URI
      # 
      # Will return the RDF::URI object that serves as the RDF subject of the current Person
      def id
        self.subject
      end
      
    end
  end
end