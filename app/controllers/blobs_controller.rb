class BlobsController < ApplicationController
  def new
    @blob = @user.stories.find_by!(code: params[:story_code]).blobs.new
    @back_url = edit_story_path(@blob.story.code)
  end

  def create
    story = @user.stories.find_by!(code: params[:story_code])
    @blob = story.blobs.new(blob_params)
    if @blob.save
      redirect_to edit_story_blob_path(story.code, @blob.id)
    else
      @back_url = edit_story_path(@blob.story.code)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @blob = get_blob
    @back_url = edit_story_path(@blob.story.code)
  end

  def update
    @blob = get_blob
    if @blob.update(blob_params)
      redirect_to edit_story_blob_path(@blob.story.code, @blob.id)
    else
      @back_url = edit_story_path(@blob.story.code)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    blob = get_blob
    blob.destroy
    redirect_to edit_story_path(blob.story.code)
  end

  private

  def get_blob
    Blob.joins(:story)
      .joins("JOIN users ON users.id = stories.author_id")
      .where(stories: {code: params[:story_code]})
      .where(blobs: {id: params[:id]})
      .where(users: {id: @user.id})
      .first!
  end

  def blob_params
    params.require(:blob).permit(:title, :body)
  end
end
