class AddCodeToStories < ActiveRecord::Migration[7.1]
  def change
    add_column :stories, :code, :string
    add_index :stories, :code, unique: true
  end
end
