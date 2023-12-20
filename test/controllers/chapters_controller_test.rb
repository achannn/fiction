require "test_helper"

class ChaptersControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get chapters_show_url
    assert_response :success
  end
end
