require 'test_helper'

class ProgramsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:programs)
  end

  def test_should_show_program
    get :show, {:id => programs(:one).id, :page => '1'}
    
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:abstracts)
  end

end
