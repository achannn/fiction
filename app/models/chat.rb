class Chat < ApplicationRecord
  has_many :chat_messages, dependent: :destroy

  belongs_to :chapter
  belongs_to :user

  def new_chat_message(user, message)
    self.chat_messages.create!(user: user, message: message)
  end

  def get_history
    self.chat_messages.order(created_at: :asc)
  end
end
