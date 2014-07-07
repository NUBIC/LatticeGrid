class AddIsCancerAndPmcColumns < ActiveRecord::Migration
  def self.up
  	begin
  	  add_column :abstracts, :is_cancer, :boolean, :default => true, :null => false
  	  add_column :abstracts, :pubmedcentral, :string, :unique => true
  	  #Abstract.update_all(:is_cancer => true)
      
  	rescue  Exception => error
  	  puts "is_cancer and pubmedcentral already in abstracts?"
  	  puts "error: #{error.message}"
  	end
  end

  def self.down
	  remove_column :abstracts, :is_cancer 
	  remove_column :abstracts, :pubmedcentral
  end
end
