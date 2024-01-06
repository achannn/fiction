class ChaptersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]

  def show
    @chapter = Chapter.joins(:story)
                      .where(stories: {code: params[:story_code]})
                      .where(chapters: {number: params[:number]})
                      .first!
    @prev = @chapter.prev
    @next = @chapter.next
    @back_url = story_path(@chapter.story.code)


    @cable_url = "wss:#{ENV.fetch("RENDER_EXTERNAL_HOSTNAME") { "localhost:3000" }}/cable"

    @chat_history = []
    if user_signed_in?
      chat = Chat.create_or_find_by!(chapter: @chapter, user: @user)
      chat.get_history.each do |message|
        @chat_history << ChatsChannel::Message.new(
          chat_message: message,
          user: message.user,
        )
      end
    end
  end

  def new
    @chapter = @user.stories.find_by!(code: params[:story_code]).chapters.new
    @back_url = edit_story_path(@chapter.story.code)
  end

  def create
    ActiveRecord::Base.transaction do
      story = @user.stories.find_by!(code: params[:story_code])
      @chapter = story.chapters.new(chapter_params)
      if @chapter.save
        redirect_to edit_story_chapter_path(story.code, @chapter.number)
      else
        @back_url = edit_story_path(@chapter.story.code)
        render :new, status: :unprocessable_entity
      end
    end
  end

  def edit
    @chapter = get_chapter
    @back_url = edit_story_path(@chapter.story.code)
  end

  def update
    @chapter = get_chapter
    if @chapter.update(chapter_params)
      redirect_to edit_story_chapter_path(@chapter.story.code, @chapter.number)
    else
      @back_url = edit_story_path(@chapter.story.code)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      @chapter = get_chapter
      begin
        @chapter.destroy
        redirect_to edit_story_path(@chapter.story.code)
      rescue InvalidDestroyCall
        @back_url = edit_story_path(@chapter.story.code)
        render :edit, status: :bad_request
      end
    end
  end

  private

  def get_chapter
    Chapter.joins(:story)
           .joins("JOIN users ON users.id = stories.author_id")
           .where(stories: {code: params[:story_code]})
           .where(chapters: {number: params[:number]})
           .where(users: {id: @user.id})
           .first!
  end

  def chapter_params
    params.require(:chapter).permit(:title, :body)
  end
end
