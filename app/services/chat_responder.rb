class ChatResponder < ApplicationService
  def initialize(chat_message)
    @chat_message = chat_message
  end

  def call
    get_response
  end


  def get_response
    # We use the question and the relevant embeddings as the key instead of just
    # the question because the author can edit the chapters and blobs at any time
    # invalidating previous answers to the question
    raw_key = @chat_message.message + "/"
    raw_key << relevant_chapters.map { |chapter| chapter.embedding.to_s }.join(":") + "/"
    raw_key << relevant_blobs.map { |blob| blob.embedding.to_s }.join(":")
    key = Digest::MD5.hexdigest(raw_key)

    Rails.cache.fetch(key) do
      logger.info "Chat cache miss for: #{key} (#{@chat_message.message})"

      client = OpenAI::Client.new
      response = client.chat(parameters: {
        model: "gpt-3.5-turbo",
        messages: messages,
        max_tokens: token_count + 100,
      })
      response.dig("choices", 0, "message", "content")
    end
  end

  private

  def messages
    @messages ||= [setup_message].push(*chat_history)
  end

  def chat_history
    system_user = User.find_by!(username: "system", email: "system@fiction.party")
    history = @chat_message.chat.get_history

    messages = []
    history.each do | chat_message |
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

  def token_count
    count = 0
    messages.each do |message|
      count += OpenAI.rough_token_count(message[:content])
    end
    count
  end

  def question_embedding
    @question_embedding ||= EmbeddingCreator.call(@chat_message.message)
  end

  def relevant_chapters
    current_chapter = @chat_message.chat.chapter
    @relevant_chapters ||= Chapter.where(story_id: current_chapter.story_id)
                                  .where("number <= ?", current_chapter.number)
                                  .nearest_neighbors(:embedding, question_embedding, distance: "cosine")
                                  .first(3)
  end

  def relevant_blobs
    @relevant_blobs ||= Blob.where(story_id: @chat_message.chat.chapter.story_id)
                            .nearest_neighbors(:embedding, question_embedding, distance: "cosine")
                            .first(3)
  end

  def setup_message
    ret = {
      role: "system",
      content: "Answer the questions based on the story below, if the question can't be answered, say 'I dont know'.

========================================================

Here is the story:

#{relevant_chapters.map{|chapter| chapter.body}.join(' ')}

========================================================

Here is extra information about the story:

#{relevant_blobs.map{|blob| blob.body}.join(' ')}"
    }
    logger.info("setup_message: #{ret}")
    ret
  end
end
