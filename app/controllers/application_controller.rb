class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: %i[name username email password password_confirmation profile_image])
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name username email password password_confirmation profile_image])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name username email password password_confirmation current_password profile_image])
  end

end
