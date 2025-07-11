class PersonasController < ApplicationController
  before_action :set_persona, only: %i[ show edit update destroy ]

  # GET /personas or /personas.json
  def index
    @personas = current_user.personas
  end

  # GET /personas/1 or /personas/1.json
  def show
  end

  # GET /personas/new
  def new
    @persona = current_user.personas.build
  end

  # GET /personas/1/edit
  def edit
  end

  # POST /personas or /personas.json
  def create
    @persona = current_user.personas.build(persona_params)

    respond_to do |format|
      if @persona.save
        format.html { redirect_to @persona, notice: "Persona was successfully created." }
        format.json { render :show, status: :created, location: @persona }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @persona.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /personas/1 or /personas/1.json
  def update
    respond_to do |format|
      if @persona.update(persona_params)
        format.html { redirect_to @persona, notice: "Persona was successfully updated." }
        format.json { render :show, status: :ok, location: @persona }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @persona.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /personas/1 or /personas/1.json
  def destroy
    @persona.destroy!

    respond_to do |format|
      format.html { redirect_to personas_path, status: :see_other, notice: "Persona was successfully destroyed." }
      format.json { head :no_content }
    end
  rescue ActiveRecord::DeleteRestrictionError
    respond_to do |format|
      format.html { redirect_to personas_path, alert: "Cannot delete persona because it is currently used by one or more email accounts." }
      format.json { render json: { error: "Cannot delete persona because it is currently used by one or more email accounts." }, status: :unprocessable_entity }
    end
  end

  def generate_random
    job_id = SecureRandom.uuid
    PersonaGenerationJob.perform_later(job_id)
    render json: { job_id: job_id }
  end

  def test
    render json: PersonaTester.new(params[:description]).test
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_persona
      @persona = current_user.personas.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def persona_params
      params.expect(persona: [ :name, :description, :user_id ])
    end
end
