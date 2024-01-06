class ChatMessage < ApplicationRecord
  belongs_to :chat
  belongs_to :user

  after_create_commit :broadcast

  validates :message, presence: true, length: {maximum: 500}

  def broadcast
    ChatsChannel.broadcast_to(chat, ChatsChannel::Message.new(
      chat_message: self, user: user
    ))
  end

  def generate_reply
    reply = ChatResponder.call(self)
    system_user = User.find_by!(username: "system", email: "system@fiction.party")
    chat_message = ChatMessage.create(chat: chat, user: system_user, message: reply)
    logger.info("Generated chat message reply (#{chat_message.id}): #{chat_message.message}")
    chat_message
  end
end
