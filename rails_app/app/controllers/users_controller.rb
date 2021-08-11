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

    # 保存に失敗した
    render 'new' unless @user.save

    # 保存に成功
  end

  def user_params
    params
      .require(:user)
      .permit(:name, :email, :password, :password_confirmation)
  end

  private :user_params
end
