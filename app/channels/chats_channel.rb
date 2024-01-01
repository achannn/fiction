class ChatsChannel < ApplicationCable::Channel
  after_subscribe :broadcast_history, unless: :subscription_rejected?

  def subscribed
    @chat = Chat.create_or_find_by!(chapter_id: params["chapter_id"], user_id: current_user.id)
    stop_stream_for(@chat)
    stream_for @chat
  end

  def unsubscribed
    stop_all_streams
  end

  def receive(data)
    message = @chat.chat_messages.create(user: current_user, message: data["message"])
    ChatsChannel.broadcast_to(@chat, message)

    system_user = User.find_by(username: "system", email: "system@fiction.party")
    response = @chat.chat_messages.create(user: system_user, message: "I received your message: #{data["message"]}")
    ChatsChannel.broadcast_to(@chat, response)
  end

  private

  def broadcast_history
    @chat.chat_messages.order(created_at: :asc).each do |message|
      ChatsChannel.broadcast_to(@chat, message)
    end
  end
end
