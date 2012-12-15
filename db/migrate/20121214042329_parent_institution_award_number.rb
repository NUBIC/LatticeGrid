class ParentInstitutionAwardNumber < ActiveRecord::Migration
  def self.up
    add_column :proposals, :parent_institution_award_number, :string
    add_column :proposals, :merged, :boolean, :default => false
  end

  def self.down
	  remove_column :proposals, :parent_institution_award_number 
	  remove_column :proposals, :merged 
  end
end
