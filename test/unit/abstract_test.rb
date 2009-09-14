require File.dirname(__FILE__) + '/../test_helper'

class AbstractTest < ActiveSupport::TestCase
  fixtures :abstracts

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  test "invalid with empty attributes" do 
    first_abstract = abstracts(:one)
    abstract = Abstract.new(:pubmed=>first_abstract.pubmed)
    assert !abstract.valid? 
    assert abstract.errors.invalid?(:pubmed) 
  end 
  test "test abstract display methods" do 
    first_abstract = abstracts(:one)
    abstracts=Abstract.display_data(first_abstract.year)
    assert(abstracts.length == 1)
    assert(abstracts[0].id == 1)
    assert_not_nil(abstracts.total_entries, "abstracts.total_entries should  exist")
    assert(abstracts.length == abstracts.total_entries)
    abstracts=Abstract.display_all_data(first_abstract.year)
    assert(abstracts.length == 1)
    assert(abstracts[0].id == 1)
    assert_raise(NoMethodError,"abstracts.total_entries should not exist") {abstracts.total_entries}
  end
  test "test investigator abstract display methods" do 
    first_abstract = abstracts(:one)
    first_investigator = investigators(:one)
    investigators = Investigator.find(:all)
    abstracts=Abstract.display_investigator_data(first_investigator.id)
    assert(abstracts.length == 1)
    assert(abstracts[0].id == 1)
    assert_not_nil(abstracts.total_entries, "abstracts.total_entries should  exist")
    assert(abstracts.length == abstracts.total_entries)
    abstracts=Abstract.display_all_investigator_data(first_investigator.id)
    assert(abstracts.length == 1)
    assert(abstracts[0].id == 1)
    assert_raise(NoMethodError,"abstracts.total_entries should not exist") {abstracts.total_entries}
    abstracts=Abstract.investigator_publications(investigators)
    assert(abstracts.length == 1)
    assert(abstracts[0].id == 1)
    assert_raise(NoMethodError,"abstracts.total_entries should not exist") {abstracts.total_entries}
  end

  test "test program abstract display methods" do 
    first_abstract = abstracts(:one)
    first_investigator = investigators(:one)
    investigators = Investigator.find(:all)
    abstracts=Abstract.display_program_data(first_investigator.investigator_programs[0].program_id)
    assert(abstracts.length == 1)
    assert(abstracts[0].id == 1)
    assert_not_nil(abstracts.total_entries, "abstracts.total_entries should  exist")
    assert(abstracts.length == abstracts.total_entries)
    abstracts=Abstract.display_all_program_data(first_investigator.investigator_programs[0].program_id)
    assert(abstracts.length == 0)
    assert_nil(abstracts[0])
    assert_raise(NoMethodError,"abstracts.total_entries should not exist") {abstracts.total_entries}
    abstracts=Abstract.display_all_program_data(first_investigator.investigator_programs[0].program_id,first_abstract.year)
    assert(abstracts.length == 1)
    assert(abstracts[0].id == 1)
    abstracts=Abstract.get_all_program_data(first_investigator.investigator_programs[0].program_id)
    assert(abstracts.length == 1)
    assert(abstracts[0].id == 1)
    assert_raise(NoMethodError,"abstracts.total_entries should not exist") {abstracts.total_entries}
    abstracts=Abstract.get_minimal_all_program_data(first_investigator.investigator_programs[0].program_id)
    assert(abstracts.length == 1)
    assert(abstracts[0].id == 1)
    assert_raise(NoMethodError,"abstracts.total_entries should not exist") {abstracts.total_entries}
    abstracts=Abstract.display_program_data_by_date(first_investigator.investigator_programs[0].program_id, "5/1/2000", "5/1/2009")
    assert(abstracts.length == 1)
    assert(abstracts[0].id == 1)
    assert_raise(NoMethodError,"abstracts.total_entries should not exist") {abstracts.total_entries}
    
   end
  
end
