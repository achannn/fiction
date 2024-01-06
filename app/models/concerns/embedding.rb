module Embedding
  extend ActiveSupport::Concern

  included do
    has_neighbors :embedding

    after_commit :generate_embedding?
  end

  def generate_embedding?
    if saved_change_to_attribute?(:body)
      GenerateEmbeddingJob.perform_later(self)
    end
  end

  def generate_embedding
    embedding = EmbeddingCreator.call(body)
    update_column(:embedding, embedding)
    logger.info("Generated embedding for #{self}: #{id}")
  end
end
