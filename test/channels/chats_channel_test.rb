require "test_helper"

class ChatsChannelTest < ActionCable::Channel::TestCase
  test "subscribes to chat for chapter and user" do
    stub_connection current_user: users(:one)
    subscribe chapter_id: chapters(:one).id
    assert subscription.confirmed?
    assert_has_stream_for chats(:one)

    stub_connection current_user: users(:two)
    subscribe chapter_id: chapters(:two).id
    assert subscription.confirmed?
    assert_has_stream_for chats(:two)
  end

  test "receive rebroadcasts the message and then generates reply" do
    stub_connection current_user: users(:one)
    subscribe chapter_id: chapters(:one).id

    broadcasts = capture_broadcasts(broadcasting_for(chats(:one))) do
      perform(:receive, message: "test incoming message")
    end
    assert_equal 2, broadcasts.length
    assert_equal "test incoming message", broadcasts.first["chat_message"]["message"]
    assert_equal "test response", broadcasts.last["chat_message"]["message"]
  end
end
