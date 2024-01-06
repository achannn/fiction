class RespondToChatJob < ApplicationJob
  queue_as :urgent
  retry_on Faraday::Error, wait: :polynomially_longer, attempts: 5

  def perform(chat_message)
    chat_message.generate_reply
  end
end
