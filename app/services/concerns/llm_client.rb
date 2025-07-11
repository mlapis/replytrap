module LlmClient
  extend ActiveSupport::Concern

  private

  def llm_client
    @llm_client ||= if use_local_llm?
      OpenAI::Client.new(
        access_token: "ollama",
        uri_base: ENV.fetch("OLLAMA_URL", "http://localhost:11434") + "/v1"
      )
    else
      OpenAI::Client.new(
        access_token: ENV["LLM_API_KEY"],
        uri_base: ENV.fetch("LLM_BASE_URL", "https://api.groq.com/openai/v1")
      )
    end
  end

  def llm_model
    if use_local_llm?
      ENV.fetch("OLLAMA_MODEL", "llama3.2:3b")
    else
      ENV["LLM_MODEL"]
    end
  end

  def use_local_llm?
    ENV["USE_LOCAL_LLM"] == "true"
  end

  def generate_response(messages:, **options)
    llm_client.chat(
      parameters: {
        model: llm_model,
        messages: messages,
        **options
      }
    )
  end
end
