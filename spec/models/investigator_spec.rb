require 'spec_helper'

describe Investigator do

  it { should belong_to(:home_department) }

  it { should have_many(:logs) }

  # studies
  it { should have_many(:investigator_studies) }
  it { should have_many(:studies).through(:investigator_studies) }
  it { should have_many(:investigator_pi_studies) }

  # proposals
  it { should have_many(:investigator_proposals) }
  it { should have_many(:proposals).through(:investigator_proposals) }
  it { should have_many(:current_proposals).through(:investigator_proposals) }
  it { should have_many(:investigator_pi_proposals) }
  it { should have_many(:pi_proposals).through(:investigator_pi_proposals) }
  it { should have_many(:current_pi_proposals).through(:investigator_pi_proposals) }
  it { should have_many(:investigator_nonpi_proposals) }
  it { should have_many(:nonpi_proposals).through(:investigator_nonpi_proposals) }
  it { should have_many(:current_nonpi_proposals).through(:investigator_nonpi_proposals) }

  # abstracts
  it { should have_many(:investigator_abstracts) }
  it { should have_many(:abstracts).through(:investigator_abstracts) }

  # colleagues
  it { should have_many(:investigator_colleagues) }
  it { should have_many(:colleague_investigators) }
  it { should have_many(:similar_investigators) }
  it { should have_many(:all_similar_investigators) }
  it { should have_many(:co_authors) }
  it { should have_many(:colleagues).through(:investigator_colleagues) }

  # appointments
  it { should have_many(:investigator_appointments) }
  it { should have_many(:all_investigator_appointments) }
  it { should have_many(:joints) }
  it { should have_many(:secondaries) }
  it { should have_many(:member_appointments) }
  it { should have_many(:only_member_appointments) }
  it { should have_many(:associate_member_appointments) }
  it { should have_many(:any_members) }
  it { should have_many(:appointments).through(:investigator_appointments) }
  it { should have_many(:joint_appointments).through(:joints) }
  it { should have_many(:secondary_appointments).through(:secondaries) }
  it { should have_many(:memberships).through(:member_appointments) }
  it { should have_many(:any_memberships).through(:any_members) }
  it { should have_many(:associate_memberships).through(:associate_member_appointments) }

  it 'can be instantiated' do
    FactoryGirl.build(:investigator).should be_an_instance_of(Investigator)
  end

  it 'can be saved successfully' do
    FactoryGirl.create(:investigator).should be_persisted
  end

  it { should validate_presence_of(:username) }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  # TODO: test this but first and last name are required
  # it { should validate_uniqueness_of(:username) }
end

