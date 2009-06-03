require "migration_helper"
class CreateInvestigatorProposals < ActiveRecord::Migration
  extend MigrationHelper
  def self.up
    create_table :investigator_proposals do |t|
      t.column :submission_date, :date # DP: pubmed YYYY/MM/DD
      t.column :award_date, :date # DP: pubmed YYYY/MM/DD
      t.column :is_awarded, :boolean, :default => false 
      t.column :role, :string # PI, co-PI, co-I, O (O is other significant personnel)

      t.timestamps
    end
    add_foreign_key(:investigators, :id, :investigator_proposals, :add_column=>1)
    add_foreign_key(:proposals, :id, :investigator_proposals, :add_column=>1)
  end

  def self.down
    drop_foreign_key(:investigators, :id, :investigator_proposals)
    drop_foreign_key(:proposals, :id, :investigator_proposals)
    drop_table :investigator_proposals
  end
end
