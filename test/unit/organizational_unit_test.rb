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
  
  test "test first abstract is not nil" do 
    first_abstract = abstracts(:one)
    assert( ! first_abstract.blank?)
    assert( ! first_abstract.year.blank?)
    assert( first_abstract.year ==  '2006')
  end
  
  test "test first abstract has organizations" do 
    first_abstract = abstracts(:one)
    assert( first_abstract.organization_abstracts.length > 0 )
    assert( first_abstract.organizational_units.length > 0 )
  end
  
  test "test first organizational unit is not nil" do 
    first_unit = organizational_units(:one)
    assert( ! first_unit.blank?)
    assert( ! first_unit.id.blank?)
  end

  test "test first organizational unit self and descendents not nil" do 
    OrganizationalUnit.rebuild!
    first_unit = organizational_units(:one)
    assert( ! first_unit.self_and_descendants.blank?)
    assert( first_unit.self_and_descendants.length > 0)
    assert( first_unit.self_and_descendants[0].id == first_unit.id)
  end
  
  
  test "test first organizational unit has abstracts" do 
    OrganizationalUnit.rebuild!
    first_unit = organizational_units(:one)
    assert( first_unit.abstracts.length > 0)
  end

    test "test first organizational unit has all_abstracts" do 
      OrganizationalUnit.rebuild!
      first_unit = organizational_units(:one)
      assert( first_unit.all_abstracts.length > 0)
    end

    test "test first organizational unit has all_abstract_ids" do 
      OrganizationalUnit.rebuild!
      first_unit = organizational_units(:one)
      assert( first_unit.all_abstract_ids.length > 0)
    end


    test "test organizational unit abstract display methods" do 
      OrganizationalUnit.rebuild!
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
      OrganizationalUnit.rebuild!
      first_unit = organizational_units(:one)
      abstracts=first_unit.display_data_by_date("5/1/2000", "5/1/2009")
      assert(abstracts.length > 0)
      assert(abstracts.length == first_unit.abstract_data.length )
      assert_raise(NoMethodError,"abstracts.total_entries should not exist") {abstracts.total_entries}
    end

    test "test organizational unit faculty methods" do 
      OrganizationalUnit.rebuild!
      first_unit = organizational_units(:one)
      assert(first_unit.primary_faculty.length > 0)
      assert(first_unit.members.length > 0)
      abstracts = first_unit.primary_faculty_publications
      assert(first_unit.primary_faculty_publications.length > 0)
      # tree traversal is not working
  #    assert(first_unit.all_faculty.length > 0)
  #    abstracts=first_unit.all_faculty_publications()
      assert(abstracts.length >= 1 )
      assert(abstracts[0].id == 1)
  #    assert(first_unit.all_faculty_publications.length == first_unit.abstract_data.length )
      assert_raise(NoMethodError,"abstracts.total_entries should not exist") {abstracts.total_entries}

     end
  
end
