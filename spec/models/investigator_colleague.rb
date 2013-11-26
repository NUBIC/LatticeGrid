# -*- coding: utf-8 -*-
require 'spec_helper'

describe InvestigatorColleague do

  it { should belong_to(:investigator) }
  it { should belong_to(:colleague) }

  it 'can be instantiated' do
    FactoryGirl.build(:investigator_colleague).should be_an_instance_of(InvestigatorColleague)
  end

  it 'can be saved successfully' do
    FactoryGirl.create(:investigator_colleague).should be_persisted
  end
end
