require 'spec_helper'

describe Abstract do
  it 'can be instantiated' do
    FactoryGirl.build(:abstract).should be_an_instance_of(Abstract)
  end

  it 'can be saved successfully' do
    FactoryGirl.create(:abstract).should be_persisted
  end
end
