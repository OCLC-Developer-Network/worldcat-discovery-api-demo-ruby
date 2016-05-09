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
    # [issue_number] RDF predicate: http:/schema.org/issueNumber; returns: Integer
    # [type] RDF predicate: http://www.w3.org/1999/02/22-rdf-syntax-ns#type; returns: RDF::URI
    # [date_published] RDF predicate: http://schema.org/datePublished; returns: String
    #
    
    class PublicationIssue < Spira::Base
      
      property :issue_number, :predicate => SCHEMA_ISSUE_NUMBER, :type => XSD.integer
      property :type, :predicate => RDF.type, :type => RDF::URI
      property :date_published, :predicate => SCHEMA_DATE_PUBLISHED, :type => XSD.string      
      
      # call-seq:
      #   id() => RDF::URI
      # 
      # Will return the RDF::URI object that serves as the RDF subject of the current Place
      def id
        self.subject
      end
      
      def volume
        part_of_stmt = Spira.repository.query(:subject => self.id, :predicate => SCHEMA_IS_PART_OF).first
        part_of_type = Spira.repository.query(:subject => part_of_stmt.object, :predicate => RDF.type).first
        
        if part_of_type.object == RDF::URI(SCHEMA_PUBLICATION_VOLUME)
          part_of_stmt.object.as(PublicationVolume) 
        else
          nil
        end
        
      end
      
      def periodical
        if self.volume 
          volume = self.volume
          periodical = Spira.repository.query(:subject => volume.id, :predicate => SCHEMA_IS_PART_OF).first
          periodical.object.as(Periodical)
        else
          part_of_stmt = Spira.repository.query(:subject => self.id, :predicate => SCHEMA_IS_PART_OF).first
          part_of_stmt.object.as(Periodical) 
        end 
       
      end

    end
  end
end