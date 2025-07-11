json.extract! email_account, :id, :email, :fetch_server, :smtp_server, :username, :password, :fetch_protocol, :active, :last_checked_at, :status, :error_message, :user_id, :created_at, :updated_at
json.url email_account_url(email_account, format: :json)
