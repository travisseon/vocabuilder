class Deck < ApplicationRecord
  has_many :sentences, dependent: :destroy
  has_many :user_deck_progresses, dependent: :destroy
  has_many :users, through: :user_deck_progresses
  
  validates :name, presence: true
  validates :difficulty_level, inclusion: { in: 1..5 }
end
