require 'test_helper'

class InvestigatorsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  test "should get investigator_listing" do
    get :listing,  :id => investigators(:one).to_param
    assert_response :success
    assert_template 'listing'
    assert_not_nil assigns(:investigators)
  end


end
