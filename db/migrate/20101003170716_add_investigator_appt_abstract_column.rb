class AddInvestigatorApptAbstractColumn < ActiveRecord::Migration
  def self.up
    begin
      add_column :investigator_appointments, :abstract, :text 
      add_column :investigators, :faculty_keywords, :text 
      add_column :investigators, :faculty_research_summary, :text 
      add_column :investigators, :faculty_interests, :text 
      add_column :investigators, :faculty_clinical_interests, :text 
    rescue  Exception => error
      puts "abstract already in investigator_appointments?"
    end
  end

  def self.down
    remove_column :investigator_appointments, :abstract 
    remove_column :investigators, :faculty_keywords
    remove_column :investigators, :faculty_research_summary
    remove_column :investigators, :faculty_interests
    remove_column :investigators, :faculty_clinical_interests
  end
end
