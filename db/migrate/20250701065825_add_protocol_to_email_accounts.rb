class AddProtocolToEmailAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :email_accounts, :protocol, :string, default: 'imap', null: false
  end
end
