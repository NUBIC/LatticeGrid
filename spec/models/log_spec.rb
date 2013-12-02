# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20131121210426
#
# Table name: logs
#
#  action_name     :string(255)
#  activity        :string(255)
#  controller_name :string(255)
#  created_at      :datetime         not null
#  created_ip      :string(255)
#  id              :integer          not null, primary key
#  investigator_id :integer
#  params          :text
#  program_id      :integer
#  updated_at      :datetime         not null
#

require 'spec_helper'

describe Log do

  it { should belong_to(:investigator) }
  it { should belong_to(:organizational_unit) }

  it 'can be instantiated' do
    FactoryGirl.build(:log).should be_an_instance_of(Log)
  end

  it 'can be saved successfully' do
    FactoryGirl.create(:log).should be_persisted
  end
end
