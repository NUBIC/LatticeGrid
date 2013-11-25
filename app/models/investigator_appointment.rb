# == Schema Information
# Schema version: 20131121210426
#
# Table name: investigator_appointments
#
#  created_at             :timestamp        not null
#  end_date               :date
#  id                     :integer          default(0), not null, primary key
#  investigator_id        :integer          not null
#  organizational_unit_id :integer          not null
#  research_summary       :text
#  start_date             :date
#  type                   :string(255)
#  updated_at             :timestamp        not null
#

class InvestigatorAppointment < ActiveRecord::Base
  belongs_to :investigator
  belongs_to :organizational_unit
  belongs_to :center, :foreign_key => :organizational_unit_id
  #belongs_to :organizational_unit
  has_many :investigator_abstracts, :through => :investigator
  validates_uniqueness_of :investigator_id, :scope => [:organizational_unit_id, :type]

  scope :remove_deleted, where('investigator_appointments.end_date is null')
  scope :only_members, where("investigator_appointments.type = 'Member'")

  def self.has_appointment(unit_id )
    where('investigator_appointments.organizational_unit_id = :unit_id and
           investigator_appointments.end_date is null', { :unit_id => unit_id }).count > 0
  end
end
