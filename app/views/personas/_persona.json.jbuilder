json.extract! persona, :id, :name, :description, :user_id, :created_at, :updated_at
json.url persona_url(persona, format: :json)
