class Word < ApplicationRecord
  belongs_to :sentence
  
  validates :word, presence: true
  validates :position, presence: true, uniqueness: { scope: :sentence_id }
  
  scope :correct_words, -> { where(is_distractor: false) }
  scope :distractor_words, -> { where(is_distractor: true) }
  scope :ordered, -> { order(:position) }
end
