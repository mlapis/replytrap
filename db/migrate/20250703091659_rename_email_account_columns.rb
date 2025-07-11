class RenameEmailAccountColumns < ActiveRecord::Migration[8.0]
  def change
    rename_column :email_accounts, :imap_server, :fetch_server
    rename_column :email_accounts, :protocol, :fetch_protocol
  end
end
