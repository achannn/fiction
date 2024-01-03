require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "deleting a user also deletes all its stories" do
    story_id = stories(:one).id

    users(:one).destroy
    assert_raises(ActiveRecord::RecordNotFound) do
      Story.find(story_id)
    end
  end

  test "deleting a user also deletes all its chats" do
    chat_id = chats(:one).id

    users(:one).destroy
    assert_raises(ActiveRecord::RecordNotFound) do
      ChatMessage.find(chat_id)
    end
  end
end
