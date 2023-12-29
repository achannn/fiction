class User < ApplicationRecord
  has_many :stories, foreign_key: :author_id

  validates :username, presence: true, uniqueness: true, format: {with: /\A[A-Za-z0-9]+\z/, message: 'must be alphanumeric'}

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable
end
