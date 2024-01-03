class ChatMessage < ApplicationRecord
  belongs_to :chat
  belongs_to :user

  validates :message, presence: true

  def generate_reply(&callback)
    system_user = User.find_by(username: "system", email: "system@fiction.party")
    reply = self.chat.chat_messages.create!(user: system_user, message: "I received your message: #{message}")
    callback.call(reply)
  end
end
