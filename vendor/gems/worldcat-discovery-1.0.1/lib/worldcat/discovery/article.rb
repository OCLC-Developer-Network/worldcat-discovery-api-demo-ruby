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
    # [page_start] RDF predicate: http://schema.org/name; returns: String
    # [page_end] RDF predicate: http://schema.org/name; returns: String
    # [pagination] RDF predicate: http://schema.org/pagination; returns: String
    
    class Article < Bib
      
      property :page_start, :predicate => SCHEMA_PAGE_START, :type => XSD.integer
      property :page_end, :predicate => SCHEMA_PAGE_END, :type => XSD.integer
      property :pagination, :predicate => SCHEMA_PAGINATION, :type => XSD.string
      
      def periodical
        # when article only had a volume
        if self.is_part_of.class == WorldCat::Discovery::PublicationVolume
          self.is_part_of.periodical
        # when article has issue and volume
        elsif self.is_part_of.class == WorldCat::Discovery::PublicationIssue
          self.is_part_of.volume.periodical
        # when the article doesn't have issue or volume
        elsif self.is_part_of.class == WorldCat::Discovery::Periodical
          self.is_part_of  
        else
          nil
        end
      end
      
      def publisher
        # when periodical only had a volume
        if self.is_part_of.class == WorldCat::Discovery::PublicationVolume
          self.is_part_of.periodical.publisher
        # when periodical has issue and volume
        elsif self.is_part_of.class == WorldCat::Discovery::PublicationIssue
          self.is_part_of.volume.periodical.publisher
        # when the article doesn't have issue or volume  
        elsif self.is_part_of.class == WorldCat::Discovery::Periodical
          self.is_part_of.publisher
        else
          nil
        end
      end
     
      def volume
        if self.is_part_of.class == WorldCat::Discovery::PublicationVolume
          self.is_part_of
        #when periodical has volume and issue
        elsif self.is_part_of.class == WorldCat::Discovery::PublicationIssue
          self.is_part_of.volume
        else
          nil
        end
      end
      
      def issue
        if self.is_part_of.class == WorldCat::Discovery::PublicationIssue
          self.is_part_of
        else
          nil
        end
      end
      
      protected
      def is_part_of
      part_of_stmt = Spira.repository.query(:subject => self.id, :predicate => SCHEMA_IS_PART_OF).first

      if part_of_stmt
        part_of_type = Spira.repository.query(:subject => part_of_stmt.object, :predicate => RDF.type).first
        case part_of_type.object
        when SCHEMA_PUBLICATION_ISSUE then part_of_stmt.object.as(PublicationIssue)
        when SCHEMA_PUBLICATION_VOLUME then part_of_stmt.object.as(PublicationVolume)
        when SCHEMA_PERIODICAL then part_of_stmt.object.as(Periodical)
        else nil
        end
      else
        nil
      end
    end
      
    end
  end
end