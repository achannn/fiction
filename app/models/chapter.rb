class Chapter < ApplicationRecord
  belongs_to :story

  validates :number, presence: true, uniqueness: {scope: :story_id}

  def prev
    Chapter.find_by(story_id: story_id, number: number-1)
  end
  def next
    Chapter.find_by(story_id: story_id, number: number+1)
  end
end
