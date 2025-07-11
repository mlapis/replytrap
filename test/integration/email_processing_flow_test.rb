require "test_helper"

class EmailProcessingFlowTest < ActiveSupport::TestCase
  def setup
    @email_account = email_accounts(:one)
    stub_mail_defaults
  end

  test "complete email processing flow from fetch to classification" do
    mock_mail_fetch(mock_scam_email)

    # Mock the LLM response that ScamDetector actually uses
    ScamDetector.any_instance.stubs(:generate_response).returns({
      "choices" => [ { "message" => { "content" => '{"confidence": "high"}' } } ]
    })

    EmailFetcherJob.new.perform

    # Verify end-to-end result
    message = EmailMessage.last
    conversation = message.conversation

    assert_email_stored_correctly(message)
    assert_conversation_created_correctly(conversation)
    assert_scam_detected_correctly(conversation)
  end

  test "handles legitimate email classification" do
    mock_mail_fetch(mock_legitimate_email)

    # Mock the LLM response for legitimate classification
    ScamDetector.any_instance.stubs(:generate_response).returns({
      "choices" => [ { "message" => { "content" => '{"confidence": "low"}' } } ]
    })

    EmailFetcherJob.new.perform

    conversation = Conversation.last
    assert_equal "legitimate", conversation.classification
  end

  test "processes multiple emails in sequence" do
    emails = [ mock_scam_email, mock_legitimate_email ]
    mock_mail_fetch(emails)
    ScamDetector.any_instance.stubs(:analyze).returns({ confidence: "medium" })

    assert_difference "EmailMessage.count", 2 do
      assert_difference "Conversation.count", 2 do
        EmailFetcherJob.new.perform
      end
    end
  end

  test "handles duplicate email detection" do
    # Setup existing email
    existing_conversation = conversation.scammer.for_account(@email_account).create!
    email_message.with_id("duplicate-123").for_conversation(existing_conversation).create!

    # Process duplicate
    duplicate_email = mock_scam_email.tap { |m| m.stubs(:message_id).returns("duplicate-123") }
    mock_mail_fetch(duplicate_email)

    assert_no_difference "EmailMessage.count" do
      EmailFetcherJob.new.perform
    end
  end

  private

  def assert_email_stored_correctly(message)
    assert_equal "Urgent: Transfer $10 Million", message.subject
    assert_equal "inbound", message.direction
    assert_equal "scam-email-123", message.message_id
  end

  def assert_conversation_created_correctly(conversation)
    assert_equal "prince@nigeria.fake", conversation.email_contact
    assert_equal "active", conversation.status
    assert_not_nil conversation.email_account
  end

  def assert_scam_detected_correctly(conversation)
    assert_equal "scammer", conversation.classification
  end
end
