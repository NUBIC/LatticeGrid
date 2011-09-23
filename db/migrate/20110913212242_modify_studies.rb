require "migration_helper"
class ModifyStudies < ActiveRecord::Migration
  extend MigrationHelper
  def self.up
    add_column :studies, :enotis_study_id, :integer
    add_column :studies, :irb_study_number, :string
    add_column :studies, :research_type, :string
    add_column :studies, :review_type, :string
    add_column :studies, :proposal_id, :integer
    add_column :studies, :is_clinical_trial, :boolean, :default => false, :null => false
    add_column :studies, :inclusion_criteria, :text
    add_column :studies, :exclusion_criteria, :text
    add_column :studies, :has_medical_services, :boolean, :default => false, :null => false
    add_column :studies, :had_import_errors, :boolean, :default => false
    add_column :studies, :next_review_date, :date
    add_column :investigator_studies, :consent_role, :string
    add_column :investigators, :total_studies, :integer, :default => 0, :null => false
    add_column :investigators, :total_studies_collaborators, :integer, :default => 0, :null => false
    add_column :investigators, :total_pi_studies, :integer, :default => 0, :null => false
    add_column :investigators, :total_pi_studies_collaborators, :integer, :default => 0, :null => false
    add_column :investigators, :total_awards, :integer, :default => 0, :null => false
    add_column :investigators, :total_awards_collaborators, :integer, :default => 0, :null => false
    add_column :investigators, :total_pi_awards, :integer, :default => 0, :null => false
    add_column :investigators, :total_pi_awards_collaborators, :integer, :default => 0, :null => false
    add_column :investigators, :home_department_name, :string
    rename_column :investigators, :total_pubs_last_five_years, :total_publications_last_five_years
    rename_column :investigators, :total_pubs, :total_publications
    
 
    add_foreign_key(:proposals, :id, :studies)

    remove_column :studies, :is_awarded 
    remove_column :studies, :award_mechanism

    rename_column :studies, :approval_date, :approved_date
    rename_column :studies, :closure_date, :closed_date
    rename_column :studies, :completion_date, :completed_date
    add_index(:studies, [:enotis_study_id], :unique=>true, :name => 'study_by_enotis_study_id_uq')
    add_index(:studies, [:irb_study_number], :unique=>true, :name => 'study_by_irb_study_number_uq')
  end

  def self.down
    drop_foreign_key(:proposals, :id, :studies)
    remove_column :studies, :enotis_study_id
    remove_column :studies, :irb_study_number
    remove_column :studies, :research_type
    remove_column :studies, :review_type
    remove_column :studies, :proposal_id
    remove_column :studies, :is_clinical_trial
    remove_column :studies, :inclusion_criteria
    remove_column :studies, :exclusion_criteria
    remove_column :studies, :has_medical_services
    remove_column :studies, :had_import_errors
    remove_column :studies, :next_review_date
    remove_column :investigator_studies, :consent_role
    add_column :studies, :is_awarded, :boolean, :default => false 
    add_column :studies, :award_mechanism, :string # R01, U01, K01

    remove_column :investigators, :total_studies
    remove_column :investigators, :total_studies_collaborators
    remove_column :investigators, :total_pi_studies
    remove_column :investigators, :total_pi_studies_collaborators
    remove_column :investigators, :total_awards
    remove_column :investigators, :total_awards_collaborators
    remove_column :investigators, :total_pi_awards
    remove_column :investigators, :total_pi_awards_collaborators
    remove_column :investigators, :home_department_name
    rename_column :investigators, :total_publications_last_five_years, :total_pubs_last_five_years
    rename_column :investigators, :total_publications, :total_pubs

    rename_column :studies, :approved_date, :approval_date
    rename_column :studies, :closed_date, :closure_date
    rename_column :studies, :completed_date, :completion_date
    remove_index :studies, [:enotis_study_id] 
    remove_index :studies, [:irb_study_number]
  end
end
