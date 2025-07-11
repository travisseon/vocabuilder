class UserAchievement < ApplicationRecord
  belongs_to :user
  
  validates :achievement_type, presence: true
  validates :user_id, uniqueness: { scope: :achievement_type }
  
  scope :by_type, ->(type) { where(achievement_type: type) }
  scope :recent, -> { order(achieved_at: :desc) }
end
