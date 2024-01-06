class RespondToChatJob < ApplicationJob
  queue_as :urgent

  def perform(chat_message)
    chat_message.generate_reply
  end
end
