class ChaptersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]
  before_action :check_author_using_code, only: [:new, :edit, :destroy]
  before_action :check_author_using_id, only: [:create, :update]

  def show
    @chapter = Chapter.joins(:story)
                      .where(stories: {code: params[:story_code]})
                      .where(chapters: {number: params[:number]})
                      .first
    @prev = @chapter.prev
    @next = @chapter.next
  end

  def new
    @story = @user.stories.find_by(code: params[:story_code])
    @chapter = @story.chapters.new(number: @story.next_chapter_number)
  end

  def create
    story = @user.stories.find(params[:story_code])
    chapter = story.chapters.new(chapter_params)
    chapter.number = story.next_chapter_number
    if chapter.save
      redirect_to story_chapter_path(story.code, chapter.number)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @chapter = Chapter.joins(:story)
                      .where(stories: {code: params[:story_code]})
                      .where(chapters: {number: params[:number]})
                      .first
  end

  def update
    chapter = Chapter.find(params[:number])
    if chapter.update(chapter_params)
      redirect_to story_chapter_path(chapter.story.code, chapter.number)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    chapter = Chapter.joins(:story)
                      .where(stories: {code: params[:story_code]})
                      .where(chapters: {number: params[:number]})
                      .first

    if chapter.story.last_chapter.number == chapter.number
      chapter.destroy
      redirect_to story_path(chapter.story.code)
    else
      render :show, status:400
    end
  end

  def check_author_using_code
    author = User.joins("JOIN stories ON stories.author_id = users.id AND stories.code = '#{params[:story_code]}'").first
    redirect_to(root_path, status: :forbidden) unless author == current_user
  end

  def check_author_using_id
    author = User.joins("JOIN stories ON stories.author_id = users.id AND stories.id = '#{params[:story_code]}'").first
    redirect_to(root_path, status: :forbidden) unless author == current_user
  end

  private
  def chapter_params
    params.require(:chapter).permit(:title, :body)
  end
end
