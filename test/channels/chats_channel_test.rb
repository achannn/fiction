require "test_helper"

class ChatsChannelTest < ActionCable::Channel::TestCase
  include ActiveJob::TestHelper

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

  test "the received message is rebroadcasted and then the reply is broadcasted" do
    stub_connection current_user: users(:one)
    subscribe chapter_id: chapters(:one).id

    broadcasts = capture_broadcasts(broadcasting_for(chats(:one))) do
      perform_enqueued_jobs do
        perform(:receive, message: "test incoming message")
      end
    end
    assert_equal 2, broadcasts.length
    assert_equal "test incoming message", broadcasts.first["chat_message"]["message"]
    assert_equal chat_responder_ret, broadcasts.last["chat_message"]["message"]
  end
end
