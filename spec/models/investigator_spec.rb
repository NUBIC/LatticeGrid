require 'spec_helper'

describe Investigator do
  it 'can be instantiated' do
    FactoryGirl.build(:investigator).should be_an_instance_of(Investigator)
  end

  it 'can be saved successfully' do
    FactoryGirl.create(:investigator).should be_persisted
  end
end

