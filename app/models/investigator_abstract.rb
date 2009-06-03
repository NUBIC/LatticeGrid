class InvestigatorAbstract < ActiveRecord::Base
  belongs_to :investigator
  belongs_to :abstract
  has_many :investigator_programs, 
    :through => :investigator, 
    :conditions => ['investigator_programs.end_date is null or investigator_programs.end_date >= :now', {:now => Date.today }]
  validates_uniqueness_of :investigator_id, :scope => "abstract_id"
end
