# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20131121210426
#
# Table name: investigator_studies
#
#  approval_date   :date
#  completion_date :date
#  consent_role    :string(255)
#  created_at      :datetime         not null
#  id              :integer          not null, primary key
#  investigator_id :integer          not null
#  role            :string(255)
#  status          :string(255)
#  study_id        :integer          not null
#  updated_at      :datetime         not null
#

require 'spec_helper'

describe InvestigatorStudy do

  it { should belong_to(:investigator) }
  it { should belong_to(:study) }

  it 'can be instantiated' do
    FactoryGirl.build(:investigator_study).should be_an_instance_of(InvestigatorStudy)
  end

  it 'can be saved successfully' do
    FactoryGirl.create(:investigator_study).should be_persisted
  end
end
