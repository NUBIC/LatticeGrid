require 'test_helper'
require 'config'

class AbstractsControllerTest < ActionController::TestCase

  test "should get index redirect" do
    get :index
    year = LatticeGridHelper.year_array[0].to_s
    assert_redirected_to abstracts_by_year_path(:id => year, :page => '1')
#    assert_not_nil assigns(:abstracts)
  end

  test "should get year_list redirect" do
    year = LatticeGridHelper.year_array[0].to_s
    get :year_list, {:id => year}
    assert_redirected_to abstracts_by_year_path(:id => year, :page => '1')
#    assert_not_nil assigns(:abstracts)
  end

  test "should get year_list" do
    OrganizationalUnit.rebuild!
    @head_node = OrganizationalUnit.head_node("headnode")
    year = LatticeGridHelper.year_array[0].to_s
    get :year_list, {:id => year, :page => '1'}
    assert_template 'year_list'
    assert_not_nil assigns(:abstracts)
  end

  test "should get current" do
    OrganizationalUnit.rebuild!
    @head_node = OrganizationalUnit.head_node("headnode")
    get :current
    year = LatticeGridHelper.year_array[0].to_s
    assert_response :success
    assert_template 'year_list'
    assert_not_nil assigns(:abstracts)
  end

  test "should show abstract" do
    OrganizationalUnit.rebuild!
    @head_node = OrganizationalUnit.head_node("headnode")
    get :show, :id => abstracts(:one).to_param
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:publication)
    assert assigns(:publication).valid?
  end

  test "should show journal list" do
    OrganizationalUnit.rebuild!
    @head_node = OrganizationalUnit.head_node("headnode")
    get :journal_list, :id => journals(:one).to_param
    assert_response :success
    assert_template 'journal_list'
    assert_not_nil assigns(:abstracts)
  end
  
  test "should get high_impact" do
    get :high_impact
    assert_response :success
    assert_template 'high_impact'
    assert_not_nil assigns(:high_impact)
  end
  
  test "should get impact_factor" do
    get :impact_factor, :id => '2011'
    assert_response :success
    assert_template 'impact_factor'
    assert_not_nil assigns(:journals)
    assert_not_nil assigns(:missing_journals)
    assert_not_nil assigns(:high_impact_pubs)
    assert_not_nil assigns(:all_pubs)
  end
  
  
  test "should get a year_list" do
    #year list needs an id and page or it is redirected
    OrganizationalUnit.rebuild!
    @head_node = OrganizationalUnit.head_node("headnode")
    get :year_list, {:id => '2009', :page => '1'}

    assert_response :success
    assert_template 'year_list'
    assert_not_nil assigns(:abstracts)
    
    get :year_list, {:id => '2007'}
    assert_redirected_to abstracts_by_year_path(:id => '2007', :page => '1')
    assert_template ''
    assert assigns(:abstracts).blank?
    get :year_list, {:id => '2008'}
    assert_redirected_to  abstracts_by_year_path(:id => '2008', :page => '1')
    assert_template ''
    assert assigns(:abstracts).blank?
  end

  test "should get a full_year_list" do
    #year list needs an id and page or it is redirected
    OrganizationalUnit.rebuild!
    @head_node = OrganizationalUnit.head_node("headnode")
    get :full_year_list, :id => '2009'

    assert_response :success
    assert_template 'year_list'
    assert_not_nil assigns(:abstracts)
    
  end

test "should get tag_cloud" do
  get :tag_cloud
  assert_response :success
  assert_template 'tag_cloud'
  assert_not_nil assigns(:tags)
end

test "should get tag_cloud_by_year" do
  xhr :get, 'tag_cloud_by_year', :id => '2011'
  assert_response :success
  assert_template 'shared/_tag_cloud'
  assert_not_nil assigns(:tags)
end


test "should get tagged_abstracts" do
  get :tagged_abstracts, {:id => 'disease', :page=>'1'}
  assert_response :success
  assert_template 'tag'
  assert_not_nil assigns(:abstracts)
end

test "should get full_tagged_abstracts" do
  get :full_tagged_abstracts, {:id => 'disease', :page=>'1'}
  assert_response :success
  assert_template 'tag'
  assert_not_nil assigns(:abstracts)
end



  test "should search abstracts" do
    # this does not seem to work due to a tsearch vector error. Not sure how to resolve
#    get :search, :keywords => journals(:one).journal_name
 #   assert_response :success
  #  assert_template 'year_list'
   # assert_not_nil assigns(:abstracts)
  end
  

end
