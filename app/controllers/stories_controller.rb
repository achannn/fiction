class StoriesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :check_author_using_code, only: [:edit, :destroy]
  before_action :check_author_using_id, only: [:update]

  def index
    @stories = Story.all.order(updated_at: :desc)
  end

  def show
    @story = Story.find_by(code: params[:code])
  end

  def new
    @story = @user.stories.new
  end

  def create
    story = @user.stories.new(story_params)
    if story.save
      redirect_to story_path(story.code)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @story = @user.stories.find_by(code: params[:code])
  end

  def update
    story = @user.stories.find(params[:code])
    if story.update(story_params)
      redirect_to story_path(story.code)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    story = @user.stories.find_by(code: params[:code])
    story.destroy
    redirect_to stories_path, status: :see_other
  end

  def check_author_using_code
    author = User.joins("JOIN stories ON stories.author_id = users.id AND stories.code = '#{params[:code]}'").first
    redirect_to root_path, status: :forbidden unless author == current_user
  end

  def check_author_using_id
    author = User.joins("JOIN stories ON stories.author_id = users.id AND stories.id = '#{params[:code]}'").first
    redirect_to root_path, status: :forbidden unless author == current_user
  end

  private
  def story_params
    params.require(:story).permit(:title, :summary)
  end
end
