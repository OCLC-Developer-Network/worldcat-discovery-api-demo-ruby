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
    # [actors] RDF predicate: http://schema.org/actor; returns: Enumerable of WorldCat::Discovery::Person objects
    # [director] RDF predicate: http://schema.org/director; returns: WorldCat::Discovery::Person object
    # [producers] RDF predicate: http://schema.org/producer; returns: Enumerable of WorldCat::Discovery::Person objects
    # [musicBy] RDF predicate: http://schema.org/musicBy; returns: Enumerable of WorldCat::Discovery::Person objects
    # [productionCompany] RDF predicate: http://schema.org/productionCompany; returns: WorldCat::Discovery::Organization object
    
    class Movie < Bib
      
      has_many :actors, :predicate => SCHEMA_ACTOR, :type => 'Person'
      property :director, :predicate => SCHEMA_DIRECTOR, :type => 'Person'
      has_many :producers, :predicate => SCHEMA_PRODUCER, :type => 'Person'
      property :musicBy, :predicate => SCHEMA_MUSICBY, :type => 'Person'
      property :productionCompany, :predicate => SCHEMA_PRODUCTIONCOMPANY, :type => 'Organization'
      
    end
  end
end