require "test_helper"

class BlobsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # happy path

  test "new should return new blob form for blob" do
    sign_in users(:one)

    get new_story_blob_path("TESTS1")
    assert_response :success
    assert_match "Create Blob", @response.body
    assert_match "/s/TESTS1/b", @response.body
  end

  test "create should create new blob for story" do
    sign_in users(:one)

    post story_blobs_path("TESTS1"), params: {blob: {title: "2", body: "two"}}
    new_blob = Blob.find_by!(title: "2")
    assert_equal new_blob.story, stories(:one)
    assert_redirected_to edit_story_blob_path("TESTS1", new_blob.id)
  end

  test "edit should return populated edit blob form for story" do
    sign_in users(:one)

    get edit_story_blob_path("TESTS1", blobs(:one).id)
    assert_response :success
    assert_match "Update Blob", @response.body
    assert_match "Blob one", @response.body
    assert_match "Body one", @response.body
  end

  test "update should update existing blob" do
    sign_in users(:one)

    patch story_blob_path("TESTS1", blobs(:one).id),
          params: { blob: {title: "New title", body: "New body"}}
    assert_redirected_to edit_story_blob_path("TESTS1", blobs(:one).id)
    blob = Blob.find(blobs(:one).id)
    assert_equal "New title", blob.title
    assert_equal "New body", blob.body
  end

  test "destroy should delete blob" do
    sign_in users(:one)

    blob_id = blobs(:one).id
    delete story_blob_path("TESTS1", blob_id)
    assert_redirected_to edit_story_path("TESTS1")
    assert_raises(ActiveRecord::RecordNotFound) do
      Blob.find(blob_id)
    end
  end

  # auth and ownership

  test "new create edit update destroy require auth" do
    get new_story_blob_path("TESTS1")
    assert_redirected_to new_user_session_path
    post story_blobs_path("TESTS1"), params: { blob: {title: "2", body: "two"}}
    assert_redirected_to new_user_session_path
    get edit_story_blob_path("TESTS1", blobs(:one).id)
    assert_redirected_to new_user_session_path
    patch story_blob_path("TESTS1", blobs(:one).id),
          params: { blob: {title: "New title", body: "New body"}}
    assert_redirected_to new_user_session_path
    delete story_blob_path("TESTS1", blobs(:one).id)
    assert_redirected_to new_user_session_path

    sign_in users(:one)
    get new_story_blob_path("TESTS1")
    assert_response :success
    post story_blobs_path("TESTS1"), params: { blob: {title: "2", body: "two"}}
    assert_response :redirect
    get edit_story_blob_path("TESTS1", blobs(:one).id)
    assert_response :success
    patch story_blob_path("TESTS1", blobs(:one).id),
          params: { blob: {title: "New title", body: "New body"}}
    assert_response :redirect
    delete story_blob_path("TESTS1", blobs(:one).id)
    assert_response :redirect
  end

  test "only the author can new create edit update destroy blobs for a story" do
    author = users(:one)
    other_user = users(:two)

    sign_in other_user
    get new_story_blob_path("TESTS1")
    assert_response :not_found
    post story_blobs_path("TESTS1"), params: { blob: {title: "2", body: "two"}}
    assert_response :not_found
    get edit_story_blob_path("TESTS1", blobs(:one).id)
    assert_response :not_found
    patch story_blob_path("TESTS1", blobs(:one).id),
          params: { blob: {title: "New title", body: "New body"}}
    assert_response :not_found
    delete story_blob_path("TESTS1", blobs(:one).id)
    assert_response :not_found

    sign_out other_user
    sign_in author
    get new_story_blob_path("TESTS1")
    assert_response :success
    post story_blobs_path("TESTS1"), params: { blob: {title: "2", body: "two"}}
    assert_response :redirect
    get edit_story_blob_path("TESTS1", blobs(:one).id)
    assert_response :success
    patch story_blob_path("TESTS1", blobs(:one).id),
          params: { blob: {title: "New title", body: "New body"}}
    assert_response :redirect
    delete story_blob_path("TESTS1", blobs(:one).id)
    assert_response :redirect
  end
end
