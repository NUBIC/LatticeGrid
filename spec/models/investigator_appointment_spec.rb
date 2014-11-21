# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20141010154909
#
# Table name: investigator_appointments
#
#  created_at             :datetime
#  end_date               :date
#  id                     :integer          not null, primary key
#  investigator_id        :integer          not null
#  organizational_unit_id :integer          not null
#  research_summary       :text
#  start_date             :date
#  type                   :string(255)
#  updated_at             :datetime
#  uuid                   :string(255)
#

require 'spec_helper'

describe InvestigatorAppointment do

  it { should belong_to(:investigator) }
  it { should belong_to(:organizational_unit) }
  it { should belong_to(:center) }
  it { should have_many(:investigator_abstracts).through(:investigator) }

  it 'can be instantiated' do
    FactoryGirl.build(:investigator_appointment).should be_an_instance_of(InvestigatorAppointment)
  end

  describe '.has_appointment' do
    let(:ou) { FactoryGirl.create(:organizational_unit) }
    let!(:ia) { FactoryGirl.create(:investigator_appointment, organizational_unit: ou) }
    describe 'when investigator appointment organizational_unit id matches parameter' do
      it 'returns true' do
        InvestigatorAppointment.has_appointment(ou.id).should be_true
      end
    end

    describe 'when investigator appointment organizational_unit id does not match parameter' do
      it 'returns false' do
        InvestigatorAppointment.has_appointment(666).should be_false
      end
    end
  end

end

describe AssociateMember do
  context 'subclasses of InvestigatorAppointment' do
    it 'can be saved successfully' do
      FactoryGirl.create(:associate_member).should be_persisted
    end
  end
end

describe Joint do
  context 'subclasses of InvestigatorAppointment' do
    it 'can be saved successfully' do
      FactoryGirl.create(:joint).should be_persisted
    end
  end
end

describe Member do
  context 'subclasses of InvestigatorAppointment' do
    it 'can be saved successfully' do
      FactoryGirl.create(:member).should be_persisted
    end
  end
end

describe PrimaryMember do
  context 'subclasses of InvestigatorAppointment' do
    it 'can be saved successfully' do
      FactoryGirl.create(:primary_member).should be_persisted
    end
  end
end

describe PrimaryAssociateMember do
  context 'subclasses of InvestigatorAppointment' do
    it 'can be saved successfully' do
      FactoryGirl.create(:primary_associate_member).should be_persisted
    end
  end
end

describe Secondary do
  context 'subclasses of InvestigatorAppointment' do
    it 'can be saved successfully' do
      FactoryGirl.create(:secondary).should be_persisted
    end
  end
end

describe SecondaryMember do
  context 'subclasses of InvestigatorAppointment' do
    it 'can be saved successfully' do
      FactoryGirl.create(:secondary_member).should be_persisted
    end
  end
end

describe SecondaryAssociateMember do
  context 'subclasses of InvestigatorAppointment' do
    it 'can be saved successfully' do
      FactoryGirl.create(:secondary_associate_member).should be_persisted
    end
  end
end

describe TertiaryMember do
  context 'subclasses of InvestigatorAppointment' do
    it 'can be saved successfully' do
      FactoryGirl.create(:tertiary_member).should be_persisted
    end
  end
end

describe TertiaryAssociateMember do
  context 'subclasses of InvestigatorAppointment' do
    it 'can be saved successfully' do
      FactoryGirl.create(:tertiary_associate_member).should be_persisted
    end
  end
end
