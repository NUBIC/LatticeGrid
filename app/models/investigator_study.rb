# == Schema Information
# Schema version: 20130327155943
#
# Table name: investigator_studies
#
#  approval_date   :date
#  completion_date :date
#  consent_role    :string(255)
#  created_at      :timestamp
#  id              :integer          default(0), not null, primary key
#  investigator_id :integer          not null
#  role            :string(255)
#  status          :string(255)
#  study_id        :integer          not null
#  updated_at      :timestamp
#

class InvestigatorStudy < ActiveRecord::Base
  belongs_to :investigator
  belongs_to :study
  named_scope :by_role, 
    :order => "investigator_studies.role DESC", :joins => :study
  named_scope :distinct_roles, 
    :order => "role", :select => 'role, count(*) as count', :group => 'role'
  named_scope :pis, 
    :joins => :investigator,
    :conditions=>"role = 'PI'"
end
