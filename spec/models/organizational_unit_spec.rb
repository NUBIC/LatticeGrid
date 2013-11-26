# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20131121210426
#
# Table name: organizational_units
#
#  abbreviation                :string(255)
#  appointment_count           :integer          default(0)
#  campus                      :string(255)
#  children_count              :integer          default(0)
#  created_at                  :datetime         not null
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
#  updated_at                  :datetime         not null
#

require 'spec_helper'

describe OrganizationalUnit do
  it 'can be instantiated' do
    FactoryGirl.build(:organizational_unit).should be_an_instance_of(OrganizationalUnit)
  end
end

describe Center do
  it { should belong_to(:school) }
  it { should have_many(:programs) }
end

describe Department do
  it { should belong_to(:school) }
  it { should have_many(:divisions) }
end

describe Division do
  context 'subclasses of OrganizationalUnit' do
    it 'can be saved successfully' do
      FactoryGirl.create(:division).should be_persisted
    end
  end
end

describe Program do
  context 'subclasses of OrganizationalUnit' do
    it 'can be saved successfully' do
      FactoryGirl.create(:program).should be_persisted
    end
  end
end

describe School do
  context 'subclasses of OrganizationalUnit' do
    it 'can be saved successfully' do
      FactoryGirl.create(:school).should be_persisted
    end
  end
end
