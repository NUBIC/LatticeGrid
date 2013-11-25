# == Schema Information
# Schema version: 20131121210426
#
# Table name: investigator_proposals
#
#  created_at      :timestamp        not null
#  id              :integer          default(0), not null, primary key
#  investigator_id :integer          not null
#  is_main_pi      :boolean          default(FALSE), not null
#  percent_effort  :integer          default(0)
#  proposal_id     :integer          not null
#  role            :string(255)
#  updated_at      :timestamp        not null
#

class InvestigatorProposal < ActiveRecord::Base
  belongs_to :investigator
  belongs_to :proposal
  scope :by_role, joins(:proposal).order('investigator_proposals.role DESC, proposals.project_end_date DESC')
  scope :distinct_roles, select('investigator_proposals.role, count(*) as count').order('role').group('investigator_proposals.role')
  scope :pis, where("investigator_proposals.role = 'PD/PI'")
end
