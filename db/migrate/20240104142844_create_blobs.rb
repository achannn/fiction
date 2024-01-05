class CreateBlobs < ActiveRecord::Migration[7.1]
  def change
    create_table :blobs do |t|
      t.references :story, null: false, foreign_key: true
      t.text :body
      t.vector :embedding, limit: 1536

      t.timestamps
    end
  end
end
