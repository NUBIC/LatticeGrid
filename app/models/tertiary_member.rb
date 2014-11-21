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

class TertiaryMember < Member
end
