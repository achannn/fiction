require "test_helper"

class StoriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # happy path

  test "index should list all stories" do
    get stories_path
    assert_response :success
    assert_match "Title one", @response.body
    assert_match "Title two", @response.body
  end

  test "show should return story" do
    get story_path("TESTS1")
    assert_response :success
    assert_match "Summary one", @response.body
  end

  test "new should return new story form" do
    sign_in users(:one)

    get new_story_path
    assert_response :success
    assert_match "Create Story", @response.body
  end

  test "create should create new story" do
    sign_in users(:one)

    post stories_path, params: { story: {title: "Title three", summary: "Summary three"}}
    new_story = Story.find_by!(title: "Title three")
    assert_redirected_to story_path(new_story.code)
  end

  test "edit should return populated edit story form" do
    sign_in users(:one)

    get edit_story_path("TESTS1")
    assert_response :success
    assert_match "Update Story", @response.body
    assert_match "Title one", @response.body
    assert_match "Summary one", @response.body
  end

  test "update should update existing story" do
    sign_in users(:one)

    patch story_path(stories(:one).id), params: { story: {title: "New title", summary: "New summary"}}
    assert_redirected_to story_path("TESTS1")
    story = Story.find(stories(:one).id)
    assert_equal "New title", story.title
    assert_equal "New summary", story.summary
  end

  test "destroy should delete story" do
    sign_in users(:one)

    story_id = stories(:one).id
    delete story_path("TESTS1")
    assert_redirected_to stories_path
    assert_raises(ActiveRecord::RecordNotFound) do
      Story.find(story_id)
    end
  end

  # auth and ownership

  test "index show dont require auth" do
    get stories_path
    assert_response :success
    get story_path("TESTS1")
    assert_response :success

    sign_in users(:one)
    get stories_path
    assert_response :success
    get story_path("TESTS1")
    assert_response :success
  end

  test "new create edit update destroy require auth" do
    get new_story_path
    assert_redirected_to new_user_session_path
    post stories_path, params: { story: {title: "1", summary: "1"}}
    assert_redirected_to new_user_session_path
    get edit_story_path("TESTS1")
    assert_redirected_to new_user_session_path
    patch story_path(stories(:one).id), params: { story: {title: "1", summary: "1"}}
    assert_redirected_to new_user_session_path
    delete story_path("TESTS1")
    assert_redirected_to new_user_session_path

    sign_in users(:one)
    get new_story_path
    assert_response :success
    post stories_path, params: { story: {title: "1", summary: "1"}}
    assert_response :redirect
    get edit_story_path("TESTS1")
    assert_response :success
    patch story_path(stories(:one).id), params: { story: {title: "1", summary: "1"}}
    assert_response :redirect
    delete story_path("TESTS1")
    assert_response :redirect
  end

  test "creating a story makes the user the author" do
    user = users(:one)
    sign_in user

    post stories_path, params: { story: {title: "Title three", summary: "Summary three"}}
    story = Story.find_by!(title: "Title three")
    assert_equal user, story.author
  end

  test "only the author can edit update destroy a story" do
    author = users(:one)
    other_user = users(:two)

    sign_in other_user
    get edit_story_path("TESTS1")
    assert_response :not_found
    patch story_path(stories(:one).id), params: { story: {title: "1", summary: "1"}}
    assert_response :not_found
    delete story_path("TESTS1")
    assert_response :not_found

    sign_out other_user
    sign_in author
    get edit_story_path("TESTS1")
    assert_response :success
    patch story_path(stories(:one).id), params: { story: {title: "1", summary: "1"}}
    assert_response :redirect
    delete story_path("TESTS1")
    assert_response :redirect
  end
end
