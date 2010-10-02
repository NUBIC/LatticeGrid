require File.dirname(__FILE__) + '/../test_helper'

class InvestigatorTest < ActiveSupport::TestCase
#  fixtures :investigators

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_investigator_fixture
    assert(Investigator.find(:all).length == 1)
    first_pi = Investigator.find(1)
    assert(first_pi.id == 1)
    assert(first_pi.first_name+" "+first_pi.last_name == first_pi.name)
  end

  def test_investigator_similar
    first_pi = Investigator.find(1)
    pi_abstract = first_pi.investigator_abstracts[0]
    assert(first_pi.similar_investigators.length == 0)
    assert(Investigator.generate_date == Investigator.generate_date(5))
    assert(Investigator.generate_date != Investigator.generate_date(1))
    assert(Investigator.distinct_primary_appointments.length == 1 )
    assert(first_pi.home_department_id == 1)
    assert(first_pi.investigator_appointments.length == first_pi.member_appointments.length)
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


  def test_get_investigator_publications
    abstracts=Abstract.display_all_investigator_data(1)
    assert(abstracts.length == 1)
    assert(abstracts[0].id == 1)
    assert_raise(NoMethodError,"abstracts.total_entries should not exist") {abstracts.total_entries}
    abstracts=Abstract.display_investigator_data(1,1)
    assert(abstracts.length == 1)
    assert(abstracts[0].id == 1)
    assert_not_nil(abstracts.total_entries, "abstracts.total_entries should  exist")
    assert(abstracts.length == abstracts.total_entries)
  end
  test "invalid with empty attributes" do 
    pi = Investigator.new 
    assert !pi.valid? 
    assert pi.errors.invalid?(:username) 
  end 
  
end
