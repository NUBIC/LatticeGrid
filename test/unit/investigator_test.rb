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

require File.dirname(__FILE__) + '/../test_helper'

class InvestigatorTest < ActiveSupport::TestCase
#  fixtures :investigators

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_investigator_fixture
    assert(Investigator.all.length >= 1)
    first_pi = Investigator.find(1)
    first_pi_by_username = Investigator.find_by_username_including_deleted("1")
    first_pi_by_email = Investigator.find_by_email_including_deleted("wf-anderson@northwestern.edu")
    assert(first_pi.id == 1)
    assert(first_pi_by_username.id == 1)
    assert(first_pi.first_name+" "+first_pi.last_name == first_pi.name)
    assert(!first_pi.full_name.blank?)
    assert(!first_pi.sort_name.blank?)
  end
  
  def test_investigator_scope
    all_pis_including_deleted = Investigator.include_deleted
    all_pis = Investigator.all
    # for now haven't created anyone who is deleted
    assert(all_pis_including_deleted.length >= all_pis.length)
    assert(Investigator.deleted_with_valid_abstracts.length == 0)
    #need to change if we add deleted investigators
    assert(Investigator.find_purged.length == 0)
    # this should always be true
    assert(Investigator.find_purged.length < all_pis_including_deleted.length)
    assert(Investigator.find_updated.length == all_pis.length)
    assert(Investigator.find_not_updated.length ==0 )
  end
 
  def test_investigator_basis
    no_basis = Investigator.has_basis_without_connections("FT")
    assert(no_basis.length == 0)
    no_basis = Investigator.has_basis_without_connections("UNPD")
    assert(no_basis.length == 0)
  end
 
  def test_investigator_similar
    first_pi = Investigator.find(1)
    pi_abstract = first_pi.investigator_abstracts[0]
    assert(first_pi.similar_investigators.length == 0)
    assert(Investigator.generate_date == Investigator.generate_date(5))
    assert(Investigator.generate_date != Investigator.generate_date(1))
    assert(Investigator.distinct_primary_appointments.length == 1 )
    assert(first_pi.home_department_id == 1)
    assert(first_pi.investigator_appointments.length >= first_pi.member_appointments.length)
    assert(first_pi.memberships[0] == first_pi.home_department)
    assert(first_pi.investigator_appointments.length == first_pi.appointments.length)
    if (first_pi.joints.length > 0)
      assert(first_pi.joints.length == first_pi.joint_appointments.length)
    end
    if (first_pi.secondaries.length > 0)
      assert(first_pi.secondaries.length == first_pi.secondary_appointments.length)
    end
    assert(first_pi.member_appointments.length == first_pi.memberships.length)
    assert(first_pi.abstracts.length >= 1)
  end


  def test_investigator_abstracts_display
    abstracts=Abstract.display_all_investigator_data(1)
    assert(abstracts.length >= 1)
    assert(abstracts[0].id == 1)
    assert_raise(NoMethodError,"abstracts.total_entries should not exist") {abstracts.total_entries}
    abstracts=Abstract.display_investigator_data(1,1)
    assert(abstracts.length >= 1)
    assert(abstracts[0].id >= 1)
    assert_not_nil(abstracts.total_entries, "abstracts.total_entries should  exist")
    assert(abstracts.length == abstracts.total_entries)
  end

  test "investigator coauthors" do 
    pi = Investigator.find(1)
    coauthors = pi.colleague_coauthors
    direct_coauthors = pi.direct_coauthors
    assert(coauthors.length == 0)
    assert(direct_coauthors.length == 0)
  end

  test "investigators in list" do 
    pis = Investigator.find_investigators_in_list("1,1")
    assert(pis.length == 1)
    pis = Investigator.find_investigators_in_list("wf-anderson@northwestern.edu,1,wakibbe@northwestern.edu")
    assert(pis.length == 1)
  end

  test "investigators by tsearch" do 
    #need to create the tsearch vector prior to running tests. Not sure why Investigator.create_vector needs to be run too
		Abstract.create_vector  #doesn't hurt to try, even if it exists
		Abstract.update_vector
		Investigator.create_vector  #doesn't hurt to try, even if it exists
		Investigator.update_vector
    count = Investigator.count_all_tsearch("Anderson")
    assert(count == 1)
    results = Investigator.investigators_tsearch("Anderson")
    assert(results.length == 1)
    assert(results[0].id == 1)
    pis = Investigator.all_tsearch("Anderson")
    assert(pis.length == 1)
    assert(pis[0].id == 1)
    pis = Investigator.top_ten_tsearch("Anderson")
    assert(pis.length == 1)
    assert(pis[0].id == 1)
  end
 
  test "investigator units" do 
    pi = Investigator.find(1)
    units = pi.unit_list
    assert(units.length > 0)
    units = Investigator.distinct_primary_appointments
    assert(units.length > 0)
    # none set in the fixtures
    units = Investigator.distinct_joint_appointments
    assert(units.length == 0)
    # one in the fixture
    units = Investigator.distinct_secondary_appointments
    assert(units.length == 1)
    units = Investigator.distinct_associate_memberships
    assert(units.length == 1)

  end
 
  test "investigator abstracts" do 
    pi = Investigator.find(1)
    abstracts_cnt = pi.abstract_count
    assert(pi.abstracts.length > 0)
    assert(pi.abstracts.length == abstracts_cnt)
    last_five_cnt = pi.abstract_last_five_years_count
    recent_cnt = Abstract.investigator_publications(pi.id, 5).length
    assert(abstracts_cnt >= last_five_cnt)
    assert(abstracts_cnt >= recent_cnt)
    assert(last_five_cnt == recent_cnt)
  end

 
  
  test "invalid with empty attributes" do 
    pi = Investigator.new 
    assert !pi.valid? 
    assert pi.errors.invalid?(:username) 
  end 
  
end
