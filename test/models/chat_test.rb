require "test_helper"

class ChatTest < ActiveSupport::TestCase
  test "new_chat_message creates and returns a new chat message" do
    new_chat_message = chats(:one).new_chat_message(users(:system), "test message")
    assert_equal "test message", new_chat_message.message
    chats(:one).chat_messages.find_by!(message: "test message")
  end

  test "get_history returns all chat messages in ascending order of creation time" do
    chat = Chat.create(user: users(:one), chapter: chapters(:two))
    chat.chat_messages.create(user: users(:system), message: "one", created_at: DateTime.new(2000, 5, 1))
    chat.chat_messages.create(user: users(:system), message: "three", created_at: DateTime.new(2000, 5, 3))
    chat.chat_messages.create(user: users(:system), message: "four", created_at: DateTime.new(2000, 5, 4))
    chat.chat_messages.create(user: users(:system), message: "two", created_at: DateTime.new(2000, 5, 2))

    history = chat.get_history
    assert_equal ["one", "two", "three", "four"], history.pluck(:message)
  end

  test "deleting a chat also deletes all its chat messages" do
    chat_message_id = chat_messages(:one).id

    chats(:one).destroy
    assert_raises(ActiveRecord::RecordNotFound) do
      ChatMessage.find(chat_message_id)
    end
  end
end
