class ApplicationController < ActionController::Base
  before_action :authenticate_user!, :set_current_user,
                :set_user_signed_in

  def set_current_user
    @user = current_user
  end

  def set_user_signed_in
    @user_signed_in = user_signed_in?
  end
end
