require 'spec_helper'

describe Abstract do

  it { should have_many(:journals) }
  it { should have_many(:investigator_abstracts) }
  it { should have_many(:investigators).through(:investigator_abstracts) }
  it { should have_many(:investigator_appointments).through(:investigator_abstracts) }
  it { should have_many(:organization_abstracts) }
  it { should have_many(:organizational_units).through(:organization_abstracts) }

  it 'can be instantiated' do
    FactoryGirl.build(:abstract).should be_an_instance_of(Abstract)
  end

  it 'can be saved successfully' do
    FactoryGirl.create(:abstract).should be_persisted
  end
end
