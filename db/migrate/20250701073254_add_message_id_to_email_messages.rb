class AddMessageIdToEmailMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :email_messages, :message_id, :string
    add_index :email_messages, :message_id, unique: true
  end
end
