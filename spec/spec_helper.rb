require "rubygems"
require "bundler/setup"
require "rake"
require "rspec"
require "rspec/its"

require "neo4j"
require 'neo4j/core/cypher_session/adaptors/bolt'
require 'dirty_cleaner'
require 'neo4j_fake_migration'

require "carrierwave"
require "carrierwave/neo4j"

def file_path(*paths)
  File.expand_path(File.join(File.dirname(__FILE__), "fixtures", *paths))
end

def public_path(*paths)
  File.expand_path(File.join(File.dirname(__FILE__), "public", *paths))
end

def tmp_path( *paths )
  File.expand_path(File.join(File.dirname(__FILE__), 'public/uploads/tmp', *paths))
end

CarrierWave.root = public_path
# DatabaseCleaner[:neo4j, connection: {type: :bolt, path: 'bolt://localhost:7003'}].strategy = :transaction

neo4j_adaptor = Neo4j::Core::CypherSession::Adaptors::Bolt.new('bolt://localhost:7003', {ssl: false})
Neo4j::ActiveBase.on_establish_session { Neo4j::Core::CypherSession.new(neo4j_adaptor) }

cleaner = DirtyCleaner.new

RSpec.configure do |config|
  config.before(:each) do
    cleaner.avoid_validation do 
      cleaner.clean
      Neo4jFakeMigration.create.migrate(:up)
    end
  end

  config.after(:each) do
    cleaner.avoid_validation { cleaner.clean }
  end
end

