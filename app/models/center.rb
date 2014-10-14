# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20141010154909
#
# Table name: organizational_units
#
#  abbreviation                :string(255)
#  appointment_count           :integer          default(0)
#  campus                      :string(255)
#  children_count              :integer          default(0)
#  created_at                  :datetime
#  department_id               :integer          default(0), not null
#  depth                       :integer          default(0)
#  division_id                 :integer          default(0)
#  end_date                    :date
#  id                          :integer          not null, primary key
#  lft                         :integer
#  member_count                :integer          default(0)
#  name                        :string(255)      not null
#  organization_classification :string(255)
#  organization_phone          :string(255)
#  organization_url            :string(255)
#  parent_id                   :integer
#  rgt                         :integer
#  search_name                 :string(255)
#  sort_order                  :integer          default(1)
#  start_date                  :date
#  type                        :string(255)      not null
#  updated_at                  :datetime
#  uuid                        :string(255)
#

class Center < School
  belongs_to :school, :foreign_key => :parent_id
  has_many :programs, :foreign_key => :parent_id
  accepts_nested_attributes_for :programs
end
