module LlmTestHelper
  def mock_llm_response(content)
    response = {
      "choices" => [
        {
          "message" => {
            "content" => content
          }
        }
      ]
    }

    if defined?(@detector)
      @detector.stubs(:generate_response).returns(response)
    elsif defined?(@generator)
      @generator.stubs(:generate_response).returns(response)
    else
      # For any class that includes LlmClient
      subject.stubs(:generate_response).returns(response) if respond_to?(:subject)
    end

    response
  end

  def mock_scam_detection(confidence:)
    mock_llm_response(%Q({"confidence": "#{confidence}"}))
  end

  def mock_response_generation(text:)
    mock_llm_response(text)
  end

  def stub_llm_error
    error = StandardError.new("API Error")

    if defined?(@detector)
      @detector.stubs(:generate_response).raises(error)
    elsif defined?(@generator)
      @generator.stubs(:generate_response).raises(error)
    else
      subject.stubs(:generate_response).raises(error) if respond_to?(:subject)
    end
  end
end
