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
    # [music_by] RDF predicate: http://schema.org/musicBy; returns: WorldCat::Discovery::Person object
    # [by_artists] RDF predicate: http://schema.org/byArtists; returns: Enumerable of WorldCat::Discovery::Person objects
    # [performers] RDF predicate: http://schema.org/performer; returns: Enumerable of WorldCat::Discovery::Person objects
    # [publishers] RDF predicate: http://schema.org/publisher; returns: Enumerable of WorldCat::Discovery::Organization objects
    # [parts] RDF predicate: http://schema.org/hasPart; returns: Enumerable of WorldCat::Discovery::Bib objects
    # [see_alsos] RDF predicate: http://www.w3.org/2000/01/rdf-schema#seeAlso; returns: Enumerable of WorldCat::Discovery::Bib objects
    
    class MusicAlbum < Bib
      
      property :music_by, :predicate => SCHEMA_MUSICBY, :type => 'Person'
      property :composer, :predicate => SCHEMA_COMPOSER, :type => 'Person'
      has_many :by_artists, :predicate => SCHEMA_BY_ARTIST, :type => 'Person'
      has_many :performers, :predicate => SCHEMA_PERFORMER, :type => 'Person'
      has_many :publishers, :predicate => SCHEMA_PUBLISHER, :type => 'Organization'
      has_many :parts, :predicate => SCHEMA_HAS_PART, :type => 'Bib'
      has_many :see_alsos, :predicate => RDF_SEE_ALSO, :type => 'Bib'
      
      # call-seq:
      #   format() => WorldCat::Discovery::Person or WorldCat::Discovery::Organization
      # 
      # Returns Format based on RDF predicate: http://www.w3.org/TR/rdf-schema/#ch_type limited to the bibliograph.net domain
      def format
        self.types.select {|i| i.host.match("bibliograph.net")}
      end
      
      def performers
        performers = Spira.repository.query(:subject => self.id, :predicate => SCHEMA_PERFORMER)

        performers.map { |performer|
          performer_type = Spira.repository.query(:subject => performer.object, :predicate => RDF.type).first
          case performer_type.object
          when SCHEMA_PERSON then performer.object.as(Person)
          when SCHEMA_ORGANIZATION then performer.object.as(Organization)
          else nil
          end
        }  
      end
      
    end
  end
end