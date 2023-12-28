class StoriesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @stories = Story.all.order(updated_at: :desc)
  end

  def show
    @story = Story.find_by(code: params[:code])
  end

  def new
    @story = Story.new
  end

  def create
    @story = Story.new(story_params)
    if @story.save
      redirect_to story_path(@story.code)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @story = Story.find_by(code: params[:code])
  end

  def update
    @story = Story.find(params[:code])
    if @story.update(story_params)
      redirect_to story_path(@story.code)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @story = Story.find_by(code: params[:code])
    @story.destroy
    redirect_to stories_path, status: :see_other
  end

  private
  def story_params
    params.require(:story).permit(:title, :summary)
  end
end
