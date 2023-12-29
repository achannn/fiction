class ApplicationController < ActionController::Base
  before_action :authenticate_user!, :set_current_user,
                :set_user_signed_in
  before_action :configure_permitted_parameters, if: :devise_controller?

  def set_current_user
    @user = current_user
  end

  def set_user_signed_in
    @user_signed_in = user_signed_in?
  end

  protected

  def configure_permitted_parameters
    added_attrs = [:username, :email, :password, :password_confirmation, :remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end
end
