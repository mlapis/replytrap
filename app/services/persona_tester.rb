class PersonaTester
  def initialize(description)
    @description = description
  end

  def test
    mock_conversation = create_mock_conversation
    mock_persona = Persona.new(description: @description)

    # Create a custom ResponseGenerator that uses our test email
    response_generator = ResponseGenerator.new(mock_conversation, mock_persona)
    def response_generator.conversation_history
      "Scammer: Dear Winner,\n\nCongratulations! You have been selected as the winner of $1,000,000 in our International Lottery Program. This is a legitimate lottery organized by the International Lottery Commission.\n\nTo claim your prize, please respond with:\n- Your full name\n- Your phone number\n- Your address\n- A copy of your ID\n\nWe need this information to process your winnings immediately.\n\nBest regards,\nDr. James Wilson\nInternational Lottery Commission"
    end

    response = response_generator.generate

    { response: response }
  end

  private

  def create_mock_conversation
    conversation = Conversation.new(
      email_contact: "dr.james.wilson@lottery-commission.com"
    )

    email_message = EmailMessage.new(
      subject: "Urgent: You have won $1,000,000 in the International Lottery",
      body: sample_spam_email,
      conversation: conversation,
      direction: "inbound",
      message_id: "test-lottery-email-#{Time.current.to_i}"
    )

    # Mock the email_messages method to return our test message
    def conversation.email_messages
      @mock_messages ||= []
    end

    conversation.email_messages << email_message
    conversation
  end

  def sample_spam_email
    <<~EMAIL
      Dear Winner,

      Congratulations! You have been selected as the winner of $1,000,000 in our International Lottery Program. This is a legitimate lottery organized by the International Lottery Commission.

      To claim your prize, please respond with:
      - Your full name
      - Your phone number#{'  '}
      - Your address
      - A copy of your ID

      We need this information to process your winnings immediately.

      Best regards,
      Dr. James Wilson
      International Lottery Commission
    EMAIL
  end
end
