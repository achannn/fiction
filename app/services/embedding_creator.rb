class EmbeddingCreator < ApplicationService
  def initialize(input)
    @input = input
  end

  def call
    get_embedding
  end

  private

  def get_embedding
    # hashing because the maxsize of input is 5000 chars (chapter.body)
    key = Digest::MD5.hexdigest(@input)

    Rails.cache.fetch(key) do
      logger.info "Embedding cache miss for: #{key} (#{@input})"

      client = OpenAI::Client.new
      response = client.embeddings(parameters: {
        model: "text-embedding-ada-002",
        input: @input,
      })
      response.dig("data", 0, "embedding")
    end
  end
end
