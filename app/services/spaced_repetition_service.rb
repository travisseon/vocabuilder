class SpacedRepetitionService
  # Ebbinghaus forgetting curve constants
  INITIAL_INTERVAL = 1       # 첫 복습: 1일 후
  SECOND_INTERVAL = 3        # 두 번째 복습: 3일 후
  EASE_FACTOR_DEFAULT = 2.5  # 기본 난이도 계수
  MIN_EASE_FACTOR = 1.3      # 최소 난이도 계수
  QUALITY_THRESHOLD = 3      # 품질 임계값 (3 이상이면 성공)

  def initialize(learning_record)
    @learning_record = learning_record
  end

  # 학습 완료 후 다음 복습 일정 생성
  def schedule_next_review(quality_score)
    # quality_score: 0-5 (0: 완전히 틀림, 5: 완벽함)
    
    current_schedule = @learning_record.review_schedules.last
    
    if quality_score >= QUALITY_THRESHOLD
      # 정답인 경우 - 다음 복습 일정 생성
      create_next_schedule(current_schedule, quality_score)
      update_learning_status_on_success
    else
      # 틀린 경우 - 학습 다시 시작
      reset_learning_progress
    end
  end

  # 오늘 복습할 문장들 가져오기
  def self.get_due_reviews_for_user(user)
    user.learning_records
        .joins(:review_schedules)
        .where(review_schedules: { 
          scheduled_date: ..Date.current, 
          completed: false 
        })
        .includes(:sentence, :review_schedules)
        .order('review_schedules.scheduled_date ASC')
  end

  # 복습 완료 처리
  def mark_review_completed
    current_schedule = @learning_record.review_schedules.pending.first
    current_schedule&.update!(completed: true, completed_at: Time.current)
  end

  # 복습 통계
  def self.review_stats_for_user(user)
    today_due = get_due_reviews_for_user(user).count
    overdue = user.learning_records
                  .joins(:review_schedules)
                  .where(review_schedules: { 
                    scheduled_date: ...Date.current, 
                    completed: false 
                  }).count
    
    {
      today_due: today_due,
      overdue: overdue,
      total_reviews: today_due + overdue
    }
  end

  private

  def create_next_schedule(current_schedule, quality_score)
    if current_schedule.nil?
      # 첫 번째 복습 일정
      interval = INITIAL_INTERVAL
      ease_factor = EASE_FACTOR_DEFAULT
    else
      # 기존 일정이 있는 경우 - SM-2 알고리즘 적용
      interval = calculate_next_interval(current_schedule, quality_score)
      ease_factor = calculate_ease_factor(current_schedule.ease_factor, quality_score)
    end

    @learning_record.review_schedules.create!(
      scheduled_date: Date.current + interval.days,
      interval_days: interval,
      ease_factor: ease_factor,
      completed: false
    )
  end

  # SM-2 알고리즘을 기반으로 한 간격 계산
  def calculate_next_interval(current_schedule, quality_score)
    previous_interval = current_schedule.interval_days
    ease_factor = current_schedule.ease_factor

    case previous_interval
    when INITIAL_INTERVAL
      SECOND_INTERVAL
    when SECOND_INTERVAL
      6 # 세 번째는 6일
    else
      # 그 이후는 이전 간격 × 난이도 계수
      (previous_interval * ease_factor).round
    end
  end

  # SM-2 알고리즘 난이도 계수 계산
  def calculate_ease_factor(current_ease_factor, quality_score)
    # EF = EF + (0.1 - (5-q) * (0.08 + (5-q) * 0.02))
    new_ease_factor = current_ease_factor + (0.1 - (5 - quality_score) * (0.08 + (5 - quality_score) * 0.02))
    
    # 최소값 보장
    [new_ease_factor, MIN_EASE_FACTOR].max
  end

  def update_learning_status_on_success
    case @learning_record.status
    when 'not_started'
      @learning_record.update!(status: 'learned')
    when 'learning'
      # 연속 성공 횟수에 따라 learned 또는 mastered로 승격
      review_count = @learning_record.review_schedules.completed.count
      if review_count >= 3
        @learning_record.update!(status: 'mastered')
      else
        @learning_record.update!(status: 'learned')
      end
    end
  end

  def reset_learning_progress
    # 틀린 경우 학습 상태를 learning으로 되돌리고 첫 복습부터 다시 시작
    @learning_record.update!(status: 'learning')
    
    # 기존 미완료 복습 일정 삭제
    @learning_record.review_schedules.pending.destroy_all
    
    # 새로운 첫 복습 일정 생성 (1일 후)
    @learning_record.review_schedules.create!(
      scheduled_date: Date.current + 1.day,
      interval_days: INITIAL_INTERVAL,
      ease_factor: EASE_FACTOR_DEFAULT,
      completed: false
    )
  end
end