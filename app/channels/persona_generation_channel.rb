class PersonaGenerationChannel < ApplicationCable::Channel
  def subscribed
    stream_from "persona_generation_#{params[:job_id]}"
  end
end
