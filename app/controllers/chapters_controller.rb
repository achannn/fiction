class ChaptersController < ApplicationController
  def show
    @chapter = Chapter.find_by(story_id: params[:story_id], number: params[:number])
  end
end
