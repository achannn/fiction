class DashboardController < ApplicationController
  def index
    @stories = @user.stories
  end
end
