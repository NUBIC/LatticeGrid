class InvestigatorAbstract < ActiveRecord::Base
  belongs_to :investigator
  belongs_to :abstract,
    :conditions => ['investigator_abstracts.end_date is null or investigator_abstracts.end_date >= :now', {:now => Date.today }]
  
  has_many :investigator_appointments, 
    :through => :investigator, 
    :conditions => ['investigator_appointments.end_date is null or investigator_appointments.end_date >= :now', {:now => Date.today }]
  named_scope :first_author_publications, :conditions => ['investigator_abstracts.is_first_author = true and investigator_abstracts.end_date is null']

  named_scope :last_author_publications, :conditions => ['investigator_abstracts.is_last_author = true and investigator_abstracts.end_date is null']


  validates_uniqueness_of :investigator_id, :scope => "abstract_id"
  
  named_scope :remove_deleted,  :conditions => 'investigator_abstracts.end_date is null'
    
end
