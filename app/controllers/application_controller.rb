class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  #before_action :turbo_frame_request_variant

  #dokimh gia na doulepsei to current_user tou devise otan kanw broadcasts
  #def current_user
  #  super
  #rescue Devise::MissingWarden
  #  nil
  #end

  protected

  def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :username])
      devise_parameter_sanitizer.permit(:account_update, keys: [:username, :avatar])
  end

  #def turbo_frame_request_variant
    # otan to request einai turbo_frame, o controller kanei respond me ena turbo_frame variant (index.html+turbo_frame.erb), anti gia to .html content.
  #  request.variant = :turbo_frame if turbo_frame_request? # turbo_frame_request? anagnwrizei eiserxomena Turbo Frame requests
  #end
end
