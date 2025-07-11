require "test_helper"

class ScamDetectorTest < ActiveSupport::TestCase
  def setup
    @email_message = email_messages(:one)
    @detector = ScamDetector.new(@email_message)
  end

  test "classifies high confidence scam correctly" do
    mock_scam_detection(confidence: "high")

    result = @detector.analyze

    assert_equal "high", result[:confidence]
    assert_equal "scammer", @email_message.conversation.reload.classification
  end

  test "classifies medium confidence as unknown" do
    mock_scam_detection(confidence: "medium")

    result = @detector.analyze

    assert_equal "medium", result[:confidence]
    assert_equal "unknown", @email_message.conversation.reload.classification
  end

  test "classifies low confidence as legitimate" do
    mock_scam_detection(confidence: "low")

    result = @detector.analyze

    assert_equal "low", result[:confidence]
    assert_equal "legitimate", @email_message.conversation.reload.classification
  end

  test "handles LLM API errors gracefully" do
    stub_llm_error

    result = @detector.analyze

    assert_equal "medium", result[:confidence]
    assert_equal "unknown", @email_message.conversation.reload.classification
  end

  test "handles malformed JSON response" do
    mock_llm_response("invalid json")

    result = @detector.analyze

    assert_equal "medium", result[:confidence]
    assert_equal "unknown", @email_message.conversation.reload.classification
  end

  test "builds correct email content for analysis" do
    expected_content = [
      "Subject: #{@email_message.subject}",
      "From: #{@email_message.conversation.email_contact}",
      "Body: #{@email_message.text_content}"
    ].join("\n\n")

    assert_equal expected_content, @detector.send(:email_content)
  end

  test "truncates long email content" do
    long_text = "word " * 150
    @email_message.stubs(:text_content).returns(long_text)

    truncated = @detector.send(:truncate_content, long_text, max_words: 100)

    assert_operator truncated.split.length, :<=, 100
  end
end
