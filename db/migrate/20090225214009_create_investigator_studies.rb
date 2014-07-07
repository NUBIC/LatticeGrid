require "migration_helper"
class CreateInvestigatorStudies < ActiveRecord::Migration
  extend MigrationHelper
  def self.up
    create_table :investigator_studies do |t|
       t.column :status, :string 
      t.column :approval_date, :date # DP: pubmed YYYY/MM/DD
      t.column :completion_date, :date # DP: pubmed YYYY/MM/DD
      t.column :role, :string # PI, co-PI, co-I, Stats, O (O is other significant personnel)

      t.timestamps
    end
    add_foreign_key(:investigators, :id, :investigator_studies, :add_column=>1)
    add_foreign_key(:studies, :id, :investigator_studies, :add_column=>1)
  end

  def self.down
    drop_foreign_key(:investigators, :id, :investigator_studies)
    drop_foreign_key(:studies, :id, :investigator_studies)
    drop_table :investigator_studies
  end
end
