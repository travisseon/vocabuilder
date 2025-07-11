class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  before_action :current_user
  
  private
  
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
  
  def logged_in?
    !!current_user
  end
  
  def require_login
    unless logged_in?
      flash[:error] = "로그인이 필요합니다."
      redirect_to login_path
    end
  end
  
  helper_method :current_user, :logged_in?
  
  protected
  
  def update_user_study_statistics(study_time)
    current_user.total_study_time += study_time
    
    # 연속 학습 일수 계산 (last_study_date 변경 전에 계산)
    if current_user.last_study_date == Date.current - 1.day
      # 어제 학습했으면 연속 일수 증가
      current_user.streak_days += 1
    elsif current_user.last_study_date == Date.current
      # 오늘 이미 학습했으면 연속 일수 유지 (변경 없음)
    else
      # 그 외의 경우 (처음 학습 또는 연속 끊김) 1일로 설정
      current_user.streak_days = 1
    end
    
    current_user.last_study_date = Date.current
    current_user.save!
  end
end
