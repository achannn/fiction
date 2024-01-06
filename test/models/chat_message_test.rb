require "test_helper"

class ChatMessageTest < ActiveSupport::TestCase
  test "generate_reply creates a responding ChatMessage by the system user" do
    chat_messages(:one).generate_reply
    ChatMessage.find_by!(chat: chats(:one), user: users(:system), message: chat_responder_ret)
  end
end

class ChatMessageBroadcastTest < ActionCable::Channel::TestCase
  tests ChatsChannel

  test "chat messages are broadcasted after creation" do
    stub_connection current_user: users(:one)
    subscribe chapter_id: chapters(:one).id

    broadcasts = capture_broadcasts(broadcasting_for(chats(:one))) do
      chats(:one).chat_messages.create(user: users(:one), message: "test message")
    end
    assert_equal 1, broadcasts.length
    assert_equal "test message", broadcasts.first["chat_message"]["message"]
  end
end
