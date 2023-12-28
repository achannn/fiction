class AddUniquenessIndexToChapters < ActiveRecord::Migration[7.1]
  def change
    add_index :chapters, [:story_id, :number], unique: true
  end
end
