class StoriesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @stories = Story.all.order(updated_at: :desc)
  end

  def show
    @story = Story.find_by!(code: params[:code])
    @back_url = root_path
  end

  def new
    @story = @user.stories.new
    @back_url = write_path
  end

  def create
    story = @user.stories.new(story_params)
    if story.save
      redirect_to edit_story_path(story.code)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @story = @user.stories.find_by!(code: params[:code])
    @back_url = write_path
  end

  def update
    story = @user.stories.find_by!(code: params[:code])
    if story.update(story_params)
      redirect_to edit_story_path(story.code)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    story = @user.stories.find_by!(code: params[:code])
    story.destroy
    redirect_to '/write', status: :see_other
  end

  private

  def story_params
    params.require(:story).permit(:title, :summary)
  end
end
