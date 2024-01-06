class ChatsChannel < ApplicationCable::Channel
  Message = Struct.new(:chat_message, :user)

  def subscribed
    @chat = Chat.create_or_find_by!(chapter_id: params["chapter_id"], user_id: current_user.id)
    stream_for @chat
    logger.info("stream started for user(#{current_user.id}) for chat(#{@chat.id})")
  end

  def unsubscribed
    stop_stream_for(@chat)
    logger.info("stream stopped for user(#{@chat.user_id}) for chat(#{@chat.id})")
  end

  def receive(data)
    logger.info("received message in channel: #{data["message"]}")
    chat_message = @chat.chat_messages.create!(user: current_user, message: data["message"])
    RespondToChatJob.perform_later(chat_message)
  end
end
