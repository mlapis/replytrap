class ScamDetector
  include LlmClient

  def initialize(email_message)
    @email_message = email_message
  end

  def analyze
    response = generate_response(
      messages: [
        { role: "system", content: system_prompt },
        { role: "user", content: email_content }
      ],
      max_tokens: 50,
      n: 1
    )

    confidence = JSON.parse(response.dig("choices", 0, "message", "content"))["confidence"]
    update_conversation_classification(confidence)
    { confidence: confidence }
  rescue => e
    update_conversation_classification("medium")
    { confidence: "medium" }
  end

  private

  def system_prompt
    <<~PROMPT
      You are a scam detection system. Analyze emails sent to honeypot accounts (fake email addresses that shouldn't receive legitimate mail). Respond with ONLY a JSON object in this exact format:
      {"confidence": "high/medium/low"}

      Confidence levels:
      - high: definitely a scam
      - medium: probably a scam
      - low: probably not a scam

      Look for common scam indicators:
      - Unsolicited contact with no clear legitimate reason
      - Vague, probing messages
      - Generic greetings to unknown recipients
      - Claims of urgency without clear context
      - Poor grammar/spelling
      - Too-good-to-be-true offers
      - Impersonation attempts
    PROMPT
  end

  def email_content
    content = []
    content << "Subject: #{@email_message.subject}"
    content << "From: #{@email_message.conversation.email_contact}"
    content << "Body: #{truncate_content(@email_message.text_content)}"
    content.join("\n\n")
  end

  def truncate_content(text, max_words: 100)
    words = text.split
    return text if words.length <= max_words

    # Find the last complete sentence within word limit
    truncated = words.first(max_words).join(" ")
    last_sentence_end = truncated.rindex(/[.!?]/)

    if last_sentence_end
      truncated[0..last_sentence_end]
    else
      # If no sentence ending found, take the words up to limit
      words.first(max_words).join(" ")
    end
  end


  def update_conversation_classification(confidence)
    classification = { "high" => "scammer", "medium" => "unknown", "low" => "legitimate" }[confidence] || "unknown"
    @email_message.conversation.update!(classification: classification)
  end
end
