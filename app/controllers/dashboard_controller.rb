class DashboardController < ApplicationController
  def index
    if logged_in?
      @user = current_user
      @daily_quote = DailyQuote.today_quote
      @user_deck_progresses = @user.user_deck_progresses.includes(:deck)
      @total_study_time_hours = (@user.total_study_time / 3600.0).round(1)
      @achievements = @user.user_achievements.recent.limit(3)
      
      # SRS 통계 (안전하게 처리)
      begin
        @review_stats = SpacedRepetitionService.review_stats_for_user(@user)
      rescue NameError
        @review_stats = { today_due: 0, overdue: 0, total_reviews: 0 }
      end
    else
      redirect_to login_path
    end
  end
end
