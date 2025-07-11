class PersonaGenerationJob < ApplicationJob
  def perform(job_id)
    result = PersonaGenerator.new.generate

    ActionCable.server.broadcast(
      "persona_generation_#{job_id}",
      result.merge(status: "completed")
    )
  rescue => e
    ActionCable.server.broadcast(
      "persona_generation_#{job_id}",
      { status: "error", error: e.message }
    )
  end
end
