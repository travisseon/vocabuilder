class UsersController < ApplicationController
  before_action :require_login, only: [:show]
  
  def new
    redirect_to dashboard_path if logged_in?
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      session[:user_id] = @user.id
      flash[:success] = "#{@user.nickname}님, 회원가입을 환영합니다!"
      redirect_to dashboard_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user = current_user
  end
  
  private
  
  def user_params
    params.require(:user).permit(:email, :nickname, :password, :password_confirmation)
  end
end
