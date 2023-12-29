class MakeFieldsNotNullable < ActiveRecord::Migration[7.1]
  def change
    change_column_null :chapters, :number, false
    change_column_null :stories, :code, false
    change_column_null :users, :username, false
  end
end
