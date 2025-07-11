module EmailTestHelper
  def mock_email(from: "test@example.com", subject: "Test Subject", body: "Test body", message_id: nil)
    message_id ||= "test-#{SecureRandom.hex(4)}"

    mail = mock("mail")
    mail.stubs(:message_id).returns(message_id)
    mail.stubs(:subject).returns(subject)
    mail.stubs(:from).returns([ from ])

    body_mock = mock("body")
    body_mock.stubs(:decoded).returns(body)
    body_mock.stubs(:force_encoding).returns(body)
    mail.stubs(:body).returns(body_mock)

    mail
  end

  def mock_scam_email
    mock_email(
      from: "prince@nigeria.fake",
      subject: "Urgent: Transfer $10 Million",
      body: "Dear sir, I need your help to transfer $10 million...",
      message_id: "scam-email-123"
    )
  end

  def mock_legitimate_email
    mock_email(
      from: "newsletter@company.com",
      subject: "Welcome to our newsletter",
      body: "Thank you for subscribing to our newsletter...",
      message_id: "legit-email-123"
    )
  end

  def mock_mail_fetch(emails)
    Mail.stubs(:find).returns(Array(emails))
  end

  def stub_mail_defaults
    Mail.stubs(:defaults).returns(true)
  end
end
