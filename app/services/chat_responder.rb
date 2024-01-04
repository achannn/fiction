class ChatResponder < ApplicationService
  def initialize(chat_message)
    @chat_message = chat_message
  end

  def call
    client = OpenAI::Client.new
    response = client.chat(parameters: {
      model: "gpt-3.5-turbo",
      messages: messages,
    })
    response.dig("choices", 0, "message", "content")
  end

  private

  def messages
    messages = []
    messages << setup_message
    messages.push(*message_history)
  end

  def message_history
    system_user = User.find_by!(username: "system", email: "system@fiction.party")
    chat_history = @chat_message.chat.get_history

    messages = []
    chat_history.each do | chat_message |
      messages << {
        role: chat_message.user == system_user ? "assistant" : "user",
        content: chat_message.message
      }
      if chat_message == @chat_message
        break
      end
    end
    messages
  end

  def relevant_chapters
    # sorted top N chapters by embeddings, include only chapters up to this point
    "One day a boy walked to the store and bought some candy. The candy was very delicious but so so expensive. The boy became broke the next day.

The boy ended up finding a job and became rich."
  end

  def relevant_blobs
    # sorted top N blobs by embeddings
    "The candy store was owned by the mafia.

The candy store owners name is Vincent."
  end

  def setup_message
    {
      role: "system",
      content: "Answer the questions based on the story below, if the question can't be answered, say 'I dont know'.

========================================================

Here is the story:

#{relevant_chapters}

========================================================

Here is extra information about the story:

#{relevant_blobs}"
    }
  end
end
