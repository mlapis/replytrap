class AutoResponseJob < ApplicationJob
  BASE_WAIT_TIME = 30.minutes

  def perform
    ready_conversations.each do |conversation|
      delay_minutes = calculate_response_delay
      #SendResponseJob.set(wait: delay_minutes.minutes).perform_later(conversation.id)
      SendResponseJob.perform_now(conversation.id)
    end
  end

  private

  def ready_conversations
    Conversation.joins(:email_account)
                .where(email_accounts: { active: true, status: "connected" })
                .where(classification: "scammer", status: "active")
                .select { |conv| !conv.waiting_for_answer? && enough_time_passed?(conv) && !response_already_queued?(conv) }
  end

  def enough_time_passed?(conversation)
    last_message = conversation.email_messages.order(:created_at).last
    Time.current - last_message.created_at > BASE_WAIT_TIME
  end

  def response_already_queued?(conversation)
    SolidQueue::Job.where(
      class_name: "SendResponseJob",
      finished_at: nil
    ).any? { |job| job.arguments.dig("arguments")&.first == conversation.id }
  end

  def calculate_response_delay
    case rand(1..10)
    when 1..6
      rand(15..120)        # 60% chance: 15-120 minutes (quick responses)
    when 7..8
      rand(4..12) * 60     # 20% chance: 4-12 hours (slow responses)
    when 9..10
      rand(24..48) * 60    # 20% chance: 1-2 days (very slow, annoying)
    end
  end
end
