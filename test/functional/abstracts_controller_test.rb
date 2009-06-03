require 'test_helper'

class AbstractsControllerTest < ActionController::TestCase


  test "should get index" do
    get :index
    assert_redirected_to year_list_abstract_path(:id => '2009', :page => '1')
#    assert_not_nil assigns(:abstracts)
  end

  test "should show abstract" do
    get :show, :id => abstracts(:one).to_param
    assert_response :success
  end


  def test_index
    get :index
    assert_redirected_to year_list_abstract_path(:id => '2009', :page => '1')
#    assert_template 'year_list'
  end

  def test_year_list
    #year list needs an id and page or it is redirected
    get :year_list, {:id => '2009', :page => '1'}

    assert_response :success
    assert_template 'year_list'
    assert_not_nil assigns(:abstracts)
    
    get :year_list, {:id => '2007'}
    assert_redirected_to :controller=>'abstracts',:action=>'year_list', :id => '2007', :page => '1'
    assert_template ''
    assert assigns(:abstracts).blank?
    get :year_list, {:id => '2008'}
    assert_redirected_to :controller=>'abstracts',:action=>'year_list', :id => '2008', :page => '1'
    assert_template ''
    assert assigns(:abstracts).blank?
  end

  def test_show
    get :show, :id => abstracts(:one).id

    assert_response :success
    assert_template 'show'

#    assert_not_nil assigns(:abstract)
#    assert assigns(:abstract).valid?
  end

end
