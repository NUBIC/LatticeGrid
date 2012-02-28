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
