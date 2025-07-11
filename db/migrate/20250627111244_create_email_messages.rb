class CreateEmailMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :email_messages do |t|
      t.string :subject
      t.text :body
      t.string :direction
      t.references :conversation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
