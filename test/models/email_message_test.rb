require "test_helper"

class EmailMessageTest < ActiveSupport::TestCase
  def setup
    @email_message = email_messages(:one)
  end

  test "should belong to conversation" do
    assert_respond_to @email_message, :conversation
  end

  test "should have email_account through conversation" do
    assert_respond_to @email_message, :email_account
    assert_equal @email_message.conversation.email_account, @email_message.email_account
  end

  test "should validate presence of required fields" do
    message = EmailMessage.new
    assert_not message.valid?
    assert_includes message.errors[:subject], "can't be blank"
    assert_includes message.errors[:body], "can't be blank"
    assert_includes message.errors[:message_id], "can't be blank"
  end

  test "should validate direction values" do
    @email_message.direction = "invalid_direction"
    assert_not @email_message.valid?
    assert_includes @email_message.errors[:direction], "is not included in the list"
  end

  test "should validate unique message_id" do
    duplicate = email_message
      .with_id(@email_message.message_id)
      .for_conversation(conversations(:two))
      .build

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:message_id], "has already been taken"
  end

  test "text_content should strip HTML and format text" do
    message = email_message
      .with_body("<p>This is a <strong>test</strong> message.</p><script>alert('bad');</script>")
      .for_conversation(conversations(:one))
      .build

    text = message.text_content

    assert_not_includes text, "<p>"
    assert_not_includes text, "<strong>"
    assert_not_includes text, "<script>"
    assert_includes text, "This is a test message"
  end

  test "text_content should normalize whitespace" do
    message = email_message
      .with_body("This  has    multiple   spaces.\n\n\n\nAnd many newlines.")
      .for_conversation(conversations(:one))
      .build

    text = message.text_content

    assert_not_includes text, "  " # no double spaces
    assert_not_includes text, "\n\n\n" # no triple newlines
  end
end
