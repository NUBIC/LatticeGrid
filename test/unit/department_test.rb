# == Schema Information
# Schema version: 20131121210426
#
# Table name: organizational_units
#
#  abbreviation                :string(255)
#  appointment_count           :integer          default(0)
#  campus                      :string(255)
#  children_count              :integer          default(0)
#  created_at                  :timestamp
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
#  updated_at                  :timestamp
#

require 'test_helper'

class DepartmentTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
