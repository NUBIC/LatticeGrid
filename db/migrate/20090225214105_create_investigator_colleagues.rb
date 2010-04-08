require "migration_helper"
class CreateInvestigatorColleagues < ActiveRecord::Migration
  extend MigrationHelper
  def self.up
    create_table :investigator_colleagues do |t|
      t.column :investigator_id, :integer
      t.column :colleague_id, :integer
      t.column :mesh_tags_cnt, :integer, :default => 0   #number of tags in common
      t.column :mesh_tags_ic, :float, :default => 0.0   #information content of the tags in common
      t.column :tag_list, :text
      t.column :publication_cnt, :integer, :default => 0 
      t.column :publication_list, :text
      t.column :in_same_program, :boolean, :default => false 
      t.column :proposal_cnt, :integer, :default => 0 
      t.column :proposal_list, :text
      t.column :study_cnt, :integer, :default => 0
      t.column :study_list, :text
      
      t.timestamps
    end
    add_foreign_key(:investigators, :id, :investigator_colleagues, :column_name=>'colleague_id')
    add_foreign_key(:investigators, :id, :investigator_colleagues)
    add_index(:investigator_colleagues, [:colleague_id, :investigator_id, :publication_cnt], :name => 'by_colleague_pubs')
    add_index(:investigator_colleagues, [:colleague_id, :investigator_id, :mesh_tags_ic], :name => 'by_colleague_mesh_ic')
    add_index(:investigator_colleagues, [:mesh_tags_ic], :name => 'mesh_tags_ic')
    add_index(:investigator_colleagues, [:colleague_id, :investigator_id], :name => 'by_colleague_investigator', :unique => true)
  end

  def self.down
    drop_foreign_key(:investigators, :id, :investigator_colleagues, :column_name=>'colleague_id')
    drop_foreign_key(:investigators, :id, :investigator_colleagues)
    begin
      drop_table :investigator_colleagues
    rescue Exception => error
      puts "unable to drop investigator_colleagues. Probably doesn't exist"
    end
  end
end

# this is necessary for the co-author and similarity searches
# CREATE  INDEX by_colleague_pubs ON investigator_colleagues(colleague_id, publication_cnt)