require 'spec_helper'

describe InvestigatorAbstract do

  it { should belong_to(:investigator) }
  it { should belong_to(:abstract) }
  it { should have_many(:investigator_appointments).through(:investigator) }

  it 'can be instantiated' do
    FactoryGirl.build(:investigator_abstract).should be_an_instance_of(InvestigatorAbstract)
  end

  it 'can be saved successfully' do
    FactoryGirl.create(:investigator_abstract).should be_persisted
  end
end
