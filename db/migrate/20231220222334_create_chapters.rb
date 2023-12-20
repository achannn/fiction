class CreateChapters < ActiveRecord::Migration[7.1]
  def change
    create_table :chapters do |t|
      t.references :story, null: false, foreign_key: true
      t.integer :number
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
