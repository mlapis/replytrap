class EmailSender
  def initialize(email_account)
    @email_account = email_account
  end

  def send_email(to:, subject:, body:, message_id:)
    configure_smtp

    from_email = @email_account.email

    mail = Mail.new do
      from       from_email
      to         to
      subject    subject
      body       body
      message_id message_id
    end

    mail.deliver!

    true
  rescue StandardError => e
    handle_sending_error(e)
    false
  end

  private

  def configure_smtp
    host, port = @email_account.smtp_server.split(":")
    username = @email_account.username
    password = @email_account.password

    Mail.defaults do
      delivery_method :smtp, {
        address: host,
        port: port.to_i,
        user_name: username,
        password: password,
        authentication: "plain",
        enable_starttls_auto: true
      }
    end
  end

  def handle_sending_error(error)
    Rails.logger.error "Email sending failed for account #{@email_account.email}: #{error.class} - #{error.message}"
    Rails.logger.error "Backtrace: #{error.backtrace.first(5).join("\n")}"

    if error.message.match?(/authentication|suspended|disabled|locked/i)
      @email_account.update!(status: "disabled")
    else
      @email_account.update!(status: "error")
    end
  end
end
