class AddInvestigatorApptResearchSummaryColumn < ActiveRecord::Migration
  def self.up
    add_column :investigator_appointments, :research_summary, :text 
    remove_column :investigator_appointments, :abstract 
    remove_column :investigators, :faculty_clinical_interests
  end

  def self.down
    remove_column :investigator_appointments, :research_summary 
    add_column :investigator_appointments, :abstract, :text 
    add_column :investigators, :faculty_clinical_interests, :text 
  end
end
