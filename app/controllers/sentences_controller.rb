class SentencesController < ApplicationController
  before_action :require_login
  before_action :set_deck_and_sentence, only: [:show, :check_answer, :complete, :sentence_data]
  before_action :set_learning_record, only: [:show, :check_answer, :complete]
  
  def show
    @words = @sentence.words.includes(:sentence)
    @correct_words = @words.correct_words.ordered
    @distractor_words = @words.distractor_words
    @all_words = (@correct_words + @distractor_words).shuffle
    
    # 학습 시작 시간 기록 (세션에 저장)
    session[:learning_start_time] = Time.current.to_i
  end

  def check_answer
    user_answer = params[:user_answer] || []
    correct_answer = @sentence.words.correct_words.ordered.pluck(:word)
    
    @learning_record.attempts_count += 1
    
    if user_answer == correct_answer
      @learning_record.correct_count += 1
      @learning_record.first_attempt_correct = true if @learning_record.attempts_count == 1
      
      # 학습 시간 계산 및 기록
      study_time = calculate_study_time
      @learning_record.study_time += study_time
      @learning_record.last_studied_at = Time.current
      
      @learning_record.save!
      
      # SRS 시스템 적용 - 품질 점수 계산
      quality_score = calculate_quality_score(@learning_record)
      
      # 복습 일정 생성
      srs_service = SpacedRepetitionService.new(@learning_record)
      srs_service.mark_review_completed  # 현재 복습 완료 처리
      srs_service.schedule_next_review(quality_score)
      
      # 사용자 통계 업데이트
      update_user_study_statistics(study_time)
      
      # 덱 진행률 업데이트
      update_deck_progress
      
      render json: { 
        success: true, 
        correct_sentence: @sentence.english_text,
        korean_sentence: @sentence.korean_text,
        quality_score: quality_score,
        verb_explanations: @sentence.verb_explanations.map do |explanation|
          {
            verb: explanation.verb,
            explanation: explanation.explanation,
            comparison: explanation.comparison,
            examples: explanation.examples
          }
        end
      }
    else
      @learning_record.save!
      
      # 틀린 경우에도 SRS 시스템 적용
      quality_score = 0 # 완전히 틀림
      srs_service = SpacedRepetitionService.new(@learning_record)
      srs_service.schedule_next_review(quality_score)
      
      render json: { 
        success: false, 
        message: "정답이 아닙니다. 다시 시도해보세요!",
        attempts: @learning_record.attempts_count
      }
    end
  end

  def complete
    # 다음 문장으로 이동 또는 완료 처리
    next_sentence = find_next_sentence
    
    if next_sentence
      redirect_to deck_sentence_path(@deck, next_sentence)
    else
      # 덱 완료 처리
      update_deck_progress
      redirect_to deck_path(@deck), notice: "축하합니다! #{@deck.name} 덱을 완료하셨습니다!"
    end
  end
  
  def sentence_data
    # 현재 문장의 데이터를 JSON으로 반환
    render json: {
      english_text: @sentence.english_text,
      korean_text: @sentence.korean_text,
      verb_explanations: @sentence.verb_explanations.map do |explanation|
        {
          verb: explanation.verb,
          explanation: explanation.explanation,
          comparison: explanation.comparison,
          examples: explanation.examples
        }
      end
    }
  end
  
  private
  
  def set_deck_and_sentence
    @deck = Deck.find(params[:deck_id])
    @sentence = @deck.sentences.find(params[:id])
  end
  
  def set_learning_record
    @learning_record = current_user.learning_records.find_or_create_by(sentence: @sentence) do |record|
      record.status = 'not_started'
      record.attempts_count = 0
      record.correct_count = 0
      record.first_attempt_correct = false
      record.study_time = 0
    end
  end
  
  def calculate_study_time
    return 0 unless session[:learning_start_time]
    
    study_time = Time.current.to_i - session[:learning_start_time].to_i
    session.delete(:learning_start_time)
    [study_time, 0].max # 음수 방지
  end
  
  def calculate_quality_score(learning_record)
    # SM-2 알고리즘 품질 점수 (0-5)
    # 5: 완벽 (첫 시도 성공)
    # 4: 망설임 후 정답 (2-3 시도)
    # 3: 어려움 후 정답 (3-4 시도)
    # 2: 많은 시도 후 정답 (4+ 시도)
    # 1: 힌트 사용 후 정답
    # 0: 틀림
    
    if learning_record.first_attempt_correct
      5 # 완벽
    elsif learning_record.attempts_count <= 2
      4 # 망설임 후 정답
    elsif learning_record.attempts_count <= 3
      3 # 어려움 후 정답
    else
      2 # 많은 시도 후 정답
    end
  end
  
  # 공통 메서드는 ApplicationController로 이동됨
  
  def find_next_sentence
    # 현재 문장보다 ID가 큰 문장 중에서 아직 완료하지 않은 첫 번째 문장 찾기
    completed_sentence_ids = current_user.learning_records
                                       .joins(:sentence)
                                       .where(sentences: { deck: @deck })
                                       .where(status: ['learning', 'learned', 'mastered'])
                                       .pluck(:sentence_id)
    
    # 현재 문장보다 ID가 큰 문장들 중에서 완료되지 않은 첫 번째 문장
    next_sentence = @deck.sentences
                        .where('id > ?', @sentence.id)
                        .where.not(id: completed_sentence_ids)
                        .order(:id)
                        .first
    
    # 현재 문장보다 ID가 큰 문장이 없으면, 전체에서 완료되지 않은 첫 번째 문장
    if next_sentence.nil?
      next_sentence = @deck.sentences
                          .where.not(id: completed_sentence_ids + [@sentence.id])
                          .order(:id)
                          .first
    end
    
    next_sentence
  end
  
  def update_deck_progress
    user_progress = current_user.user_deck_progresses.find_or_create_by(deck: @deck)
    
    completed_count = current_user.learning_records
                                 .joins(:sentence)
                                 .where(sentences: { deck: @deck })
                                 .where(status: ['learning', 'learned', 'mastered'])
                                 .count
    
    total_study_time = current_user.learning_records
                                  .joins(:sentence)
                                  .where(sentences: { deck: @deck })
                                  .sum(:study_time)
    
    user_progress.update!(
      total_sentences: @deck.sentences.count,
      completed_sentences: completed_count,
      study_time: total_study_time
    )
  end
end
