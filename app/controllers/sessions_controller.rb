class SessionsController < ApplicationController
  def new
    redirect_to dashboard_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:email])
    
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:success] = "#{user.nickname}님, 환영합니다!"
      redirect_to dashboard_path
    else
      flash.now[:error] = "이메일 또는 비밀번호가 잘못되었습니다."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:success] = "로그아웃되었습니다."
    redirect_to login_path
  end
end
