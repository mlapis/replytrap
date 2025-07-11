class Conversation < ApplicationRecord
  belongs_to :email_account
  has_one :user, through: :email_account
  has_many :email_messages, dependent: :destroy

  validates :email_contact, presence: true, uniqueness: { scope: :email_account_id }
  validates :classification, inclusion: { in: %w[legitimate unknown scammer] }
  validates :status, inclusion: { in: %w[active paused] }

  def waiting_for_answer?
    return false if email_messages.empty?

    email_messages.order(:created_at).last.direction == "outbound"
  end
end
