require "migration_helper"

class CreateForeignKeys < ActiveRecord::Migration
  extend MigrationHelper
  def self.up
    begin
      #add_foreign_key (:mainentity, :mainentity_id, secundaryentity)
      add_foreign_key(:investigators, :id, :investigator_abstracts)
      add_foreign_key(:abstracts, :id, :investigator_abstracts)
    rescue Exception => error
      puts "unable to add investigator_abstracts foreign keys. Probably already exist"
    end
    begin
       add_foreign_key(:investigators, :id, :investigator_appointments)
      add_foreign_key(:organizational_units, :id, :investigator_appointments)
    rescue Exception => error
      puts "unable to add investigator_appointments foreign keys. Probably already exist"
    end
    begin
      add_foreign_key(:organizational_units, :id, :organization_abstracts)
      add_foreign_key(:abstracts, :id, :organization_abstracts)
    rescue Exception => error
      puts "unable to add organization_abstracts foreign keys. Probably already exist"
    end
  end

  def self.down
    begin
      drop_foreign_key(:investigators, :id, :investigator_abstracts)
      drop_foreign_key(:abstracts, :id, :investigator_abstracts)
    rescue Exception => error
      puts "unable to drop investigator_abstracts foreign keys. Probably doesn't exist"
    end
    begin
       drop_foreign_key(:investigators, :id, :investigator_appointments)
      drop_foreign_key(:organizational_units, :id, :investigator_appointments)
    rescue Exception => error
      puts "unable to drop investigator_appointments foreign keys. Probably already exist"
    end
    begin
      drop_foreign_key(:organizational_units, :id, :organization_abstracts)
      drop_foreign_key(:abstracts, :id, :organization_abstracts)
    rescue Exception => error
      puts "unable to drop organization_abstracts foreign keys. Probably already exist"
    end
  end
end
