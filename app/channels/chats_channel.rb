class ChatsChannel < ApplicationCable::Channel
  Message = Struct.new(:chat_message, :user)

  def subscribed
    @chat = Chat.create_or_find_by!(chapter_id: params["chapter_id"], user_id: current_user.id)
    stream_for @chat
  end

  def unsubscribed
    stop_stream_for(@chat)
  end

  def receive(data)
    chat_message = @chat.new_chat_message(current_user, data["message"])
    ChatsChannel.broadcast_to(@chat, Message.new(
      chat_message: chat_message, user: chat_message.user
    ))

    chat_message.generate_reply{|message|
      ChatsChannel.broadcast_to(message.chat, Message.new(
        chat_message: message, user: message.user
      ))
    }
  end
end
