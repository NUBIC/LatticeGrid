# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20131121210426
#
# Table name: investigators
#
#  address1                                    :text
#  address2                                    :string(255)
#  appointment_basis                           :string(255)
#  appointment_track                           :string(255)
#  appointment_type                            :string(255)
#  birth_date                                  :date
#  business_phone                              :string(255)
#  campus                                      :string(255)
#  city                                        :string(255)
#  consecutive_login_failures                  :integer          default(0)
#  country                                     :string(255)
#  created_at                                  :datetime         not null
#  created_id                                  :integer
#  created_ip                                  :string(255)
#  degrees                                     :string(255)
#  deleted_at                                  :datetime
#  deleted_id                                  :integer
#  deleted_ip                                  :string(255)
#  email                                       :string(255)
#  employee_id                                 :integer
#  end_date                                    :date
#  era_comons_name                             :string(255)
#  faculty_interests                           :text
#  faculty_keywords                            :text
#  faculty_research_summary                    :text
#  fax                                         :string(255)
#  first_name                                  :string(255)      not null
#  home_department_id                          :integer
#  home_department_name                        :string(255)
#  home_phone                                  :string(255)
#  id                                          :integer          not null, primary key
#  lab_phone                                   :string(255)
#  last_login_failure                          :datetime
#  last_name                                   :string(255)      not null
#  last_pubmed_search                          :date
#  last_successful_login                       :datetime
#  mailcode                                    :string(255)
#  middle_name                                 :string(255)
#  nu_start_date                               :date
#  num_extraunit_collaborators                 :integer          default(0)
#  num_extraunit_collaborators_last_five_years :integer          default(0)
#  num_first_pubs                              :integer          default(0)
#  num_first_pubs_last_five_years              :integer          default(0)
#  num_intraunit_collaborators                 :integer          default(0)
#  num_intraunit_collaborators_last_five_years :integer          default(0)
#  num_last_pubs                               :integer          default(0)
#  num_last_pubs_last_five_years               :integer          default(0)
#  pager                                       :string(255)
#  password                                    :string(255)
#  password_changed_at                         :datetime
#  password_changed_id                         :integer
#  password_changed_ip                         :string(255)
#  postal_code                                 :string(255)
#  pubmed_limit_to_institution                 :boolean          default(FALSE)
#  pubmed_search_name                          :string(255)
#  sex                                         :string(1)
#  ssn                                         :string(9)
#  start_date                                  :date
#  state                                       :string(255)
#  suffix                                      :string(255)
#  title                                       :string(255)
#  total_awards                                :integer          default(0), not null
#  total_awards_collaborators                  :integer          default(0), not null
#  total_pi_awards                             :integer          default(0), not null
#  total_pi_awards_collaborators               :integer          default(0), not null
#  total_pi_studies                            :integer          default(0), not null
#  total_pi_studies_collaborators              :integer          default(0), not null
#  total_publications                          :integer          default(0)
#  total_publications_last_five_years          :integer          default(0)
#  total_studies                               :integer          default(0), not null
#  total_studies_collaborators                 :integer          default(0), not null
#  updated_at                                  :datetime         not null
#  updated_id                                  :integer
#  updated_ip                                  :string(255)
#  username                                    :string(255)      not null
#  vectors                                     :text
#  weekly_hours_min                            :integer          default(35)
#

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

