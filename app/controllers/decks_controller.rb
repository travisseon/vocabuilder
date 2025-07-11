class DecksController < ApplicationController
  before_action :require_login
  before_action :set_deck, only: [:show]
  
  def index
    @decks = Deck.all.includes(:sentences)
    @user_deck_progresses = current_user.user_deck_progresses.includes(:deck)
  end

  def show
    @sentences = @deck.sentences.includes(:words)
    @user_progress = current_user.user_deck_progresses.find_or_create_by(deck: @deck) do |progress|
      progress.total_sentences = @deck.sentences.count
      progress.completed_sentences = 0
      progress.study_time = 0
    end
    
    # 다음 학습할 문장 찾기
    completed_sentence_ids = current_user.learning_records
                                       .joins(:sentence)
                                       .where(sentences: { deck: @deck })
                                       .where(status: ['learned', 'mastered'])
                                       .pluck(:sentence_id)
    
    @next_sentence = @deck.sentences.where.not(id: completed_sentence_ids).first
    @completed_sentences = @deck.sentences.where(id: completed_sentence_ids)
  end
  
  private
  
  def set_deck
    @deck = Deck.find(params[:id])
  end
end
