class EmailAccount < ApplicationRecord
  belongs_to :user
  belongs_to :persona
  has_many :conversations, dependent: :destroy
  has_many :email_messages, through: :conversations

  encrypts :username
  encrypts :password

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :fetch_server, :smtp_server, :username, :password, presence: true
  validates :status, inclusion: { in: %w[connected error disabled] }, allow_nil: true
  validates :fetch_protocol, inclusion: { in: %w[imap pop3] }
  validates :persona, presence: true

  after_initialize :set_defaults, if: :new_record?

  def test_and_update_connection_status
    begin
      test_smtp_connection
    rescue => e
      errors.add(:base, "SMTP connection test failed: #{e.message}")
    end

    begin
      test_fetch_connection
    rescue => e
      errors.add(:base, "Fetch connection test failed: #{e.message}")
    end

    if errors.any?
      update_columns(status: "error", error_message: "Connection failed")
    else
      update_columns(status: "connected", error_message: nil)
    end
  end

  private

  def set_defaults
    self.active = true if active.nil?
  end

  def test_smtp_connection
    server, port = smtp_server.split(":")
    port = port.to_i

    Timeout.timeout(5) do
      Net::SMTP.start(server, port, "mail.client", self.username, self.password, :plain) do |smtp|
        true
      end
    end
  end

  def test_fetch_connection
    server, port = fetch_server.split(":")
    port = port.to_i

    Timeout.timeout(5) do
      if fetch_protocol == "pop3"
        pop = Net::POP3.new(server, port)
        pop.enable_ssl
        pop.start(self.username, self.password)
      else
        imap = Net::IMAP.new(server, port, true)
        imap.login(self.username, self.password)
        imap.disconnect
      end
    end
  end
end
