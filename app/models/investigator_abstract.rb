class InvestigatorAbstract < ActiveRecord::Base
  belongs_to :investigator
  belongs_to :abstract
  
  has_many :investigator_appointments, 
    :through => :investigator, 
    :conditions => ['investigator_appointments.end_date is null or investigator_appointments.end_date >= :now', {:now => Date.today }]
  named_scope :first_author_publications, :conditions => ['investigator_abstracts.is_first_author = true and investigator_abstracts.is_valid = true']

  named_scope :last_author_publications, :conditions => ['investigator_abstracts.is_last_author = true and investigator_abstracts.is_valid = true']


  validates_uniqueness_of :investigator_id, :scope => "abstract_id"
  
  named_scope :remove_invalid,  :conditions => 'investigator_abstracts.is_valid = true'
  named_scope :only_valid,  :conditions => 'investigator_abstracts.is_valid = true'
  named_scope :only_invalid,  :conditions => 'investigator_abstracts.is_valid = false'
  named_scope :remove_deleted,  :conditions => 'investigator_abstracts.end_date is null'
  named_scope :only_deleted,  :conditions => 'investigator_abstracts.end_date is not null'
  named_scope :by_range, lambda { |*args| {:conditions => ['investigator_abstracts.publication_date between :start_date and :end_date', 
                {:start_date => args.first, :end_date => args.last} ] }}

end
