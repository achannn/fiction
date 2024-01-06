class GenerateEmbeddingJob < ApplicationJob
  queue_as :default
  retry_on Faraday::Error, wait: :polynomially_longer, attempts: 5

  def perform(record)
    record.generate_embedding
  end
end
