class AddEmbeddingToChapters < ActiveRecord::Migration[7.1]
  def change
    add_column :chapters, :embedding, :vector, limit: 1536
  end
end
