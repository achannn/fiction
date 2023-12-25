class ChaptersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]

  def show
    @chapter = Chapter.joins(:story)
                      .where(stories: {code: params[:story_code]})
                      .where(chapters: {number: params[:number]})
                      .first
    @is_last_chapter = @chapter.story.last_chapter.number == @chapter.number
  end

  def new
    @story = Story.find_by(code: params[:story_code])
    number = @story.last_chapter.nil? ? 1 : @story.last_chapter.number+1
    @chapter = @story.chapters.new(number: number)
  end

  def create
    @story = Story.find(params[:story_code])
    @chapter = @story.chapters.new(chapter_params)
    @chapter.number = @story.last_chapter.nil? ? 1 : @story.last_chapter.number+1
    if @chapter.save
      redirect_to story_chapter_path(@story.code, @chapter.number)
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
    @chapter = Chapter.find(params[:number])
    if @chapter.update(chapter_params)
      redirect_to story_chapter_path(@chapter.story.code, @chapter.number)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @chapter = Chapter.joins(:story)
                      .where(stories: {code: params[:story_code]})
                      .where(chapters: {number: params[:number]})
                      .first

    if @chapter.story.last_chapter.number == @chapter.number
      @chapter.destroy
      redirect_to story_path(@chapter.story.code)
    else
      render :show, status:400
    end
  end

  private
  def chapter_params
    params.require(:chapter).permit(:title, :body)
  end
end
