class Blob < ApplicationRecord
  include Embedding

  belongs_to :story

  validates :title, presence: true
  validates :body, presence: true, length: {maximum: 2000}
end
