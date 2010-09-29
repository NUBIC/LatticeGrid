class InvestigatorAbstract < ActiveRecord::Base
  belongs_to :investigator
  belongs_to :abstract,
    :conditions => ['investigator_abstracts.end_date is null or investigator_abstracts.end_date >= :now', {:now => Date.today }]
  
  has_many :investigator_appointments, 
    :through => :investigator, 
    :conditions => ['investigator_appointments.end_date is null or investigator_appointments.end_date >= :now', {:now => Date.today }]
  validates_uniqueness_of :investigator_id, :scope => "abstract_id"
  
  named_scope :remove_deleted,  :conditions => 'investigator_abstracts.end_date is null'
    
end
