class ChaptersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]

  def show
    @chapter = Chapter.joins(:story)
                      .where(stories: {code: params[:story_code]})
                      .where(chapters: {number: params[:number]})
                      .first!
    @prev = @chapter.prev
    @next = @chapter.next

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
  end

  def create
    ActiveRecord::Base.transaction do
      story = @user.stories.find_by!(code: params[:story_code])
      chapter = story.chapters.new(chapter_params)
      if chapter.save
        redirect_to story_chapter_path(story.code, chapter.number)
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def edit
    @chapter = get_chapter
  end

  def update
    chapter = get_chapter
    if chapter.update(chapter_params)
      redirect_to story_chapter_path(chapter.story.code, chapter.number)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      @chapter = get_chapter
      begin
        @chapter.destroy
        redirect_to story_path(@chapter.story.code)
      rescue InvalidDestroyCall
        render :show, status: :bad_request
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
