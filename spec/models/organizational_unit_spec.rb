require 'spec_helper'

describe OrganizationalUnit do
  it 'can be instantiated' do
    FactoryGirl.build(:organizational_unit).should be_an_instance_of(OrganizationalUnit)
  end
end

describe School do
  context 'subclasses of OrganizationalUnit' do
    it 'can be saved successfully' do
      FactoryGirl.create(:school).should be_persisted
    end
  end
end
