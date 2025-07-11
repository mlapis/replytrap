class Persona < ApplicationRecord
  belongs_to :user
  has_many :email_accounts, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :description, presence: true
end
