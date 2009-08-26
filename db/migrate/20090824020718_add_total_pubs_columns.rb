class AddTotalPubsColumns < ActiveRecord::Migration
  def self.up
    begin
     add_column :investigators, :num_first_pubs, :integer, :default=>0
     add_column :investigators, :num_last_pubs, :integer, :default=>0
     add_column :investigators, :total_pubs, :integer, :default=>0
     add_column :investigators, :num_intraunit_collaborators, :integer, :default=>0
     add_column :investigators, :num_extraunit_collaborators, :integer, :default=>0
     Investigator.update_all("num_first_pubs = 0") 
     Investigator.update_all("num_last_pubs = 0") 
     Investigator.update_all("total_pubs = 0") 
     Investigator.update_all("num_intraunit_collaborators = 0") 
     Investigator.update_all("num_extraunit_collaborators = 0") 
   rescue
     puts "columns probably already added"
   end
  end

  def self.down
    begin
      remove_column :investigators, :num_first_pubs
      remove_column :investigators, :num_last_pubs
      remove_column :investigators, :total_pubs
      remove_column :investigators, :num_intraunit_collaborators
      remove_column :investigators, :num_extraunit_collaborators
    rescue
      puts "columns probably already removed"
    end
  end
end
