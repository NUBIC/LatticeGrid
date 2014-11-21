# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20141010154909
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
#  created_at                                  :datetime
#  created_id                                  :integer
#  created_ip                                  :string(255)
#  degrees                                     :string(255)
#  deleted_at                                  :datetime
#  deleted_id                                  :integer
#  deleted_ip                                  :string(255)
#  email                                       :string(255)
#  employee_id                                 :integer
#  end_date                                    :date
#  era_commons_name                            :string(255)
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
#  updated_at                                  :datetime
#  updated_id                                  :integer
#  updated_ip                                  :string(255)
#  username                                    :string(255)      not null
#  uuid                                        :string(255)
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

  context 'with data' do
    before do
      FactoryGirl.create(:investigator)
    end
    let(:pi) { Investigator.first }

    describe '.find_by_username_including_deleted' do
      it 'returns the matching record' do
        pi = Investigator.find_by_username_including_deleted('username')
        pi.should_not be_nil
      end
    end

    describe '.find_by_email_including_deleted' do
      it 'returns the matching record' do
        pi = Investigator.find_by_email_including_deleted('pi@northwestern.edu')
        pi.should_not be_nil
      end
    end

    describe '.include_deleted' do
      it 'returns the matching records' do
        pis = Investigator.include_deleted
        pis.length.should be >= Investigator.count
      end
    end

    describe '.find_purged' do
      it 'returns the matching records' do
        pis = Investigator.find_purged
        pis.should be_empty
        pis.length.should be < Investigator.include_deleted.length
      end
    end

    describe '.find_updated' do
      it 'returns the matching records' do
        pis = Investigator.find_updated
        pis.length.should eq Investigator.count
      end
    end

    describe '.find_not_updated' do
      it 'returns the matching records' do
        pis = Investigator.find_not_updated
        pis.should be_empty
      end
    end

    describe '.has_basis_without_connections' do
      it 'returns the matching records' do
        pis = Investigator.has_basis_without_connections('FT')
        pis.should_not be_empty
      end
    end

    # TODO: test the affirmative matching record - not just the non-matching empty return value
    describe '.has_basis_without_connections' do
      it 'returns the matching records' do
        pis = Investigator.has_basis_without_connections('UNPD')
        pis.should be_empty
      end
    end

    describe '#similar_investigators' do
      it 'returns the matching records' do
        pi.similar_investigators.should be_empty
      end
    end

    describe '.generate_date' do
      it 'sets the cutoff date by default to 5 years' do
        cutoff_date = Investigator.generate_date
        Investigator.generate_date(5).should eq cutoff_date
        Investigator.generate_date(1).should_not eq cutoff_date
      end
    end

    describe '.distinct_primary_appointments' do
      it 'returns the matching records' do
        Investigator.distinct_primary_appointments.length.should be 1
      end
    end

    context 'appointments and membership' do
      describe '#home_department_id' do
        it 'returns the matching records' do
          pi.home_department_id.should be 1
        end
      end
      describe '#investigator_appointments' do
        it 'returns the matching records' do
          pi.investigator_appointments.length.should be >= pi.member_appointments.length
        end
      end
      describe '#memberships' do
        it 'returns the matching records' do
          pi.memberships[0].should eq pi.home_department
        end
      end
      describe '#appointments' do
        it 'returns the matching records' do
          pi.investigator_appointments.length.should eq pi.appointments.length
        end
      end
      describe '#joints' do
        it 'returns the matching records' do
          pi.joints.length.should eq pi.joint_appointments.length
        end
      end
      describe '#secondaries' do
        it 'returns the matching records' do
          pi.secondaries.length.should eq pi.secondary_appointments.length
        end
      end
      describe '#member_appointments' do
        it 'returns the matching records' do
          pi.memberships.length.should eq pi.member_appointments.length
        end
      end
    end

    context 'with abstracts' do
      before do
        FactoryGirl.create(:investigator_abstract, investigator: pi, is_valid: true)
      end
      let(:abstract) { Abstract.first }
      describe '#abstracts' do
        it 'returns the matching records' do
          pi.abstracts.should eq [abstract]
        end
      end
      describe '#abstract_count' do
        it 'returns the count of the matching records' do
          pi.abstract_count.should eq 1
          pi.abstracts.count.should eq pi.abstract_count
        end
      end
      describe '#abstract_last_five_years_count' do
        it 'returns the count of the matching records' do
          last_five_count = pi.abstract_last_five_years_count
          last_five_count.should eq 1
          recent_count = Abstract.investigator_publications(pi.id, 5).length
          last_five_count.should eq recent_count
        end
      end
      describe '.display_all_investigator_data' do
        it 'returns the matching records' do
          abstracts = Abstract.display_all_investigator_data(pi.id)
          abstracts.length.should eq 1
          expect { abstracts.total_entries }.to raise_error(NoMethodError)
        end
      end
      describe '.display_investigator_data' do
        it 'returns the matching records' do
          page = 1
          abstracts = Abstract.display_investigator_data(pi.id, page)
          abstracts.length.should eq 1
          abstracts.total_entries.should_not be_nil
          abstracts.length.should eq abstracts.total_entries
        end
      end
    end

    # TODO: test the affirmative matching record - not just the non-matching empty return value
    describe '.colleague_coauthors' do
      it 'returns the matching records' do
        pi.colleague_coauthors.should be_empty
      end
    end

    # TODO: test the affirmative matching record - not just the non-matching empty return value
    describe '.direct_coauthors' do
      it 'returns the matching records' do
        pi.direct_coauthors.should be_empty
      end
    end

    describe '.find_investigators_in_list' do
      it 'returns the matching records' do
        ["#{pi.id}, 1", "#{pi.email}, asdf@test.com"].each do |list|
          Investigator.find_investigators_in_list(list).length.should eq 1
        end
      end
    end

    context 'tsearch' do
      # Need to create the tsearch vector prior to running tests.
      # Not sure why Investigator.create_vector needs to be run too
      before do
        #doesn't hurt to try, even if it exists
        Abstract.create_vector
        Abstract.update_vector
        #doesn't hurt to try, even if it exists
        Investigator.create_vector
        Investigator.update_vector
      end

      describe '#count_all_tsearch' do
        it 'returns the count of the matching records' do
          Investigator.count_all_tsearch("#{pi.last_name}").should eq 1
        end
      end

      describe '#investigators_tsearch' do
        it 'returns the matching records' do
          Investigator.investigators_tsearch("#{pi.last_name}").should eq [pi]
        end
      end

      describe '#all_tsearch' do
        it 'returns the matching records' do
          Investigator.all_tsearch("#{pi.last_name}").should eq [pi]
        end
      end

      describe '#top_ten_tsearch' do
        it 'returns the matching records' do
          Investigator.top_ten_tsearch("#{pi.last_name}").should eq [pi]
        end
      end
    end

    context 'investigator units' do
      describe '#unit_list' do
        it 'returns the matching records' do
          pi.unit_list.length.should eq 1
        end
      end
      describe '.distinct_primary_appointments' do
        it 'returns the matching records' do
          Investigator.distinct_primary_appointments.length.should eq 1
        end
      end
      # TODO: test the affirmative matching record - not just the non-matching empty return value
      describe '.distinct_joint_appointments' do
        it 'returns the matching records' do
          Investigator.distinct_joint_appointments.should be_empty
        end
      end
      # TODO: test the affirmative matching record - not just the non-matching empty return value
      describe '.distinct_secondary_appointments' do
        it 'returns the matching records' do
          Investigator.distinct_secondary_appointments.should be_empty
        end
      end
      # TODO: test the affirmative matching record - not just the non-matching empty return value
      describe '.distinct_associate_memberships' do
        it 'returns the matching records' do
          Investigator.distinct_associate_memberships.should be_empty
        end
      end
    end

  end

  context 'without data' do
    describe '.deleted_with_valid_abstracts' do
      it 'returns the matching records' do
        pis = Investigator.deleted_with_valid_abstracts
        pis.should be_empty
      end
    end
  end

end

