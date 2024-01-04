class ChatMessage < ApplicationRecord
  belongs_to :chat
  belongs_to :user

  validates :message, presence: true

  def generate_reply(&callback)
    reply = ChatResponder.call(self)
    system_user = User.find_by(username: "system", email: "system@fiction.party")
    message = self.chat.chat_messages.create!(user: system_user, message: reply)
    callback.call(message)
  end
end
