class StoriesController < ApplicationController
  def index
    @stories = Story.all
  end

  def show
    @story = Story.find_by(code: params[:code])
  end
end
