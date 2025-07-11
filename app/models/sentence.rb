class Sentence < ApplicationRecord
  belongs_to :deck
  has_many :words, dependent: :destroy
  has_many :learning_records, dependent: :destroy
  has_many :verb_explanations, dependent: :destroy
  has_many :users, through: :learning_records
  
  validates :korean_text, presence: true
  validates :english_text, presence: true
  validates :difficulty_level, inclusion: { in: 1..5 }
  
  scope :by_difficulty, ->(level) { where(difficulty_level: level) }
end
