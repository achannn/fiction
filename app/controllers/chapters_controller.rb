class ChaptersController < ApplicationController
  def show
    @story = Story.find_by(code: params[:story_code])
    @chapter = Chapter.find_by(story_id: @story.id, number: params[:number])
  end
end
