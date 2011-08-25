class AddNewInvestigatorProposalColumns < ActiveRecord::Migration
   def self.up
     add_column :investigator_proposals, :is_main_pi, :boolean, :default => false, :null => false
     add_column :proposals, :original_sponsor_name, :string
     add_column :proposals, :original_sponsor_code, :string
     add_column :proposals, :pi_employee_id, :string
   end

   def self.down
     remove_column :investigator_proposals, :is_main_pi 
     remove_column :proposals, :original_sponsor_name 
     remove_column :proposals, :original_sponsor_code 
     remove_column :proposals, :pi_employee_id 
  end
end
