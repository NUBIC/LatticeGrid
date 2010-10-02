require 'test_helper'

class OrgsControllerTest < ActionController::TestCase
  def test_should_get_index
    OrganizationalUnit.rebuild!
    @head_node = OrganizationalUnit.head_node("headnode")
    get :index
    assert_response :success
    assert_not_nil assigns(:units)
    assert_not_nil assigns(:heading)
  end

  def test_should_show_
    OrganizationalUnit.rebuild!
    @head_node = OrganizationalUnit.head_node("headnode")
    get :show, {:id => organizational_units(:one).id, :page => '1'}
    
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:abstracts)
  end

end
