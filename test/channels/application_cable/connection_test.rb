require "test_helper"

module ApplicationCable
  class ConnectionTest < ActionCable::Connection::TestCase
    test "connects with cookies" do
      cookies.signed[:user_id] = users(:one).id
      cookies.signed[:user_expires_at] = 30.minutes.from_now
      connect
      assert_equal users(:one), connection.current_user
    end

    test "rejects connection without cookies" do
      assert_reject_connection { connect }
    end
  end
end
