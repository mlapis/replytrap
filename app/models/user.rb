class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable

  has_many :email_accounts, dependent: :destroy
  has_many :personas, dependent: :destroy
  has_many :conversations, through: :email_accounts
  has_many :email_messages, through: :conversations

  attr_accessor :invite_code
  validate :valid_invite_code, on: :create

  after_create :create_starter_personas

  private

  def valid_invite_code
    errors.add(:invite_code, "is invalid") unless invite_code == ENV["INVITE_CODE"]
  end

  def create_starter_personas
    3.times do
      persona_data = PersonaGenerator.new.generate
      personas.create!(
        name: persona_data[:name],
        description: persona_data[:description]
      )
    end
  end
end
