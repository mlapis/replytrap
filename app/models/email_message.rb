class EmailMessage < ApplicationRecord
  belongs_to :conversation
  has_one :email_account, through: :conversation
  has_one :user, through: :email_account

  validates :subject, :body, presence: true
  validates :direction, inclusion: { in: %w[inbound outbound] }
  validates :message_id, presence: true, uniqueness: true

  def text_content
    doc = Nokogiri::HTML(body)
    doc.css("style, script").remove

    text = doc.text
    text.gsub(/\s+/, " ")
        .gsub(/\. /, ".\n")
        .gsub(/\n{3,}/, "\n\n")
        .strip
  end

  def reply_subject
    return subject if subject.start_with?("Re:")
    "Re: #{subject}"
  end

  def self.generate_message_id(email_account)
    email_domain = email_account.email.split("@").last
    "<#{SecureRandom.uuid}@#{email_domain}>"
  end
end
