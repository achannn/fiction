class GenerateEmbeddingJob < ApplicationJob
  queue_as :default

  def perform(record)
    record.generate_embedding
  end
end
