class ConversationsController < ApplicationController
  before_action :set_conversation, only: %i[ show destroy generate_response send_reply toggle_status ]

  # GET /conversations or /conversations.json
  def index
    @mode = params[:mode] == "all" ? "all" : "scammers"
    
    @conversations = if @mode == "all"
      current_user.conversations
    else
      current_user.conversations.where(classification: "scammer")
    end
  end

  # GET /conversations/1 or /conversations/1.json
  def show
    @can_reply = @conversation.classification == "scammer" && !@conversation.waiting_for_answer?
  end


  # DELETE /conversations/1 or /conversations/1.json
  def destroy
    @conversation.destroy!

    respond_to do |format|
      format.html { redirect_to conversations_path, status: :see_other, notice: "Conversation was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # POST /conversations/1/generate_response
  def generate_response
    cancel_scheduled_jobs(@conversation)
    @generated_response = ResponseGenerator.new(@conversation).generate

    respond_to do |format|
      format.json { render json: { response: @generated_response } }
    end
  end

  # POST /conversations/1/send_reply
  def send_reply
    response_text = params[:response_text]

    last_message = @conversation.email_messages.order(:created_at).last
    message_id = EmailMessage.generate_message_id(@conversation.email_account)
    subject = last_message.reply_subject

    sender = EmailSender.new(@conversation.email_account)
    success = sender.send_email(
      to: @conversation.email_contact,
      subject: subject,
      body: response_text,
      message_id: message_id
    )

    if success
      @conversation.email_messages.create!(
        direction: "outbound",
        subject: subject,
        body: response_text,
        message_id: message_id
      )
      redirect_to @conversation, notice: "Reply sent!"
    else
      redirect_to @conversation, alert: "Failed to send reply"
    end
  end

  def toggle_status
    new_status = @conversation.status == "active" ? "paused" : "active"
    @conversation.update!(status: new_status)

    redirect_to @conversation, notice: "Conversation #{new_status}!"
  end

  def fetch_emails
    EmailFetcherJob.perform_now
    redirect_to conversations_path, notice: "Conversations sync complete"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_conversation
      @conversation = current_user.conversations.find(params.expect(:id))
    end


    def cancel_scheduled_jobs(conversation)
      SolidQueue::Job.where(
        class_name: "SendResponseJob",
        arguments: [ conversation.id ]
      ).scheduled.destroy_all
    end
end
