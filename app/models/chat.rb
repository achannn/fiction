class Chat < ApplicationRecord
  has_many :chat_messages, dependent: :destroy

  belongs_to :chapter
  belongs_to :user

  def get_history
    self.chat_messages.order(created_at: :asc)
  end
end
