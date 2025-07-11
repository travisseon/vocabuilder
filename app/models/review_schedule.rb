class ReviewSchedule < ApplicationRecord
  belongs_to :learning_record
  
  validates :scheduled_date, presence: true
  validates :interval_days, presence: true, numericality: { greater_than: 0 }
  validates :ease_factor, presence: true, numericality: { greater_than: 0 }
  
  scope :due_today, -> { where(scheduled_date: Date.current, completed: false) }
  scope :overdue, -> { where('scheduled_date < ? AND completed = ?', Date.current, false) }
  scope :pending, -> { where(completed: false) }
  scope :completed, -> { where(completed: true) }
end
