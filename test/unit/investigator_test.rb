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
    assert(Investigator.similar_investigators(first_pi.id).length == 0)
    assert(Investigator.generate_date == Investigator.generate_date(5))
    assert(Investigator.generate_date != Investigator.generate_date(1))
    assert(Investigator.distinct_departments.length == 1 )
    assert(Investigator.distinct_departments == Investigator.distinct_departments_with_divisions )
    assert(Investigator.program_members(1).length == 1)
    assert(Investigator.program_members(1,first_pi.id).length == 0)
    assert(Investigator.program_members(1,first_pi).length == 0)
    assert(Investigator.publications_cnt(first_pi) == 1)
    assert(Investigator.last_author_publications_cnt(first_pi) == 0)
    assert(Investigator.first_author_publications_cnt(first_pi) == 0)
    assert(Investigator.collaborators(first_pi.id).length == 0)
    assert(Investigator.collaborators(first_pi.id).length == Investigator.collaborators_cnt(first_pi.id))
    assert(Investigator.publications_with_program_members_cnt(first_pi.id) == 0)
    assert(Investigator.intramural_collaborators_cnt(first_pi.id) == 0)
    assert(Investigator.other_collaborators_cnt(first_pi.id) == 0)
    assert_not_nil(Investigator.add_collaboration(first_pi,pi_abstract)  )
    assert_not_nil(Investigator.get_investigator_connections(first_pi) )
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
