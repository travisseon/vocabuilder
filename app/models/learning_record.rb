class LearningRecord < ApplicationRecord
  belongs_to :user
  belongs_to :sentence
  has_many :review_schedules, dependent: :destroy
  
  enum :status, { not_started: 0, learning: 1, learned: 2, mastered: 3 }
  
  validates :user_id, uniqueness: { scope: :sentence_id }
  
  scope :due_for_review, -> { joins(:review_schedules).where(review_schedules: { scheduled_date: ..Date.current, completed: false }) }
  scope :by_status, ->(status) { where(status: status) }
  
  def next_review_date
    review_schedules.pending.order(:scheduled_date).first&.scheduled_date
  end
  
  def next_review_time_text
    next_date = next_review_date
    return "복습 완료" unless next_date
    
    days_until = (next_date - Date.current).to_i
    
    case days_until
    when 0
      "오늘 복습"
    when 1
      "내일 복습"
    when 2..6
      "#{days_until}일 후 복습"
    else
      "#{next_date.strftime('%m/%d')} 복습"
    end
  end
end
