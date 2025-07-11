class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations do |t|
      t.string :email_contact
      t.string :classification
      t.string :status
      t.references :email_account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
