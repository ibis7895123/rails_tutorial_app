class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    # 以下を埋め込むとコンソールでその時点のデバッグができる
    # debugger
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    # 保存が成功したかどうかで遷移先を分岐
    if @user.save
      redirect_to user_url(@user)
    else
      render 'new'
    end
  end

  def user_params
    params
      .require(:user)
      .permit(:name, :email, :password, :password_confirmation)
  end

  private :user_params
end
