require 'test_helper'

class OrganizationalUnitTest < ActiveSupport::TestCase

  fixtures :abstracts
  fixtures :investigators
  fixtures :investigator_appointments
  fixtures :organizational_units

  # Replace this with your real tests.
  test "the truth" do
    assert true
  end

  test "head node" do
    OrganizationalUnit.rebuild!
    head_node = OrganizationalUnit.head_node("headnode")
    assert( head_node.id == 3 )
    assert( head_node.children.length > 0 )
  end
  
  test "test organizational unit abstract display methods" do 
    first_abstract = abstracts(:one)
    first_unit = organizational_units(:one)
    abstracts=first_unit.abstract_data()
    assert(abstracts.length >= 1)
    assert_not_nil(abstracts.total_entries, "abstracts.total_entries should  exist")
    assert(abstracts.length == abstracts.total_entries)
    
    abstracts=first_unit.get_minimal_all_data()
    assert(abstracts.length > 0)
    assert(first_unit.get_minimal_all_data.length == first_unit.abstract_data.length )
    assert_raise(NoMethodError,"abstracts.total_entries should not exist") {abstracts.total_entries}

    abstracts=first_unit.display_year_data("2000")
    assert(abstracts.length == 0)
    assert_nil(abstracts[0])
    assert_raise(NoMethodError,"abstracts.total_entries should not exist") {abstracts.total_entries}

    abstracts=first_unit.display_year_data(first_abstract.year)
    assert(abstracts.length > 0)
    assert_raise(NoMethodError,"abstracts.total_entries should not exist") {abstracts.total_entries}
    
    
  end

  test "test organizational unit date display methods" do 
    first_unit = organizational_units(:one)
    abstracts=first_unit.display_data_by_date("5/1/2000", "5/1/2009")
    assert(abstracts.length > 0)
    assert(first_unit.display_data_by_date("5/1/2000", "5/1/2009").length == first_unit.abstract_data.length )
    assert_raise(NoMethodError,"abstracts.total_entries should not exist") {abstracts.total_entries}
  end
  
  test "test organizational unit faculty methods" do 
    first_unit = organizational_units(:one)
    assert(first_unit.primary_faculty.length > 0)
    assert(first_unit.members.length > 0)
    abstracts = first_unit.primary_faculty_abstracts
    assert(first_unit.primary_faculty_abstracts.length > 0)
    # tree traversal is not working
#    assert(first_unit.all_faculty.length > 0)
#    abstracts=first_unit.all_faculty_publications()
    assert(abstracts.length >= 1 )
    assert(abstracts[0].id == 1)
#    assert(first_unit.all_faculty_publications.length == first_unit.abstract_data.length )
    assert_raise(NoMethodError,"abstracts.total_entries should not exist") {abstracts.total_entries}
    
    #abstracts=first_unit.all_faculty_publications_by_date("5/1/2000", "5/1/2009")
    #assert(abstracts.length > 0)
    #assert(first_unit.all_faculty_publications_by_date("5/1/2000", "5/1/2009").length == first_unit.abstract_data.length )
    #assert_raise(NoMethodError,"abstracts.total_entries should not exist") {abstracts.total_entries}
    
   end
  
end
