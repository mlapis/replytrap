module TestDataBuilder
  class EmailAccountBuilder
    def initialize
      @attributes = {
        email: "test#{SecureRandom.hex(4)}@example.com",
        fetch_server: "imap.example.com:993",
        smtp_server: "smtp.example.com:587",
        username: "testuser",
        password: "testpass",
        fetch_protocol: "imap",
        status: "connected",
        active: true,
        user: nil,
        persona: nil
      }
    end

    def with_email(email)
      @attributes[:email] = email
      self
    end

    def with_protocol(protocol)
      @attributes[:fetch_protocol] = protocol
      case protocol
      when "pop3"
        @attributes[:fetch_server] = "pop.example.com:995"
      when "imap"
        @attributes[:fetch_server] = "imap.example.com:993"
      end
      self
    end

    def with_status(status)
      @attributes[:status] = status
      self
    end

    def for_user(user)
      @attributes[:user] = user
      self
    end

    def with_persona(persona)
      @attributes[:persona] = persona
      self
    end

    def disabled
      @attributes[:status] = "disabled"
      @attributes[:active] = false
      self
    end

    def build
      EmailAccount.new(@attributes)
    end

    def create!
      EmailAccount.create!(@attributes)
    end
  end

  class EmailMessageBuilder
    def initialize
      @attributes = {
        subject: "Test Subject",
        body: "Test message body",
        direction: "inbound",
        message_id: "test-#{SecureRandom.hex(6)}",
        conversation: nil
      }
    end

    def scam_email
      @attributes.merge!(
        subject: "Urgent Business Proposal",
        body: "Dear sir/madam, I have a business proposal of $10 million dollars..."
      )
      self
    end

    def legitimate_email
      @attributes.merge!(
        subject: "Newsletter Subscription",
        body: "Thank you for subscribing to our newsletter..."
      )
      self
    end

    def with_subject(subject)
      @attributes[:subject] = subject
      self
    end

    def with_body(body)
      @attributes[:body] = body
      self
    end

    def outbound
      @attributes[:direction] = "outbound"
      self
    end

    def for_conversation(conversation)
      @attributes[:conversation] = conversation
      self
    end

    def with_id(message_id)
      @attributes[:message_id] = message_id
      self
    end

    def build
      EmailMessage.new(@attributes)
    end

    def create!
      EmailMessage.create!(@attributes)
    end
  end

  class ConversationBuilder
    def initialize
      @attributes = {
        email_contact: "contact#{SecureRandom.hex(3)}@example.com",
        classification: "unknown",
        status: "active",
        email_account: nil
      }
    end

    def from(email_contact)
      @attributes[:email_contact] = email_contact
      self
    end

    def classified_as(classification)
      @attributes[:classification] = classification
      self
    end

    def scammer
      @attributes[:classification] = "scammer"
      @attributes[:email_contact] = "scammer#{SecureRandom.hex(3)}@badguys.com"
      self
    end

    def legitimate
      @attributes[:classification] = "legitimate"
      @attributes[:email_contact] = "legit#{SecureRandom.hex(3)}@company.com"
      self
    end

    def for_account(email_account)
      @attributes[:email_account] = email_account
      self
    end

    def build
      Conversation.new(@attributes)
    end

    def create!
      Conversation.create!(@attributes)
    end
  end

  def email_account
    EmailAccountBuilder.new
  end

  def email_message
    EmailMessageBuilder.new
  end

  def conversation
    ConversationBuilder.new
  end
end
