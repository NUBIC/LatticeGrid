require "migration_helper"
class CreateInvestigatorRelationships < ActiveRecord::Migration
  extend MigrationHelper
  def self.up
    create_table :investigator_relationships do |t|
      t.column :investigator_id, :integer
      t.column :colleague_id, :integer
      t.column :mesh_tags_cnt, :integer   #number of tags in common
      t.column :mesh_tags_ic, :float   #information content of the tags in common
      t.column :publication_cnt, :integer, :default => 0 
      t.column :publication_list, :text
      t.column :in_same_program, :boolean, :default => false 
      t.column :proposal_cnt, :integer, :default => 0 
      t.column :proposal_list, :text
      t.column :study_cnt, :integer, :default => 0
      t.column :study_list, :text
      
      t.timestamps
    end
    add_foreign_key(:investigators, :id, :investigator_relationships, :column_name=>'colleague_id')
    add_foreign_key(:investigators, :id, :investigator_relationships)
    add_index(:investigator_relationships, [:colleague_id, :publication_cnt], :name => 'by_colleague_pubs')
  end

  def self.down
    drop_foreign_key(:investigators, :id, :investigator_relationships, :column_name=>'colleague_id')
    drop_foreign_key(:investigators, :id, :investigator_relationships)
    drop_table :investigator_relationships
  end
end

# this is necessary for the co-author and similarity searches
# CREATE  INDEX by_colleague_pubs ON investigator_relationships(colleague_id, publication_cnt)