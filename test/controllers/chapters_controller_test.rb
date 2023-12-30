require "test_helper"

class ChaptersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # happy path

  test "show should return chapter" do
    get story_chapter_path("TESTS1", 1)
    assert_response :success
    assert_match "Body one", @response.body
  end

  test "new should return new chapter form for story" do
    sign_in users(:one)

    get new_story_chapter_path("TESTS1")
    assert_response :success
    assert_match "Create Chapter", @response.body
    assert_match "/s/#{stories(:one).id}/c", @response.body
  end

  test "create should create new chapter for story" do
    sign_in users(:one)

    post story_chapters_path(stories(:one).id), params: { chapter: {title: "2", body: "two"}}
    new_chapter = Chapter.find_by!(title: "2")
    assert_equal new_chapter.story, stories(:one)
    assert_redirected_to story_chapter_path("TESTS1", 2)
  end

  test "edit should return populated edit chapter form for story" do
    sign_in users(:one)

    get edit_story_chapter_path("TESTS1", 1)
    assert_response :success
    assert_match "Update Chapter", @response.body
    assert_match "Chapter one", @response.body
    assert_match "Body one", @response.body
  end

  test "update should update existing chapter" do
    sign_in users(:one)

    patch story_chapter_path(stories(:one).id, chapters(:one).id),
          params: { chapter: {title: "New title", body: "New body"}}
    assert_redirected_to story_chapter_path("TESTS1", 1)
    chapter = Chapter.find(chapters(:one).id)
    assert_equal "New title", chapter.title
    assert_equal "New body", chapter.body
  end

  test "destroy should delete chapter" do
    sign_in users(:one)

    chapter_id = chapters(:one).id
    delete story_chapter_path("TESTS1", 1)
    assert_redirected_to story_path("TESTS1")
    assert_raises(ActiveRecord::RecordNotFound) do
      Chapter.find(chapter_id)
    end
  end

  # auth and ownership

  test "show doesnt require auth" do
    get story_chapter_path("TESTS1", 1)
    assert_response :success

    sign_in users(:one)
    get story_chapter_path("TESTS1", 1)
    assert_response :success
  end

  test "new create edit update destroy require auth" do
    get new_story_chapter_path("TESTS1")
    assert_redirected_to new_user_session_path
    post story_chapters_path(stories(:one).id), params: { chapter: {title: "2", body: "two"}}
    assert_redirected_to new_user_session_path
    get edit_story_chapter_path("TESTS1", 1)
    assert_redirected_to new_user_session_path
    patch story_chapter_path(stories(:one).id, chapters(:one).id),
          params: { chapter: {title: "New title", body: "New body"}}
    assert_redirected_to new_user_session_path
    delete story_chapter_path("TESTS1", 1)
    assert_redirected_to new_user_session_path

    sign_in users(:one)
    get new_story_chapter_path("TESTS1")
    assert_response :success
    post story_chapters_path(stories(:one).id), params: { chapter: {title: "2", body: "two"}}
    assert_response :redirect
    get edit_story_chapter_path("TESTS1", 1)
    assert_response :success
    patch story_chapter_path(stories(:one).id, chapters(:one).id),
          params: { chapter: {title: "New title", body: "New body"}}
    assert_response :redirect
    delete story_chapter_path("TESTS1", 2)
    assert_response :redirect
  end

  test "only the author can new create edit update destroy chapters for a story" do
    author = users(:one)
    other_user = users(:two)

    sign_in other_user
    get new_story_chapter_path("TESTS1")
    assert_response :not_found
    post story_chapters_path(stories(:one).id), params: { chapter: {title: "2", body: "two"}}
    assert_response :not_found
    get edit_story_chapter_path("TESTS1", 1)
    assert_response :not_found
    patch story_chapter_path(stories(:one).id, chapters(:one).id),
          params: { chapter: {title: "New title", body: "New body"}}
    assert_response :not_found
    delete story_chapter_path("TESTS1", 2)
    assert_response :not_found

    sign_out other_user
    sign_in author
    get new_story_chapter_path("TESTS1")
    assert_response :success
    post story_chapters_path(stories(:one).id), params: { chapter: {title: "2", body: "two"}}
    assert_response :redirect
    get edit_story_chapter_path("TESTS1", 1)
    assert_response :success
    patch story_chapter_path(stories(:one).id, chapters(:one).id),
          params: { chapter: {title: "New title", body: "New body"}}
    assert_response :redirect
    delete story_chapter_path("TESTS1", 2)
    assert_response :redirect
  end

  # chapter numbers

  test "chapter numbers are automatically generated when creating a chapter" do
    sign_in users(:one)

    post story_chapters_path(stories(:one).id), params: { chapter: {title: "2", body: "two"}}
    chapter = Chapter.find_by!(title: "2", body:"two")
    assert_equal false, chapter.number.nil?
  end

  test "chapter numbers are created sequentially" do
    sign_in users(:one)

    post story_chapters_path(stories(:one).id), params: { chapter: {title: "2", body: "two"}}
    post story_chapters_path(stories(:one).id), params: { chapter: {title: "3", body: "three"}}
    post story_chapters_path(stories(:one).id), params: { chapter: {title: "4", body: "four"}}
    chapter2 = Chapter.find_by!(title: "2", body:"two")
    chapter3 = Chapter.find_by!(title: "3", body:"three")
    chapter4 = Chapter.find_by!(title: "4", body:"four")
    assert_equal 2, chapter2.number
    assert_equal 3, chapter3.number
    assert_equal 4, chapter4.number
  end

  test "only the last chapter can be destroyed" do
    sign_in users(:one)

    post story_chapters_path(stories(:one).id), params: { chapter: {title: "2", body: "two"}}
    delete story_chapter_path("TESTS1", 1)
    assert_response :internal_server_error
    delete story_chapter_path("TESTS1", 2)
    assert_response :redirect
  end

  test "chapter numbers stay sequential while deleting and creating chapters" do
    sign_in users(:one)

    post story_chapters_path(stories(:one).id), params: { chapter: {title: "2", body: "two"}}
    post story_chapters_path(stories(:one).id), params: { chapter: {title: "3", body: "three"}}
    assert_equal(
      ["Chapter one", "2", "3"],
      stories(:one).chapters.order(number: :asc).pluck(:title)
    )

    delete story_chapter_path("TESTS1", 3)
    post story_chapters_path(stories(:one).id), params: { chapter: {title: "3-2", body: "three-two"}}
    assert_equal(
      ["Chapter one", "2", "3-2"],
      stories(:one).chapters.order(number: :asc).pluck(:title)
    )

    delete story_chapter_path("TESTS1", 3)
    delete story_chapter_path("TESTS1", 2)
    delete story_chapter_path("TESTS1", 1)
    post story_chapters_path(stories(:one).id), params: { chapter: {title: "1-2", body: "one-two"}}
    post story_chapters_path(stories(:one).id), params: { chapter: {title: "2-2", body: "two-two"}}
    post story_chapters_path(stories(:one).id), params: { chapter: {title: "3-3", body: "three-three"}}
    assert_equal(
      ["1-2", "2-2", "3-3"],
      stories(:one).chapters.order(number: :asc).pluck(:title)
    )
  end
end
