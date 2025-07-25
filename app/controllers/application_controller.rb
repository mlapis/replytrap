class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!, unless: -> { ENV["SINGLE_USER_MODE"] }
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :invite_code ])
  end

  def current_user
    if ENV["SINGLE_USER_MODE"]
      @current_user ||= User.first
    else
      super
    end
  end
end
