class CreateChatMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :chat_messages do |t|
      t.references :chat, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :message, null: false

      t.timestamps
    end
  end
end
