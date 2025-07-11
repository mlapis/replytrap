class EmailAccountsController < ApplicationController
  before_action :set_email_account, only: %i[ edit update destroy ]

  # GET /email_accounts or /email_accounts.json
  def index
    @email_accounts = current_user.email_accounts
  end


  # GET /email_accounts/new
  def new
    @email_account = current_user.email_accounts.build
  end

  # GET /email_accounts/1/edit
  def edit
  end

  # POST /email_accounts or /email_accounts.json
  def create
    @email_account = current_user.email_accounts.build(email_account_params)

    respond_to do |format|
      if @email_account.save
        @email_account.test_and_update_connection_status
        if @email_account.status == "error"
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @email_account.errors, status: :unprocessable_entity }
        else
          format.html { redirect_to email_accounts_path, notice: "Email account was successfully created." }
          format.json { render :show, status: :created, location: @email_account }
        end
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @email_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /email_accounts/1 or /email_accounts/1.json
  def update
    params_to_update = email_account_params
    params_to_update.delete(:password) if params_to_update[:password].blank?

    respond_to do |format|
      if @email_account.update(params_to_update)
        @email_account.test_and_update_connection_status
        if @email_account.status == "error"
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @email_account.errors, status: :unprocessable_entity }
        else
          format.html { redirect_to email_accounts_path, notice: "Email account was successfully updated." }
          format.json { render :show, status: :ok, location: @email_account }
        end
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @email_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /email_accounts/1 or /email_accounts/1.json
  def destroy
    @email_account.destroy!

    respond_to do |format|
      format.html { redirect_to email_accounts_path, status: :see_other, notice: "Email account was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_email_account
      @email_account = current_user.email_accounts.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def email_account_params
      params.expect(email_account: [ :email, :fetch_server, :smtp_server, :username, :password, :fetch_protocol, :active, :last_checked_at, :status, :error_message, :user_id, :persona_id ])
    end
end
