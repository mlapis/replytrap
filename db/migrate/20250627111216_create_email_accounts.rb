class CreateEmailAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :email_accounts do |t|
      t.string :email
      t.string :imap_server
      t.string :smtp_server
      t.string :username
      t.string :password
      t.boolean :active
      t.datetime :last_checked_at
      t.string :status
      t.text :error_message
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
