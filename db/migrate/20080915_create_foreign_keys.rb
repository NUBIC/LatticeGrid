require "migration_helper"

class CreateForeignKeys < ActiveRecord::Migration
  extend MigrationHelper
  def self.up
    begin
      #add_foreign_key (:mainentity, :mainentity_id, secundaryentity)
      add_foreign_key(:investigators, :id, :investigator_abstracts)
      add_foreign_key(:abstracts, :id, :investigator_abstracts)
    rescue
      puts "unable to add investigator_abstracts foreign keys. Probably already exist"
    end
    begin
       add_foreign_key(:investigators, :id, :investigator_programs)
      add_foreign_key(:programs, :id, :investigator_programs)
    rescue
      puts "unable to add investigator_programs foreign keys. Probably already exist"
    end
    begin
      add_foreign_key(:programs, :id, :program_abstracts)
      add_foreign_key(:abstracts, :id, :program_abstracts)
    rescue
      puts "unable to add program_abstracts foreign keys. Probably already exist"
    end
  end

  def self.down
    begin
      drop_foreign_key(:investigators, :id, :investigator_abstracts)
      drop_foreign_key(:abstracts, :id, :investigator_abstracts)
    rescue
      puts "unable to drop investigator_abstracts foreign keys. Probably doesn't exist"
    end
    begin
      drop_foreign_key(:investigators, :id, :investigator_programs)
      drop_foreign_key(:programs, :id, :investigator_programs)
    rescue
      puts "unable to drop investigator_programs foreign keys. Probably doesn't exist"
    end
    begin
      drop_foreign_key(:programs, :id, :program_abstracts)
      drop_foreign_key(:abstracts, :id, :program_abstracts)
    rescue
      puts "unable to drop program_abstracts foreign keys. Probably doesn't exist"
    end
  end
end
