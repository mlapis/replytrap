class SendResponseJob < ApplicationJob
  def perform(conversation_id)
    conversation = Conversation.find(conversation_id)
    return unless can_respond?(conversation)

    response_content = generate_response(conversation)
    send_response(conversation, response_content)
  end

  private

  def can_respond?(conversation)
    !conversation.waiting_for_answer? &&
      conversation.classification == "scammer" &&
      conversation.status == "active" &&
      conversation.email_account.active? &&
      conversation.email_account.status == "connected"
  end

  def generate_response(conversation)
    ResponseGenerator.new(conversation).generate
  end

  def send_response(conversation, content)
    last_message = conversation.email_messages.order(:created_at).last
    message_id = EmailMessage.generate_message_id(conversation.email_account)
    subject = last_message.reply_subject

    sender = EmailSender.new(conversation.email_account)
    success = sender.send_email(
      to: conversation.email_contact,
      subject: subject,
      body: content,
      message_id: message_id
    )

    if success
      conversation.email_messages.create!(
        direction: "outbound",
        subject: subject,
        body: content,
        message_id: message_id
      )
    end
  end
end
