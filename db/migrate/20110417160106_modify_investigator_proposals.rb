class ModifyInvestigatorProposals < ActiveRecord::Migration
  def self.up
    
    remove_column :investigator_proposals, :award_date
    remove_column :investigator_proposals, :submission_date
    remove_column :investigator_proposals, :is_awarded
	  add_column :investigator_proposals, :percent_effort, :integer, :default => 0 

    remove_column :proposals, :award_date
	  add_column :proposals, :award_start_date, :date
	  add_column :proposals, :award_end_date, :date
	  add_column :proposals, :direct_amount, :integer
	  add_column :proposals, :indirect_amount, :integer
	  add_column :proposals, :total_amount, :integer
	  add_column :proposals, :sponsor_type_name, :string
	  add_column :proposals, :sponsor_type_code, :string
  end

  def self.down
    add_column :investigator_proposals, :award_date, :date
    add_column :investigator_proposals, :submission_date, :date
    add_column :investigator_proposals, :is_awarded, :boolean, :default => false
	  remove_column :investigator_proposals, :percent_effort 

    add_column :proposals, :award_date, :date
	  remove_column :proposals, :award_start_date 
	  remove_column :proposals, :award_end_date 
	  remove_column :proposals, :direct_amount
	  remove_column :proposals, :indirect_amount
	  remove_column :proposals, :total_amount
 	  remove_column :proposals, :sponsor_type_name
	  remove_column :proposals, :sponsor_type_code
 end
end
