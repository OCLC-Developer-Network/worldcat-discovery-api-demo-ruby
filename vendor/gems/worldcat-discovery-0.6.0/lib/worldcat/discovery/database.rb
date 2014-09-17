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
    # [name] RDF predicate: http://schema.org/name; returns: String
    # [type] RDF predicate: http://www.w3.org/1999/02/22-rdf-syntax-ns#type; returns: RDF::URI
    # [database_id] RDF predicate: http://worldcat.org/vocab/discovery/dbId; returns: Integer
    # [description] RDF predicate: http://schema.org/description; returns: String

    class Database < Spira::Base
      
      property :name, :predicate => SCHEMA_NAME, :type => XSD.string
      property :type, :predicate => RDF.type, :type => RDF::URI
      property :database_id, :predicate => DISCOVERY_DB_ID, :type => XSD.integer
      property :description, :predicate => SCHEMA_DESCRIPTION, :type => XSD.string
      property :open_access, :predicate => DISCOVERY_OPEN, :type => XSD.string
      property :requires_authn, :predicate => DISCOVERY_REQUIRES_AUTHN, :type => XSD.boolean
      
      def requires_authentication
        if self.requires_authn.nil? 
          self.open_access == 'yes' ? false : true
        else
          self.requires_authn
        end
      end
      
      # call-seq:
      #   find(oclc_number) => WorldCat::Discovery::Bib
      # 
      # Returns a Bib resource for the given OCLC number
      #
      # [oclc_number] the WorldCat OCLC number for a bibliographic resource
      def self.list
        list = WorldCat::Discovery::DatabaseList.new
        
        url = "#{Database.production_url}/list"
        response, result = WorldCat::Discovery.get_data(url)

        Spira.repository = RDF::Repository.new.from_rdfxml(response)
        Spira.repository.query(:predicate => RDF.type, :object => DCMITYPE_DATASET).each do |database|
          list << database.subject.as(WorldCat::Discovery::Database)
        end
        
        list
      end
      
      def self.production_url
        "https://beta.worldcat.org/discovery/database"
      end
      
    end
  end
end