class ReviewsController < ApplicationController
  before_action :require_login
  
  def index
    begin
      @review_stats = SpacedRepetitionService.review_stats_for_user(current_user)
      @due_reviews = SpacedRepetitionService.get_due_reviews_for_user(current_user).limit(10)
    rescue NameError => e
      Rails.logger.error "SpacedRepetitionService not loaded: #{e.message}"
      @review_stats = { today_due: 0, overdue: 0, total_reviews: 0 }
      @due_reviews = []
    end
    @daily_quote = DailyQuote.today_quote
  end
  
  def show
    @learning_record = current_user.learning_records.find(params[:id])
    @sentence = @learning_record.sentence
    @deck = @sentence.deck
    
    # 복습 세션 시작
    @words = @sentence.words.includes(:sentence)
    @correct_words = @words.correct_words.ordered
    @distractor_words = @words.distractor_words
    @all_words = (@correct_words + @distractor_words).shuffle
    
    # 복습 시작 시간 기록
    session[:review_start_time] = Time.current.to_i
    
    render 'sentences/show'
  end
  
  def check_answer
    @learning_record = current_user.learning_records.find(params[:id])
    @sentence = @learning_record.sentence
    
    user_answer = params[:user_answer] || []
    correct_answer = @sentence.words.correct_words.ordered.pluck(:word)
    
    @learning_record.attempts_count += 1
    
    if user_answer == correct_answer
      @learning_record.correct_count += 1
      
      # 복습 시간 계산 및 기록
      review_time = calculate_review_time
      @learning_record.study_time += review_time
      @learning_record.last_studied_at = Time.current
      
      @learning_record.save!
      
      # SRS 시스템 적용 - 복습에서는 더 엄격한 품질 점수
      quality_score = calculate_review_quality_score(@learning_record)
      
      # 복습 완료 처리 및 다음 복습 일정 생성
      srs_service = SpacedRepetitionService.new(@learning_record)
      srs_service.mark_review_completed
      srs_service.schedule_next_review(quality_score)
      
      # 사용자 통계 업데이트
      update_user_review_statistics(review_time)
      
      render json: { 
        success: true, 
        correct_sentence: @sentence.english_text,
        korean_sentence: @sentence.korean_text,
        quality_score: quality_score,
        is_review: true,
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
      
      # 틀린 경우 - 학습 상태로 되돌림
      quality_score = 0
      srs_service = SpacedRepetitionService.new(@learning_record)
      srs_service.schedule_next_review(quality_score)
      
      render json: { 
        success: false, 
        message: "아직 완전히 기억하지 못하셨네요. 다시 한번 학습해보세요!",
        attempts: @learning_record.attempts_count,
        is_review: true
      }
    end
  end
  
  def complete
    # 다음 복습 문장으로 이동 또는 복습 세션 완료
    next_review = SpacedRepetitionService.get_due_reviews_for_user(current_user).first
    
    if next_review
      redirect_to review_path(next_review)
    else
      redirect_to reviews_path, notice: "오늘의 복습을 모두 완료했습니다! 🎉"
    end
  end
  
  private
  
  def calculate_review_time
    return 0 unless session[:review_start_time]
    
    review_time = Time.current.to_i - session[:review_start_time].to_i
    session.delete(:review_start_time)
    [review_time, 0].max
  end
  
  def calculate_review_quality_score(learning_record)
    # 복습에서는 더 엄격한 기준 적용
    if learning_record.attempts_count == 1
      5 # 완벽 기억
    elsif learning_record.attempts_count == 2
      3 # 약간의 망설임
    else
      1 # 기억이 희미함
    end
  end
  
  def update_user_review_statistics(review_time)
    current_user.total_study_time += review_time
    current_user.last_study_date = Date.current
    
    # 연속 학습 일수 업데이트
    if current_user.last_study_date == Date.current - 1.day
      current_user.streak_days += 1
    elsif current_user.last_study_date != Date.current
      current_user.streak_days = 1
    end
    
    current_user.save!
  end
end