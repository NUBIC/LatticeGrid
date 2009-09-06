class InvestigatorAppointment < ActiveRecord::Base
  belongs_to :investigator
  belongs_to :organizational_unit
  belongs_to :center, :foreign_key => :organizational_unit_id
  belongs_to :organizational_unit
  has_many :investigator_abstracts, :through => :investigator 
  validates_uniqueness_of :investigator_id, :scope => [:organizational_unit_id, :type]


  def self.has_appointment(unit_id ) 
    appointments = self.find :all, 
         :conditions => ['organizational_unit_id = :unit_id  and (end_date is null or end_date >= :now) ',
         {:now => Date.today, :unit_id => unit_id }] 
    return appointments.length > 0
  end 

end
