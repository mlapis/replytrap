require "test_helper"

class EmailFetcherTest < ActiveSupport::TestCase
  def setup
    @email_account = email_accounts(:one)
    @fetcher = EmailFetcher.new(@email_account)
    stub_mail_defaults
  end

  test "fetches and stores new emails" do
    email = mock_email(message_id: "unique-123")
    mock_mail_fetch(email)
    ScamDetector.any_instance.stubs(:analyze).returns({ confidence: "high" })

    assert_difference "EmailMessage.count", 1 do
      assert_difference "Conversation.count", 1 do
        @fetcher.fetch_emails
      end
    end

    message = EmailMessage.last
    assert_equal "Test Subject", message.subject
    assert_equal "Test body", message.body
    assert_equal "inbound", message.direction
    assert_equal "unique-123", message.message_id
  end

  test "skips duplicate emails" do
    email_message.with_id("duplicate-123").for_conversation(conversations(:one)).create!

    email = mock_email(message_id: "duplicate-123")
    mock_mail_fetch(email)

    assert_no_difference "EmailMessage.count" do
      @fetcher.fetch_emails
    end
  end

  test "creates conversation for new sender" do
    email = mock_email(from: "newscammer@evil.com")
    mock_mail_fetch(email)
    ScamDetector.any_instance.stubs(:analyze).returns({ confidence: "high" })

    assert_difference "Conversation.count", 1 do
      @fetcher.fetch_emails
    end

    conversation = Conversation.last
    assert_equal "newscammer@evil.com", conversation.email_contact
    assert_equal "unknown", conversation.classification
    assert_equal "active", conversation.status
  end

  test "uses existing conversation for known sender" do
    email = mock_email(from: "scammer@badguys.com")
    mock_mail_fetch(email)
    ScamDetector.any_instance.stubs(:analyze).returns({ confidence: "high" })

    assert_no_difference "Conversation.count" do
      @fetcher.fetch_emails
    end

    assert_equal conversations(:one), EmailMessage.last.conversation
  end

  test "triggers scam detection for first message in conversation" do
    email = mock_email(from: "newscammer@evil.com")
    mock_mail_fetch(email)

    detector_mock = mock("detector")
    detector_mock.expects(:analyze).returns({ confidence: "high" })
    ScamDetector.expects(:new).with(anything).returns(detector_mock)

    @fetcher.fetch_emails
  end

  test "does not trigger scam detection for subsequent messages" do
    email_message.for_conversation(conversations(:one)).create!

    email = mock_email(from: "scammer@badguys.com")
    mock_mail_fetch(email)

    ScamDetector.expects(:new).never

    @fetcher.fetch_emails
  end

  test "handles authentication errors" do
    Mail.stubs(:find).raises(StandardError.new("Authentication failed"))
    @email_account.expects(:update!).with(status: "disabled")

    @fetcher.fetch_emails
  end

  test "handles general errors" do
    Mail.stubs(:find).raises(StandardError.new("Network error"))
    @email_account.expects(:update!).with(status: "error")

    @fetcher.fetch_emails
  end

  test "handles malformed emails gracefully" do
    bad_mail = mock_email
    bad_mail.stubs(:subject).raises(StandardError.new("Malformed email"))
    good_mail = mock_email(message_id: "good-123")

    mock_mail_fetch([ bad_mail, good_mail ])
    ScamDetector.any_instance.stubs(:analyze).returns({ confidence: "high" })

    # Should still process the good email
    assert_difference "EmailMessage.count", 1 do
      @fetcher.fetch_emails
    end
  end
end
