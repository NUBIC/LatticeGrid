require "migration_helper"
class AddHighImpactJournals < ActiveRecord::Migration
  extend MigrationHelper
  def self.up
    add_column :journals, :include_as_high_impact, :boolean, :default => false, :null => false

#  can't do this as issn is not unique
#    add_foreign_key(:journals, :issn, :abstracts, :column_name=>"issn")
  end

  def self.down
    remove_column :journals, :include_as_high_impact
#    drop_foreign_key(:journals, :issn, :abstracts, :column_name=>"issn")
  end
end
