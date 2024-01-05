class Blob < ApplicationRecord
  belongs_to :story
  has_neighbors :embedding

  after_save :generate_embedding?

  validates :title, presence: true
  validates :body, presence: true, length: {maximum: 2000}

  private

  def generate_embedding?
    if saved_change_to_body?
      embedding = EmbeddingCreator.call(body)
      self.update_column(:embedding, embedding)
    end
  end
end
