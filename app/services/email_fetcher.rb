class EmailFetcher
  def initialize(email_account)
    @email_account = email_account
  end

  def fetch_emails
    account = @email_account
    host, port = account.fetch_server.split(":")

    Mail.defaults do
      retriever_method account.fetch_protocol.to_sym, {
        address: host,
        port: port.to_i,
        user_name: account.username,
        password: account.password,
        enable_ssl: true
      }
    end

    mails = Mail.find(what: :last, count: 100)
    store_emails(mails)
  rescue StandardError => e
    handle_account_error(e)
  end

  private

  def handle_account_error(error)
    if error.message.match?(/authentication|suspended|disabled|locked/i)
      @email_account.update!(status: "disabled")
    else
      @email_account.update!(status: "error")
    end
  end

  def store_emails(mails)
    mails.each do |mail|
      begin
        next if EmailMessage.exists?(message_id: mail.message_id)

        conversation = find_or_create_conversation(mail)

        email_message = EmailMessage.create!(
          conversation: conversation,
          subject: mail.subject,
          body: mail.body.decoded.force_encoding("UTF-8"),
          direction: "inbound",
          message_id: mail.message_id
        )

        if conversation.email_messages.count == 1
          ScamDetector.new(email_message).analyze
        end
      rescue StandardError => e
        next
      end
    end
  end

  def find_or_create_conversation(mail)
    sender = mail.from.first

    @email_account.conversations.find_or_create_by(
      email_contact: sender
    ) do |conversation|
      conversation.classification = "unknown"
      conversation.status = "active"
    end
  end
end
