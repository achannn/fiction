class ChaptersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]

  def show
    @chapter = Chapter.joins(:story)
                      .where(stories: {code: params[:story_code]})
                      .where(chapters: {number: params[:number]})
                      .first!
    @prev = @chapter.prev
    @next = @chapter.next
  end

  def new
    @story = @user.stories.find_by!(code: params[:story_code])
    @chapter = @story.chapters.new
  end

  def create
    ActiveRecord::Base.transaction do
      story = @user.stories.find(params[:story_code])
      last_chapter = story.last_chapter
      new_chapter_number = last_chapter.nil? ? 1 : last_chapter.number+1

      chapter = story.chapters.new(chapter_params)
      chapter.number = new_chapter_number
      if chapter.save
        redirect_to story_chapter_path(story.code, chapter.number)
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def edit
    @chapter = Chapter.joins(:story)
                      .joins("JOIN users ON users.id = stories.author_id")
                      .where(stories: {code: params[:story_code]})
                      .where(chapters: {number: params[:number]})
                      .where(users: {id: @user.id})
                      .first!
  end

  def update
    chapter = Chapter.joins(:story)
                     .joins("JOIN users ON users.id = stories.author_id")
                     .where(chapters: {id: params[:number]})
                     .where(users: {id: @user.id})
                     .first!
    if chapter.update(chapter_params)
      redirect_to story_chapter_path(chapter.story.code, chapter.number)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      chapter = Chapter.joins(:story)
                       .joins("JOIN users ON users.id = stories.author_id")
                       .where(stories: {code: params[:story_code]})
                       .where(chapters: {number: params[:number]})
                       .where(users: {id: @user.id})
                       .first!
      if chapter.story.last_chapter.number == chapter.number
        chapter.destroy
        redirect_to story_path(chapter.story.code)
      else
        render :show, status:400
      end
    end
  end

  private

  def chapter_params
    params.require(:chapter).permit(:title, :body)
  end
end
