class ResponseGenerator
  include LlmClient

  def initialize(conversation, persona = nil)
    @conversation = conversation
    @persona = persona || conversation.email_account.persona
  end

  def generate
    response = generate_response(
      messages: [
        { role: "system", content: system_prompt },
        { role: "user", content: conversation_history }
      ],
      max_tokens: 300,
      temperature: 0.8
    )

    response.dig("choices", 0, "message", "content")
  rescue => e
    "I'm interested in learning more about your offer. Could you please provide additional details?"
  end

  private

  def system_prompt
    if @persona
      @persona.description
    else
      default_prompt
    end
  end

  def default_prompt
    <<~PROMPT
      You are responding to a scam email as part of a scambaiting operation to waste scammers' time.#{' '}
      Your goal is to appear interested but ask for more information to keep the scammer engaged.

      Guidelines:
      - Show interest but be slightly skeptical
      - Ask for clarification or additional details
      - Use simple, believable language
      - Don't be too eager or suspicious
      - Keep responses conversational and natural
      - Avoid technical jargon

      Respond as if you're a potential victim who is cautiously interested.
    PROMPT
  end

  def conversation_history
    messages = @conversation.email_messages.order(:created_at).last(5)

    content = []
    messages.each do |message|
      label = message.direction == "inbound" ? "Scammer" : "You"
      content << "#{label}: #{message.text_content}"
    end

    content.join("\n\n")
  end
end
