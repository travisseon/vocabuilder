class DailyQuote < ApplicationRecord
  validates :english_text, presence: true
  validates :korean_text, presence: true
  
  scope :active, -> { where(is_active: true) }
  scope :for_date, ->(date) { where(display_date: date) }
  
  def self.today_quote
    active.for_date(Date.current).first || active.order(:created_at).first
  end
end
