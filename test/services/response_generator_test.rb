require "test_helper"

class ResponseGeneratorTest < ActiveSupport::TestCase
  def setup
    @conversation = conversations(:one)
    @persona = personas(:one)
    @generator = ResponseGenerator.new(@conversation, @persona)
  end

  test "generates response using persona" do
    expected_response = "I'm very interested in your business proposal! Please tell me more details."
    mock_response_generation(text: expected_response)

    response = @generator.generate

    assert_equal expected_response, response
  end

  test "uses persona description in system prompt" do
    expected_prompt = @persona.description

    assert_equal expected_prompt, @generator.send(:system_prompt)
  end

  test "uses default prompt when no persona and email account has no persona" do
    @conversation.email_account.stubs(:persona).returns(nil)
    generator = ResponseGenerator.new(@conversation, nil)

    prompt = generator.send(:system_prompt)

    assert_includes prompt, "scambaiting operation"
    assert_includes prompt, "waste scammers' time"
  end

  test "uses conversation email account persona when no persona provided" do
    generator = ResponseGenerator.new(@conversation)

    prompt = generator.send(:system_prompt)

    assert_equal @conversation.email_account.persona.description, prompt
  end

  test "builds conversation history correctly" do
    email_message
      .with_subject("Re: Business proposal")
      .with_body("Thank you for your interest. Here are more details...")
      .for_conversation(@conversation)
      .create!

    history = @generator.send(:conversation_history)

    assert_includes history, "Scammer: Dear sir/madam, I have a business proposal"
    assert_includes history, "Scammer: Thank you for your interest"
  end

  test "limits conversation history to last 5 messages" do
    # Create 6 additional messages
    6.times do |i|
      email_message
        .with_subject("Message #{i}")
        .with_body("Content #{i}")
        .for_conversation(@conversation)
        .create!
    end

    history = @generator.send(:conversation_history)
    lines = history.split("\n\n")

    assert_operator lines.length, :<=, 5
  end

  test "handles LLM API errors gracefully" do
    stub_llm_error

    response = @generator.generate

    assert_equal "I'm interested in learning more about your offer. Could you please provide additional details?", response
  end

  test "formats conversation history with correct labels" do
    email_message
      .with_subject("Re: Business proposal")
      .with_body("I'm interested. Please provide more details.")
      .outbound
      .for_conversation(@conversation)
      .create!

    history = @generator.send(:conversation_history)

    assert_includes history, "Scammer:"
    assert_includes history, "You:"
  end

  test "handles empty conversation" do
    empty_conversation = conversation
      .from("empty@test.com")
      .for_account(@conversation.email_account)
      .create!
    generator = ResponseGenerator.new(empty_conversation, @persona)

    history = generator.send(:conversation_history)

    assert_equal "", history
  end
end
