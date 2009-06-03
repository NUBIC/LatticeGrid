class InvestigatorProgram < ActiveRecord::Base
  belongs_to :investigator
  belongs_to :program
  has_many :investigator_abstracts, :through => :investigator 
  validates_uniqueness_of :investigator_id, :scope => "program_id"


  def self.has_program(program_id ) 
    programs = self.find :all, 
         :conditions => ['program_id = :program_id  and (end_date is null or end_date >= :now) ',
         {:now => Date.today, :program_id => program_id }] 
    return programs.length > 0
  end 

end
