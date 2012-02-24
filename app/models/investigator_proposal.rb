class InvestigatorProposal < ActiveRecord::Base
  belongs_to :investigator
  belongs_to :proposal
  named_scope :by_role, 
    :order => "investigator_proposals.role DESC, proposals.project_start_date DESC", :joins => :proposal
  named_scope :distinct_roles, 
    :order => "role", :select => 'investigator_proposals.role, count(*) as count', :group => 'investigator_proposals.role'
  named_scope :pis, 
    :conditions=>"investigator_proposals.role = 'PD/PI'"
  
end
