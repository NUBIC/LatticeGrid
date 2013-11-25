# == Schema Information
# Schema version: 20131121210426
#
# Table name: organization_abstracts
#
#  abstract_id            :integer          not null
#  created_at             :timestamp        not null
#  end_date               :date
#  id                     :integer          default(0), not null, primary key
#  organizational_unit_id :integer          not null
#  start_date             :date
#  updated_at             :timestamp        not null
#

class OrganizationAbstract < ActiveRecord::Base
  belongs_to :organizational_unit
  belongs_to :abstract
  validates_uniqueness_of :organizational_unit_id, :scope => "abstract_id"
end
