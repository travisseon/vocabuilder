class User < ApplicationRecord
  has_secure_password
  
  has_many :learning_records, dependent: :destroy
  has_many :user_deck_progresses, dependent: :destroy
  has_many :user_achievements, dependent: :destroy
  has_many :sentences, through: :learning_records
  has_many :decks, through: :user_deck_progresses
  
  validates :email, presence: true, uniqueness: true
  validates :nickname, presence: true
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?
  
  private
  
  def password_required?
    password_digest.blank? || password.present?
  end
end
