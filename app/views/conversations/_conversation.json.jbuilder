json.extract! conversation, :id, :email_contact, :classification, :status, :email_account_id, :created_at, :updated_at
json.url conversation_url(conversation, format: :json)
