class Chat < ApplicationRecord
  has_many :chat_messages, dependent: :destroy

  belongs_to :chapter
  belongs_to :user
end
