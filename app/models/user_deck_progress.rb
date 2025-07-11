class UserDeckProgress < ApplicationRecord
  belongs_to :user
  belongs_to :deck
  
  validates :user_id, uniqueness: { scope: :deck_id }
  validates :total_sentences, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :completed_sentences, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :progress_percentage, presence: true, numericality: { in: 0..100 }
  
  before_save :calculate_progress_percentage
  
  scope :by_progress, ->(min_progress) { where('progress_percentage >= ?', min_progress) }
  scope :completed, -> { where(progress_percentage: 100) }
  
  private
  
  def calculate_progress_percentage
    if total_sentences > 0
      self.progress_percentage = (completed_sentences.to_f / total_sentences * 100).round(2)
    else
      self.progress_percentage = 0
    end
  end
end
