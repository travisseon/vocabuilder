class VerbExplanation < ApplicationRecord
  belongs_to :sentence
  
  validates :verb, presence: true
  validates :explanation, presence: true
  
  scope :by_verb, ->(verb) { where(verb: verb) }
end
