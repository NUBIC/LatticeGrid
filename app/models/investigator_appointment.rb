# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20141010154909
#
# Table name: investigator_appointments
#
#  created_at             :datetime
#  end_date               :date
#  id                     :integer          not null, primary key
#  investigator_id        :integer          not null
#  organizational_unit_id :integer          not null
#  research_summary       :text
#  start_date             :date
#  type                   :string(255)
#  updated_at             :datetime
#  uuid                   :string(255)
#

class InvestigatorAppointment < ActiveRecord::Base
  belongs_to :investigator
  belongs_to :organizational_unit
  belongs_to :center, :foreign_key => :organizational_unit_id
  has_many :investigator_abstracts, :through => :investigator
  validates_uniqueness_of :investigator_id, :scope => [:organizational_unit_id, :type]

  scope :remove_deleted, where('investigator_appointments.end_date is null')
  scope :only_members, where("investigator_appointments.type = 'Member'")

  before_save :set_uuid

  ##
  # Set the uuid value to a unique UUID if not yet set
  require 'securerandom'
  def set_uuid
    self.uuid = SecureRandom.hex(5) if uuid.blank?
  end

  def investigator_uuid
    investigator.uuid
  end

  def organizational_unit_uuid
    organizational_unit.uuid
  end

  def self.has_appointment(unit_id )
    where('investigator_appointments.organizational_unit_id = :unit_id and
           investigator_appointments.end_date is null', { :unit_id => unit_id }).count > 0
  end
end
