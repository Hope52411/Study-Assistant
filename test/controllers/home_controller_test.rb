require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "test@example.com", password: "password")
    sign_in @user
  end

  test "should get index" do
    get home_index_url
    assert_response :success
  end
end
