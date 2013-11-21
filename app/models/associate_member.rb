# == Schema Information
# Schema version: 20131121210426
#
# Table name: investigator_appointments
#
#  created_at             :timestamp
#  end_date               :date
#  id                     :integer          not null, primary key
#  investigator_id        :integer          not null
#  organizational_unit_id :integer          not null
#  research_summary       :text
#  start_date             :date
#  type                   :string(255)
#  updated_at             :timestamp
#

class AssociateMember < Member
end
