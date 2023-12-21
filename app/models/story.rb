class Story < ApplicationRecord
  has_many :chapters

  before_validation :generate_unique_code, on: :create

  validates :title, presence: true
  validates :summary, presence: true
  validates :code, presence: true, uniqueness: true

  def generate_unique_code
    loop do
      self.code = SecureRandom.hex(3)
      break unless Story.exists?(code: self.code)
    end
  end
end
