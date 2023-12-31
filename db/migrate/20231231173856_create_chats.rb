class CreateChats < ActiveRecord::Migration[7.1]
  def change
    create_table :chats do |t|
      t.references :chapter, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.index [:chapter_id, :user_id], unique: true

      t.timestamps
    end
  end
end
