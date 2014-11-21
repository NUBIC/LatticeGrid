# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20141010154909
#
# Table name: organization_abstracts
#
#  abstract_id            :integer          not null
#  created_at             :datetime
#  end_date               :date
#  id                     :integer          not null, primary key
#  organizational_unit_id :integer          not null
#  start_date             :date
#  updated_at             :datetime
#

require 'spec_helper'

describe OrganizationAbstract do

  it { should belong_to(:organizational_unit) }
  it { should belong_to(:abstract) }

  it 'can be instantiated' do
    FactoryGirl.build(:organization_abstract).should be_an_instance_of(OrganizationAbstract)
  end

  it 'can be saved successfully' do
    FactoryGirl.create(:organization_abstract).should be_persisted
  end
end
