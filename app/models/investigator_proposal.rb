# == Schema Information
# Schema version: 20130327155943
#
# Table name: investigator_proposals
#
#  created_at      :timestamp
#  id              :integer          default(0), not null, primary key
#  investigator_id :integer          not null
#  is_main_pi      :boolean          default(FALSE), not null
#  percent_effort  :integer          default(0)
#  proposal_id     :integer          not null
#  role            :string(255)
#  updated_at      :timestamp
#

class InvestigatorProposal < ActiveRecord::Base
  belongs_to :investigator
  belongs_to :proposal
  named_scope :by_role, 
    :order => "investigator_proposals.role DESC, proposals.project_end_date DESC", :joins => :proposal
  named_scope :distinct_roles, 
    :order => "role", :select => 'investigator_proposals.role, count(*) as count', :group => 'investigator_proposals.role'
  named_scope :pis, 
    :conditions=>"investigator_proposals.role = 'PD/PI'"
  
end
