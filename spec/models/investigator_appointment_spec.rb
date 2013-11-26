require 'spec_helper'

describe InvestigatorAppointment do

  it { should belong_to(:investigator) }
  it { should belong_to(:organizational_unit) }
  it { should belong_to(:center) }
  it { should have_many(:investigator_abstracts).through(:investigator) }

  it 'can be instantiated' do
    FactoryGirl.build(:investigator_appointment).should be_an_instance_of(InvestigatorAppointment)
  end
end

describe Member do
  context 'subclasses of InvestigatorAppointment' do
    it 'can be saved successfully' do
      FactoryGirl.create(:member).should be_persisted
    end
  end
end
