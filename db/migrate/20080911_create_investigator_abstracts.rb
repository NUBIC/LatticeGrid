class CreateInvestigatorAbstracts < ActiveRecord::Migration
  def self.up
    create_table :investigator_abstracts do |t|
      #add_foreign_key (:mainentity, :mainentity_id, secundaryentity)
      #add_foreign_key(:investigators, :id, :investigator_abstracts, :add_column)
      #add_foreign_key(:abstracts, :id, :investigator_abstracts, :add_column)
      t.column :abstract_id, :integer, :null => false  #now in the add_foreign_key call
      t.column :investigator_id, :integer, :null => false  #now in the add_foreign_key call
      t.column :is_first_author, :boolean, :default => false, :null => false
      t.column :is_last_author, :boolean, :default => false, :null => false
      t.timestamps #adds created_at and updated_at
      t.column :start_date, :date
      t.column :end_date, :date
    end
  end

  def self.down
    drop_table :investigator_abstracts
  end
end
