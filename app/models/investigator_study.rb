# == Schema Information
# Schema version: 20131121210426
#
# Table name: investigator_studies
#
#  approval_date   :date
#  completion_date :date
#  consent_role    :string(255)
#  created_at      :timestamp        not null
#  id              :integer          default(0), not null, primary key
#  investigator_id :integer          not null
#  role            :string(255)
#  status          :string(255)
#  study_id        :integer          not null
#  updated_at      :timestamp        not null
#

class InvestigatorStudy < ActiveRecord::Base
  belongs_to :investigator
  belongs_to :study
  scope :by_role, joins(:study).order('investigator_studies.role DESC')
  scope :distinct_roles, order('role').select('role, count(*) as count').group('role')
  scope :pis, joins(:investigator).where("role = 'PI'")
end
