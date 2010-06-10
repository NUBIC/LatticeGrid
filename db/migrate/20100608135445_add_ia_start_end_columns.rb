class AddIaStartEndColumns < ActiveRecord::Migration
  def self.up
	begin
	  add_column :investigator_abstracts, :start_date, :date
	  add_column :investigator_abstracts, :end_date, :date
	rescue  Exception => error
	  puts "start_date and end_date already in investigator_abstracts"
	end
  end

  def self.down
    # don't remove these 
    #remove_column :investigator_abstracts, :start_date
    #remove_column :investigator_abstracts, :end_date
  end
end
