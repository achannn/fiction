class AddTitleToBlobs < ActiveRecord::Migration[7.1]
  def change
    add_column :blobs, :title, :string
  end
end
