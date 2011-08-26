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
  
  test "test abstracts exist" do 
    abstracts = Abstract.all
    assert( abstracts.length > 0 )
  end

  test "test first abstract is not nil" do 
    first_abstract = abstracts(:one)
    assert( ! first_abstract.blank?)
    assert( ! first_abstract.year.blank?)
    assert( first_abstract.year ==  '2007')
  end
  
  test "test abstract display methods" do 
    first_abstract = abstracts(:one)
    assert( ! first_abstract.year.blank?)
    abstracts=Abstract.display_data(first_abstract.year)
    assert(abstracts.length > 0)
    assert(abstracts[0].id > 0)
    assert_not_nil(abstracts.total_entries, "abstracts.total_entries should  exist")
    assert(abstracts.length == abstracts.total_entries)
    abstracts=Abstract.display_all_data(first_abstract.year)
    assert(abstracts.length == 1)
    assert(abstracts[0].id == 1)
    assert_raise(NoMethodError,"abstracts.total_entries should not exist") {abstracts.total_entries}
  end

  test "test abstract date methods" do
    abstracts=Abstract.abstracts_by_date("5/1/2000", "5/1/2020")
    assert(abstracts.length > 0)
    assert(abstracts.length == Abstract.all.length )
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

  
end
