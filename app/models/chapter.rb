class Chapter < ApplicationRecord
  has_many :chats, dependent: :destroy

  belongs_to :story

  before_validation :add_chapter_number, on: :create
  before_destroy :can_destroy?

  validates :number, presence: true, uniqueness: {scope: :story_id}

  def prev
    Chapter.find_by(story_id: story_id, number: number-1)
  end
  def next
    Chapter.find_by(story_id: story_id, number: number+1)
  end

  private

  def add_chapter_number
    last_chapter = story.last_chapter
    self.number = last_chapter.nil? ? 1 : last_chapter.number+1
  end

  def can_destroy?
    if number != story.last_chapter.number
      self.errors.add(:base, "can only delete the last chapter")
      raise InvalidDestroyCall.new("can only delete the last chapter")
    end
  end
end

class InvalidDestroyCall < StandardError
end
