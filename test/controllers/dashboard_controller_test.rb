require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "index should list all of the users stories" do
    sign_in users(:one)

    users(:one).stories.create(title: 'Title three', summary: 'Summary three')
    get write_path
    assert_response :success
    assert_match "Title one", @response.body
    assert_match "Title three", @response.body
  end

  test "index requires auth" do
    get write_path
    assert_redirected_to new_user_session_path

    sign_in users(:one)
    get write_path
    assert_response :success
  end
end
